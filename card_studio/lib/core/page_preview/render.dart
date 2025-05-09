import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:homeprint_o_tool/core/json.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/core/save_file.dart';
import 'package:homeprint_o_tool/page/picks/include_data.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

import '../../page/layout/layout_logic.dart';
import '../../page/layout/layout_struct.dart';
import '../../page/review/pagination.dart';
import 'page_preview.dart';
import 'page_preview_frame.dart';

enum ExportingFrontBack { front, back }

class ExportSettings {
  final String prefix;
  final String template;
  final String frontSuffix;
  final String backSuffix;
  final Rotation frontRotation;
  final Rotation backRotation;

  ExportSettings({
    required this.prefix,
    required this.template,
    required this.frontSuffix,
    required this.backSuffix,
    required this.frontRotation,
    required this.backRotation,
  });
}

Future renderRender(
  BuildContext context,
  ui.FlutterView flutterView,
  ProjectSettings projectSettings,
  LayoutData layoutData,
  Includes includeItems,
  Includes skipIncludeItems,
  String baseDirectory,
  LinkedCardFaces linkedCardFaces,
  void Function(int) onCurrentPageUpdate,
  void Function(ExportingFrontBack) onFrontBackUpdate,
  void Function(int) onTotalPageUpdate,
) async {
  final bool frontSideOnly =
      frontSideOnlyIncludes(includeItems, linkedCardFaces);

  // Check for cards with missing graphics before proceeding
  final missingGraphicsResult = checkMissingGraphicsInPickedCards(
      includeItems, baseDirectory, linkedCardFaces);
  if (missingGraphicsResult.count > 0) {
    final bool shouldContinue = await showMissingGraphicsWarningDialog(
        context, missingGraphicsResult.count);
    if (!shouldContinue) {
      return;
    }
  }

  ExportSettings? settings = await openPreExportDialog(context, frontSideOnly);
  if (settings == null) {
    return;
  }
  String? directory = await getDirectoryPath(initialDirectory: baseDirectory);
  if (directory == null) {
    return;
  }

  final cardCountRowCol =
      calculateCardCountPerPage(layoutData, projectSettings.cardSize);
  final pagination = calculatePagination(includeItems, layoutData,
      projectSettings.cardSize, cardCountRowCol.rows, cardCountRowCol.columns);

  final pixelWidth = layoutData.paperSize.widthInch * layoutData.pixelPerInch;
  final pixelHeight = layoutData.paperSize.heightInch * layoutData.pixelPerInch;
  onTotalPageUpdate(pagination.totalPages);

  // Create a completer to handle cancellation
  final completer = Completer<void>();
  bool isCancelled = false;

  // Store the ongoing dialog controller
  BuildContext? dialogContext;

  // Function to update the preview dialog
  void updatePreview(int page, ExportingFrontBack side, PagePreview preview) {
    if (dialogContext != null &&
        Navigator.of(dialogContext!, rootNavigator: true).canPop()) {
      Navigator.of(dialogContext!, rootNavigator: true).pop();
      dialogContext = null;
    }

    if (context.mounted && !isCancelled) {
      // Show new dialog without awaiting
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) {
          dialogContext = ctx;
          return Dialog.fullscreen(
            child: Scaffold(
              appBar: AppBar(
                title: Text('Exporting Uncut Sheets'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    isCancelled = true;
                    Navigator.of(ctx).pop();
                    dialogContext = null;
                    completer.complete(); // Complete the future when canceled
                  },
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Exporting page $page of ${pagination.totalPages} (${side == ExportingFrontBack.front ? "Front" : "Back"})',
                              style: Theme.of(ctx).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(ctx).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Progress: ${((2 * (page - 1) + (side == ExportingFrontBack.front ? 0 : 1)) / (2 * pagination.totalPages) * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              color:
                                  Theme.of(ctx).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: (2 * (page - 1) +
                              (side == ExportingFrontBack.front ? 0 : 1)) /
                          (2 * pagination.totalPages),
                      minHeight: 10,
                    ),
                    const SizedBox(height: 32),
                    Expanded(
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: AspectRatio(
                            aspectRatio:
                                preview.layoutData.paperSize.widthInch /
                                    preview.layoutData.paperSize.heightInch,
                            child: PagePreviewFrame(
                              child: preview,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ).catchError((error) {
        // Handle any errors that occur during dialog creation
        print('Error showing export progress dialog: $error');
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      });
    }
  }

  // Process pages and sides
  void processExport() async {
    try {
      for (var i = 0; i < pagination.totalPages; i++) {
        if (isCancelled) break;

        onCurrentPageUpdate(i + 1);
        final cards = cardsAtPage(includeItems, skipIncludeItems, layoutData,
            projectSettings.cardSize, i + 1, linkedCardFaces);

        // Front side
        onFrontBackUpdate(ExportingFrontBack.front);
        if (isCancelled) break;

        // Create a preview for the progress dialog
        final frontPreview = PagePreview(
          layoutData: layoutData,
          cards: cards.front,
          layout: false,
          previewCutLine: false,
          baseDirectory: baseDirectory,
          projectSettings: projectSettings,
          hideInnerCutLine: true,
          back: false,
        );

        // Update the preview dialog without waiting
        updatePreview(i + 1, ExportingFrontBack.front, frontPreview);

        if (isCancelled) break;
        try {
          await renderOneSide(
            false,
            layoutData,
            projectSettings,
            cards.front,
            baseDirectory,
            flutterView,
            pixelWidth,
            pixelHeight,
            directory,
            settings.prefix,
            settings.template,
            settings.frontSuffix,
            settings.backSuffix,
            i,
            settings.frontRotation,
          );
        } catch (e) {
          print('Error rendering front side of page ${i + 1}: $e');
          if (isCancelled) break;
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Error rendering front side of page ${i + 1}. Continuing with next page...'),
              ),
            );
          }
          // Continue with next page
          continue;
        }

        // Back side
        if (isCancelled) break;
        onFrontBackUpdate(ExportingFrontBack.back);

        // Create a preview for the progress dialog
        final backPreview = PagePreview(
          layoutData: layoutData,
          cards: cards.back,
          layout: false,
          previewCutLine: false,
          baseDirectory: baseDirectory,
          projectSettings: projectSettings,
          hideInnerCutLine: true,
          back: true,
        );

        // Update the preview dialog without waiting
        updatePreview(i + 1, ExportingFrontBack.back, backPreview);

        if (isCancelled) break;
        try {
          await renderOneSide(
            true,
            layoutData,
            projectSettings,
            cards.back,
            baseDirectory,
            flutterView,
            pixelWidth,
            pixelHeight,
            directory,
            settings.prefix,
            settings.template,
            settings.frontSuffix,
            settings.backSuffix,
            i,
            settings.backRotation,
          );
        } catch (e) {
          print('Error rendering back side of page ${i + 1}: $e');
          if (isCancelled) break;
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Error rendering back side of page ${i + 1}. Continuing with next page...'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          // Continue with next page
          continue;
        }
      }

      // Close the dialog if it's still open
      if (dialogContext != null &&
          Navigator.of(dialogContext!, rootNavigator: true).canPop()) {
        Navigator.of(dialogContext!, rootNavigator: true).pop();
        dialogContext = null;
      }

      if (!isCancelled && context.mounted) {
        // Show completion message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export completed successfully!'),
          ),
        );
      } else if (isCancelled && context.mounted) {
        // Show cancellation message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export was cancelled'),
          ),
        );
      }

      if (!completer.isCompleted) {
        completer.complete();
      }
    } catch (e) {
      // Close the dialog if it's still open
      if (dialogContext != null &&
          Navigator.of(dialogContext!, rootNavigator: true).canPop()) {
        Navigator.of(dialogContext!, rootNavigator: true).pop();
        dialogContext = null;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during export: $e'),
          ),
        );
      }
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
    }
  }

  // Start the export process
  processExport();

  // Wait for completion or cancellation
  return completer.future;
}

