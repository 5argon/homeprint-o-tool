import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/page/include/include_data.dart';

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

  ExportSettings({
    required this.prefix,
    required this.template,
    required this.frontSuffix,
    required this.backSuffix,
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
  void Function(int) onCurrentPageUpdate,
  void Function(ExportingFrontBack) onFrontBackUpdate,
  void Function(int) onTotalPageUpdate,
) async {
  final bool frontSideOnly = frontSideOnlyIncludes(includeItems);
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
      directory,
      settings.prefix,
      settings.template,
      settings.frontSuffix,
      settings.backSuffix,
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
      directory,
      settings.prefix,
      settings.template,
      settings.frontSuffix,
      settings.backSuffix,
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
    String prefix,
    String template,
    String frontSuffix,
    String backSuffix,
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

  // Replace placeholders in the template
  final fileName = template
      .replaceAll("{prefix}", "export")
      .replaceAll("{page}", (pageNumber + 1).toString())
      .replaceAll("{side}", back ? backSuffix : frontSuffix);

  final imageUint = await createImageBytesFromWidget(
      flutterView, toRender, pixelWidth, pixelHeight);
  await savePng(imageUint, directory, fileName);
}

Future<ExportSettings?> openPreExportDialog(
    BuildContext context, bool frontSideOnly) async {
  String tempPrefix = "export";
  String tempTemplate = "{prefix}_{page}_{side}";
  String tempFrontSuffix = "A";
  String tempBackSuffix = "B";

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
  // print(
  //     "Third render took ${finish3.millisecondsSinceEpoch - start3.millisecondsSinceEpoch} ms");
  return uint8List;
}
