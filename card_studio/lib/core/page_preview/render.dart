import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/page/include/include_data.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

import '../../page/layout/layout_logic.dart';
import '../../page/layout/layout_struct.dart';
import '../../page/review/pagination.dart';
import 'page_preview.dart';

enum ExportingFrontBack { front, back }

Future renderRender(
  BuildContext context,
  ui.FlutterView flutterView,
  ProjectSettings projectSettings,
  LayoutData layoutData,
  Includes includeItems,
  Includes skipIncludeItems,
  String baseDirectory,
  void Function(int) onCurrentPageUpdate,
  void Function(ExportingFrontBack) onFrontBackUpdate,
  void Function(int) onTotalPageUpdate,
) async {
  // Open the export directory picker and get the combined result
  String? result = await openExportDirectoryPicker(context);
  if (result == null) {
    return; // User canceled
  }

  // Split the result into directory and file prefix
  final parts = result.split('|');
  final exportDirectory = parts[0];
  final filePrefix = parts[1];

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
        projectSettings.cardSize, i + 1);
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
      exportDirectory,
      filePrefix,
      "A",
      i,
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
      exportDirectory,
      filePrefix,
      "B",
      i,
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
    String fileName,
    String frontBackSuffix,
    int pageNumber) async {
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
  final imageUint = await createImageBytesFromWidget(
      flutterView, toRender, pixelWidth, pixelHeight);
  await savePng(
      imageUint, directory, "${fileName}_${pageNumber + 1}_$frontBackSuffix");
}

Future<String?> openExportDirectoryPicker(BuildContext context) async {
  // Show a dialog to ask for the file name prefix
  String? filePrefix = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      String tempPrefix = "";
      return AlertDialog(
        title: Text('Enter File Name Prefix'),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: TextEditingController(text: "export"),
            onChanged: (value) {
              tempPrefix = value;
            },
            decoration:
                InputDecoration(hintText: "Enter prefix (e.g., 'export')"),
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
              Navigator.of(context).pop(tempPrefix); // Confirm
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );

  // If the user cancels or doesn't enter a prefix, return null
  if (filePrefix == null || filePrefix.isEmpty) {
    return null;
  }

  // Proceed to directory selection
  String? directory = await FilePicker.platform.getDirectoryPath(
    dialogTitle: 'Please select an output directory.',
  );

  // Return the directory and prefix combined as a single string
  return directory != null ? "$directory|$filePrefix" : null;
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
    configuration: ViewConfiguration(
      size: Size(pixelWidth, pixelHeight),
      devicePixelRatio: 1,
    ),
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
  // print(
  //     "Third render took ${finish3.millisecondsSinceEpoch - start3.millisecondsSinceEpoch} ms");
  return uint8List;
}