// The showCurrentPagePreview function has been replaced with the inline updatePreview function

Future<void> renderOneSide(
    bool back,
    LayoutData layoutData,
    ProjectSettings projectSettings,
    RowColCards cardsOnePage,
    String baseDirectory,
    ui.FlutterView flutterView,
    double pixelWidth,
    double pixelHeight,
    String directory,
    String prefix,
    String template,
    String frontSuffix,
    String backSuffix,
    int pageNumber,
    Rotation rotation) async {
  PagePreview toRender = PagePreview(
    layoutData: layoutData,
    cards: cardsOnePage,
    layout: false,
    previewCutLine: false,
    baseDirectory: baseDirectory,
    projectSettings: projectSettings,
    hideInnerCutLine: true,
    back: back,
  );

  // Replace placeholders in the template
  final fileName = template
      .replaceAll("{prefix}", prefix)
      .replaceAll("{page}", (pageNumber + 1).toString())
      .replaceAll("{side}", back ? backSuffix : frontSuffix);

  Uint8List imageUint = await createImageBytesFromWidget(
      flutterView, toRender, pixelWidth, pixelHeight);

  // Apply rotation if needed
  Uint8List finalImageData;
  if (rotation != Rotation.none) {
    // Process the image rotation
    final img = await decodeImageFromList(imageUint);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    if (rotation == Rotation.clockwise90) {
      // Rotate 90 degrees clockwise
      canvas.translate(img.height.toDouble(), 0);
      canvas.rotate(pi / 2);
      canvas.drawImage(img, Offset.zero, Paint());
    } else if (rotation == Rotation.counterClockwise90) {
      // Rotate 90 degrees counter-clockwise
      canvas.translate(0, img.width.toDouble());
      canvas.rotate(-pi / 2);
      canvas.drawImage(img, Offset.zero, Paint());
    }

    final picture = recorder.endRecording();
    final width = rotation == Rotation.none ? img.width : img.height;
    final height = rotation == Rotation.none ? img.height : img.width;

    final rotatedImage = await picture.toImage(width, height);
    final byteData =
        await rotatedImage.toByteData(format: ui.ImageByteFormat.png);
    finalImageData = byteData!.buffer.asUint8List();

    // Dispose of the original image to free up memory
    img.dispose();
    rotatedImage.dispose();
  } else {
    finalImageData = imageUint;
  }

  await savePng(finalImageData, directory, fileName);

  // Help trigger garbage collection between pages to reduce memory pressure
  // This is particularly important for large export jobs with many high-resolution images
  await Future.delayed(Duration.zero);
}

