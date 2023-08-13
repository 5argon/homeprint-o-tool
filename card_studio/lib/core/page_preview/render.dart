import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:card_studio/core/project_settings.dart';
import 'package:card_studio/page/include/include_data.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

import '../../page/layout/layout_struct.dart';
import '../../page/review/pagination.dart';
import 'page_preview.dart';

Future renderRender(
  BuildContext context,
  ProjectSettings projectSettings,
  LayoutData layoutData,
  Includes includeItems,
  String baseDirectory,
) async {
  final cards =
      cardsAtPage(includeItems, layoutData, projectSettings.cardSize, 1);
  var toRender = PagePreview(
    layoutData: layoutData,
    cardSize: projectSettings.cardSize,
    cards: cards.front,
    layout: false,
    previewCutLine: false,
    baseDirectory: baseDirectory,
  );
  final flutterView = View.of(context);
  final pixelWidth = layoutData.paperSize.widthInch * layoutData.pixelPerInch;
  final pixelHeight = layoutData.paperSize.heightInch * layoutData.pixelPerInch;
  final imageUint = await createImageBytesFromWidget(flutterView, toRender,
      pixelWidth, pixelHeight, toRender.waitForAllImages());
  final directory = await openExportDirectoryPicker();
  if (directory != null) {
    await savePng(imageUint, directory, "export");
  }
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

Future<Uint8List> createImageBytesFromWidget(
    ui.FlutterView flutterView,
    Widget widget,
    double pixelWidth,
    double pixelHeight,
    Future loading) async {
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

  // First time make the descriptor load.
  // Need to do it again only after we are sure descriptor finished loading.
  buildOwner
    ..buildScope(rootElement)
    ..finalizeTree();
  pipelineOwner
    ..flushLayout()
    ..flushCompositingBits()
    ..flushPaint();

  // Wait for image descriptor to async load.
  // Wait 1 second
  // await Future.delayed(Duration(seconds: 1));
  await loading;

  buildOwner
    ..buildScope(rootElement)
    ..finalizeTree();
  pipelineOwner
    ..flushLayout()
    ..flushCompositingBits()
    ..flushPaint();

  return repaintBoundary
      .toImage(pixelRatio: flutterView.devicePixelRatio)
      .then((image) => image.toByteData(format: ui.ImageByteFormat.png))
      .then((byteData) => byteData!.buffer.asUint8List());
}
