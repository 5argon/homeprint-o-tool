import 'dart:io';
import 'dart:typed_data';

import 'package:card_studio/core/project_settings.dart';
import 'package:card_studio/page/include/include_data.dart';

import 'layout_struct.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

import 'page_preview.dart';

Future renderRender(
  BuildContext context,
  ProjectSettings projectSettings,
  LayoutData layoutData,
  List<IncludeItem> includeItems,
) async {
  var toRender = PagePreview(
    layoutData,
    projectSettings.cardSize,
    [],
  );
  final pixelWidth = layoutData.paperSize.widthInch * layoutData.pixelPerInch;
  final pixelHeight = layoutData.paperSize.heightInch * layoutData.pixelPerInch;
  final imageUint = await createImageBytesFromWidget(
      context, toRender, pixelWidth, pixelHeight);
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

Future<Uint8List> createImageBytesFromWidget(BuildContext context,
    Widget widget, double pixelWidth, double pixelHeight) {
  final flutterView = View.of(context);
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