Future<ExportSettings?> openPreExportDialog(
    BuildContext context, bool frontSideOnly) async {
  String tempPrefix = "export";
  String tempTemplate = "{prefix}_{page}_{side}";
  String tempFrontSuffix = "A";
  String tempBackSuffix = "B";
  Rotation tempFrontRotation = Rotation.none;
  Rotation tempBackRotation = Rotation.none;

  final Widget noBacksideText = Container(
    padding: EdgeInsets.all(10),
    margin: EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: Colors.yellow[100],
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.yellow[700]!),
    ),
    child: Row(
      children: [
        Icon(Icons.info, color: Colors.yellow[700]),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            "Every card you picked has only a front side. Exporting only the front side of each page.",
            style: TextStyle(color: Colors.black87),
          ),
        ),
      ],
    ),
  );

  return await showDialog<ExportSettings>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Export Settings'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (frontSideOnly) noBacksideText,
              TextField(
                controller: TextEditingController(text: tempTemplate),
                decoration: InputDecoration(
                  labelText: "File Name Template",
                  helperText: "Use {prefix}, {page}, {side} as placeholders.",
                ),
                onChanged: (value) {
                  tempTemplate = value;
                },
              ),
              TextField(
                controller: TextEditingController(text: tempPrefix),
                decoration: InputDecoration(labelText: "File Name Prefix"),
                onChanged: (value) {
                  tempPrefix = value;
                },
              ),
              TextField(
                controller: TextEditingController(text: tempFrontSuffix),
                decoration: InputDecoration(labelText: "Front Side Suffix"),
                onChanged: (value) {
                  tempFrontSuffix = value;
                },
              ),
              TextField(
                controller: TextEditingController(text: tempBackSuffix),
                decoration: InputDecoration(labelText: "Back Side Suffix"),
                onChanged: (value) {
                  tempBackSuffix = value;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<Rotation>(
                value: tempFrontRotation,
                decoration: InputDecoration(labelText: "Front Post-Rotation"),
                items: [
                  DropdownMenuItem(
                    value: Rotation.none,
                    child: Text("None"),
                  ),
                  DropdownMenuItem(
                    value: Rotation.clockwise90,
                    child: Text("Clockwise 90"),
                  ),
                  DropdownMenuItem(
                    value: Rotation.counterClockwise90,
                    child: Text("Counter-clockwise 90"),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    tempFrontRotation = value;
                  }
                },
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<Rotation>(
                value: tempBackRotation,
                decoration: InputDecoration(labelText: "Back Post-Rotation"),
                items: [
                  DropdownMenuItem(
                    value: Rotation.none,
                    child: Text("None"),
                  ),
                  DropdownMenuItem(
                    value: Rotation.clockwise90,
                    child: Text("Clockwise 90"),
                  ),
                  DropdownMenuItem(
                    value: Rotation.counterClockwise90,
                    child: Text("Counter-clockwise 90"),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    tempBackRotation = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(null); // Cancel
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(
                ExportSettings(
                  prefix: tempPrefix,
                  template: tempTemplate,
                  frontSuffix: tempFrontSuffix,
                  backSuffix: tempBackSuffix,
                  frontRotation: tempFrontRotation,
                  backRotation: tempBackRotation,
                ),
              ); // Confirm
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

Future savePng(Uint8List imageData, String directory, String fileName) async {
  await File("$directory/$fileName.png").writeAsBytes(imageData);
}

Future<Uint8List> createImageBytesFromWidget(ui.FlutterView flutterView,
    Widget widget, double pixelWidth, double pixelHeight) async {
  final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
  final RenderView renderView = RenderView(
    view: flutterView,
    child: RenderPositionedBox(
        alignment: Alignment.center, child: repaintBoundary),
    configuration: ViewConfiguration.fromView(flutterView),
  );

  final PipelineOwner pipelineOwner = PipelineOwner();
  pipelineOwner.rootNode = renderView;
  renderView.prepareInitialFrame();

  final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());
  final RenderObjectToWidgetElement<RenderBox> rootElement =
      RenderObjectToWidgetAdapter<RenderBox>(
    container: repaintBoundary,
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: IntrinsicHeight(child: IntrinsicWidth(child: widget)),
    ),
  ).attachToRenderTree(buildOwner);

  // I don't know a reliable way to wait for async image to load in the
  // preview other than waiting for arbitrary time like this.
  final int renderIterations = 30;
  final int delayMs = 5;

  for (var i = 0; i < renderIterations; i++) {
    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();
    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    // Less delay for initial iterations
    if (i < 5) {
      await Future.delayed(Duration(milliseconds: 1));
    } else {
      await Future.delayed(Duration(milliseconds: delayMs));
    }
  }

  final imgg =
      await repaintBoundary.toImage(pixelRatio: flutterView.devicePixelRatio);
  final bd = await imgg.toByteData(format: ui.ImageByteFormat.png);
  final uint8List = bd!.buffer.asUint8List();

  return uint8List;
}

/// Result of checking for missing graphics in picked cards
class MissingGraphicsResult {
  final int count;

  MissingGraphicsResult(this.count);
}

/// Checks if any picked cards have missing graphics files
MissingGraphicsResult checkMissingGraphicsInPickedCards(Includes includeItems,
    String baseDirectory, LinkedCardFaces linkedCardFaces) {
  int missingGraphicsCount = 0;

  for (var includeItem in includeItems) {
    if (includeItem.cardGroup != null) {
      // Check all cards in the group that are included
      for (var card in includeItem.cardGroup!.cards) {
        // Check front face
        final frontFace = card.getFront(linkedCardFaces);
        if (frontFace != null && frontFace.relativeFilePath.isNotEmpty) {
          if (frontFace.isImageMissing(baseDirectory)) {
            missingGraphicsCount++;
          }
        }

        // Check back face
        final backFace = card.getBack(linkedCardFaces);
        if (backFace != null && backFace.relativeFilePath.isNotEmpty) {
          if (backFace.isImageMissing(baseDirectory)) {
            missingGraphicsCount++;
          }
        }
      }
    } else if (includeItem.cardEach != null) {
      // Check individual card
      final card = includeItem.cardEach!;

      // Check front face
      final frontFace = card.getFront(linkedCardFaces);
      if (frontFace != null && frontFace.relativeFilePath.isNotEmpty) {
        if (frontFace.isImageMissing(baseDirectory)) {
          missingGraphicsCount++;
        }
      }

      // Check back face
      final backFace = card.getBack(linkedCardFaces);
      if (backFace != null && backFace.relativeFilePath.isNotEmpty) {
        if (backFace.isImageMissing(baseDirectory)) {
          missingGraphicsCount++;
        }
      }
    }
  }

  return MissingGraphicsResult(missingGraphicsCount);
}

/// Shows a warning dialog if there are missing graphics in picked cards
Future<bool> showMissingGraphicsWarningDialog(
    BuildContext context, int missingGraphicsCount) async {
  return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 10),
                Text('Missing Graphics'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Warning: $missingGraphicsCount picked card${missingGraphicsCount == 1 ? '' : 's'} '
                  'with missing graphics detected.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                    'These cards will appear with placeholder graphics in the exported sheets. '
                    'Do you want to proceed with the export anyway?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Don't continue
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Continue anyway
                },
                child: Text('Export Anyway'),
              ),
            ],
          );
        },
      ) ??
      false; // Default to false if dialog is dismissed
}
