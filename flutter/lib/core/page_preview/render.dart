import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;
import 'package:homeprint_o_tool/core/json.dart';
import 'package:homeprint_o_tool/core/page_preview/cut_guide_style.dart';
import 'package:homeprint_o_tool/core/page_preview/cut_svg_export.dart';
import 'package:homeprint_o_tool/core/page_preview/export_dialog.dart';
import 'package:homeprint_o_tool/core/page_preview/png.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/core/save_file.dart';
import 'package:homeprint_o_tool/page/picks/include_data.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

import 'package:homeprint_o_tool/page/layout/layout_logic.dart';
import 'package:homeprint_o_tool/page/layout/layout_data.dart';
import 'package:homeprint_o_tool/page/review/pagination.dart';
import 'package:homeprint_o_tool/core/page_preview/page_preview.dart';
import 'package:homeprint_o_tool/core/page_preview/page_preview_frame.dart';

enum ExportingFrontBack { front, back }

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

  ExportSettings? settings =
      await openPreExportDialog(context, layoutData, projectSettings);
  if (settings == null) {
    return;
  }

  // --- SVG cut-line branch ------------------------------------------------
  if (settings.action == ExportAction.exportCutSvg) {
    await _exportCutSvg(
        context, settings, layoutData, projectSettings, baseDirectory);
    return;
  }
  // ------------------------------------------------------------------------

  String? directory = await getDirectoryPath(initialDirectory: baseDirectory);
  if (directory == null) {
    return;
  }

  final cardCountRowCol =
      calculateCardCountPerPage(layoutData, projectSettings.cardSize);
  final pagination = calculatePagination(includeItems, layoutData,
      projectSettings.cardSize, cardCountRowCol.rows, cardCountRowCol.columns);

  final pixelPerInch = settings.pixelPerInch;
  final pixelWidth = layoutData.paperSize.widthInch * pixelPerInch;
  final pixelHeight = layoutData.paperSize.heightInch * pixelPerInch;
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
                            'Progress: ${_calculateProgressPercentage(settings.frontSideOnly, page, pagination.totalPages, side)}%',
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
                      value: settings.frontSideOnly
                          ? page / pagination.totalPages
                          : (2 * (page - 1) +
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

        final frontCards = settings.backSideFirst ? cards.back : cards.front;
        final backCards = settings.backSideFirst ? cards.front : cards.back;

        // Front side
        onFrontBackUpdate(ExportingFrontBack.front);
        if (isCancelled) break;

        // Create a preview for the progress dialog
        final frontPreview = PagePreview(
          layoutData: layoutData,
          cards: frontCards,
          layout: false,
          cutGuideStyle: settings.cutGuideStyle,
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
            frontCards,
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
            settings.cutGuideStyle,
            pixelPerInch,
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

        // Back side - skip if frontSideOnly is true
        if (isCancelled || settings.frontSideOnly) continue;
        onFrontBackUpdate(ExportingFrontBack.back);

        // Create a preview for the progress dialog
        final backPreview = PagePreview(
          layoutData: layoutData,
          cards: backCards,
          layout: false,
          cutGuideStyle: settings.cutGuideStyle,
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
            backCards,
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
            settings.cutGuideStyle,
            pixelPerInch,
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

// Calculate the progress percentage for the progress indicator
String _calculateProgressPercentage(
    bool frontSideOnly, int page, int totalPages, ExportingFrontBack side) {
  double progress;
  if (frontSideOnly) {
    // If front side only, each page represents one complete step (100% / total pages)
    progress = page / totalPages * 100;
  } else {
    // If both sides, each page has two sides, so we have (2 * total pages) steps
    progress = ((2 * (page - 1) + (side == ExportingFrontBack.front ? 0 : 1)) /
            (2 * totalPages)) *
        100;
  }
  return progress.toStringAsFixed(1);
}

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
    Rotation rotation,
    CutGuideStyle cutGuideStyle,
    int pixelPerInch) async {
  // Decode every image on this page up front. Awaiting this is what makes the
  // render deterministic: the widget tree can then draw each image
  // synchronously (RawImage) with nothing asynchronous left to wait for.
  final preloadedImages = await preloadPageImages(cardsOnePage, baseDirectory);

  PagePreview toRender = PagePreview(
    layoutData: layoutData,
    cards: cardsOnePage,
    layout: false,
    cutGuideStyle: cutGuideStyle,
    baseDirectory: baseDirectory,
    projectSettings: projectSettings,
    hideInnerCutLine: true,
    back: back,
    preloadedImages: preloadedImages,
  );

  // Replace placeholders in the template
  final fileName = template
      .replaceAll("{prefix}", prefix)
      .replaceAll("{page}", (pageNumber + 1).toString())
      .replaceAll("{side}", back ? backSuffix : frontSuffix);

  Uint8List imageUint;
  try {
    imageUint = await createImageBytesFromWidget(
        flutterView, toRender, pixelWidth, pixelHeight);
  } finally {
    // We own the master images; the widget tree painted from clones of them.
    for (final image in preloadedImages.values) {
      image.dispose();
    }
  }

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

  await savePng(finalImageData, directory, fileName, pixelPerInch);

  // Help trigger garbage collection between pages to reduce memory pressure
  // This is particularly important for large export jobs with many high-resolution images
  await Future.delayed(Duration.zero);
}

Future<Uint8List> createImageBytesFromWidget(ui.FlutterView flutterView,
    Widget widget, double pixelWidth, double pixelHeight) async {
  final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
  final ViewConfiguration viewConfig = ViewConfiguration(
    logicalConstraints: BoxConstraints(
      minWidth: pixelWidth,
      minHeight: pixelHeight,
      maxWidth: pixelWidth,
      maxHeight: pixelHeight,
    ),
    devicePixelRatio: 1,
  );
  final RenderView renderView = RenderView(
    view: flutterView,
    child: RenderPositionedBox(
        alignment: Alignment.center, child: repaintBoundary),
    configuration: viewConfig,
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
      child: widget,
    ),
  ).attachToRenderTree(buildOwner);

  // Every image in [widget] is pre-decoded and painted synchronously via
  // RawImage (see [preloadPageImages] / PagePreview.preloadedImages), so the
  // whole tree settles in a single build/layout/paint pass — there is nothing
  // asynchronous to wait for. A few delay-free flushes guarantee that nested
  // LayoutBuilders are fully resolved before we capture, with no arbitrary
  // sleeping and no race against image loading.
  for (var i = 0; i < 3; i++) {
    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();
    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();
  }

  final image = await repaintBoundary.toImage(pixelRatio: 1);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final uint8List = byteData!.buffer.asUint8List();
  image.dispose();

  return uint8List;
}

/// Decodes every distinct image used by [cards] into a ready-to-paint
/// `ui.Image`, keyed by the card face's relative file path.
///
/// Doing (and awaiting) the decode up front is what makes export rendering
/// deterministic: the widget tree can then draw each image synchronously with
/// `RawImage` instead of relying on the asynchronous `Image.file` / `ImageStream`
/// machinery, which the off-screen render pipeline has no reliable way to wait
/// for. It also sidesteps the global `imageCache` entirely, so behaviour no
/// longer depends on image size, decode speed, or cache warmth.
///
/// Missing or undecodable files are simply omitted; [CardArea] renders a red
/// placeholder for those. The caller owns the returned images and must dispose
/// them once the page has been captured.
Future<Map<String, ui.Image>> preloadPageImages(
    RowColCards cards, String baseDirectory) async {
  final Set<String> relativePaths = {};
  for (final row in cards) {
    for (final card in row) {
      if (card != null && card.relativeFilePath.isNotEmpty) {
        relativePaths.add(card.relativeFilePath);
      }
    }
  }

  final Map<String, ui.Image> images = {};
  for (final relativePath in relativePaths) {
    final file = File(p.join(baseDirectory, relativePath));
    if (!file.existsSync()) {
      continue;
    }
    try {
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      images[relativePath] = frame.image;
      codec.dispose();
    } catch (_) {
      // Leave it out of the map; CardArea will show a placeholder.
    }
  }
  return images;
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
    for (var picked in includeItem.pickedCards) {
      final card = picked.duplexCard;

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

/// Resolves the cut SVG filename from the export settings template,
/// appends `_cut`, then opens a save-file dialog and writes the SVG.
Future<void> _exportCutSvg(
  BuildContext context,
  ExportSettings settings,
  LayoutData layoutData,
  ProjectSettings projectSettings,
  String baseDirectory,
) async {
  final svgType = XTypeGroup(label: 'SVG', extensions: ['svg']);
  final saveLocation = await getSaveLocation(
    acceptedTypeGroups: [svgType],
    initialDirectory: baseDirectory,
    suggestedName: '${settings.prefix}_cut.svg',
  );
  if (saveLocation == null) return;

  final cardCount =
      calculateCardCountPerPage(layoutData, projectSettings.cardSize);
  if (cardCount.rows <= 0 || cardCount.columns <= 0) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No cards fit the current layout. SVG not saved.')),
      );
    }
    return;
  }

  final svgContent = generateCutSvg(
    layoutData,
    projectSettings,
    settings.cutCornerRadiusMm,
    settings.pixelPerInch,
    settings.frontRotation,
  );

  await saveCutSvg(svgContent, saveLocation.path);

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cut SVG exported successfully.')),
    );
  }
}
