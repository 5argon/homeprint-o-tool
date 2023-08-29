import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:card_studio/core/project_settings.dart';
import 'package:card_studio/page/include/include_data.dart';
import 'package:path/path.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

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
  String directory,
  ui.FlutterView flutterView,
  ProjectSettings projectSettings,
  LayoutData layoutData,
  Includes includeItems,
  String baseDirectory,
  void Function(int) onCurrentPageUpdate,
  void Function(ExportingFrontBack) onFrontBackUpdate,
  void Function(int) onTotalPageUpdate,
) async {
  final cardCountRowCol =
      calculateCardCountPerPage(layoutData, projectSettings.cardSize);
  final pagination = calculatePagination(includeItems, layoutData,
      projectSettings.cardSize, cardCountRowCol.rows, cardCountRowCol.columns);
  final pixelWidth = layoutData.paperSize.widthInch * layoutData.pixelPerInch;
  final pixelHeight = layoutData.paperSize.heightInch * layoutData.pixelPerInch;
  onTotalPageUpdate(pagination.totalPages);
  for (var i = 0; i < pagination.totalPages; i++) {
    onCurrentPageUpdate(i + 1);
    final cards =
        cardsAtPage(includeItems, layoutData, projectSettings.cardSize, i + 1);
    const filePrefix = "export";
    onFrontBackUpdate(ExportingFrontBack.front);

    await renderOneSide(
      layoutData,
      projectSettings,
      cards.front,
      baseDirectory,
      flutterView,
      pixelWidth,
      pixelHeight,
      directory,
      filePrefix,
      "A",
      i,
    );
    onFrontBackUpdate(ExportingFrontBack.back);
    await renderOneSide(
      layoutData,
      projectSettings,
      cards.back,
      baseDirectory,
      flutterView,
      pixelWidth,
      pixelHeight,
      directory,
      filePrefix,
      "B",
      i,
    );
  }
}

Future<void> renderOneSide(
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
    cardSize: projectSettings.cardSize,
    cards: cardsOnePage,
    layout: false,
    previewCutLine: false,
    baseDirectory: baseDirectory,
  );
  final imageUint = await createImageBytesFromWidget(
      flutterView, toRender, pixelWidth, pixelHeight);
  await savePng(
      imageUint, directory, "${fileName}_${pageNumber}_$frontBackSuffix");
}

Future<String?> openExportDirectoryPicker() async {
  String? directory = await FilePicker.platform.getDirectoryPath(
    dialogTitle: 'Please select an output directory.',
  );
  return directory;
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

  for (var i = 0; i < 10; i++) {
    buildOwner
      ..buildScope(rootElement)
      ..finalizeTree();
    pipelineOwner
      ..flushLayout()
      ..flushCompositingBits()
      ..flushPaint();
    await Future.delayed(Duration(milliseconds: 10));
  }

  final start3 = DateTime.timestamp();
  final bytes = await repaintBoundary
      .toImage(pixelRatio: flutterView.devicePixelRatio)
      .then((image) => image.toByteData(format: ui.ImageByteFormat.png))
      .then((byteData) => byteData!.buffer.asUint8List());
  final finish3 = DateTime.timestamp();
  print(
      "Third render took ${finish3.millisecondsSinceEpoch - start3.millisecondsSinceEpoch} ms");
  return bytes;
}
