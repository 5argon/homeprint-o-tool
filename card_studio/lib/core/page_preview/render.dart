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
  for (var i = 0; i < pagination.totalPages; i++) {
    onCurrentPageUpdate(i + 1);
    final cards = cardsAtPage(includeItems, skipIncludeItems, layoutData,
        projectSettings.cardSize, i + 1, linkedCardFaces);
    onFrontBackUpdate(ExportingFrontBack.front);

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
    onFrontBackUpdate(ExportingFrontBack.back);
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
  }
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
    Rotation rotation) async {
  var toRender = PagePreview(
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

  final imageUint = await createImageBytesFromWidget(
      flutterView, toRender, pixelWidth, pixelHeight);

  // Apply rotation if needed
  Uint8List finalImageData = imageUint;
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
  }

  await savePng(finalImageData, directory, fileName);
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

  // Still can't find reliable way to wait for images to load by code.
  // Render once and wait for long period of time then render again didn't help,
  // it seems like the Image widget needs multiple renders to get them to load
  // and also some time in-between each render. Both number 10 here are arbitrary.

  for (var i = 0; i < 40; i++) {
    buildOwner
      ..buildScope(rootElement)
      ..finalizeTree();
    pipelineOwner
      ..flushLayout()
      ..flushCompositingBits()
      ..flushPaint();
    await Future.delayed(Duration(milliseconds: 10));
  }

  // final start3 = DateTime.timestamp();
  final imgg =
      await repaintBoundary.toImage(pixelRatio: flutterView.devicePixelRatio);
  final bd = await imgg.toByteData(format: ui.ImageByteFormat.png);
  final uint8List = bd!.buffer.asUint8List();

  // final finish3 = DateTime.timestamp();
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
