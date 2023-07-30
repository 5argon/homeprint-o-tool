import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'output_layout_control.dart';
import 'page_preview.dart';
import 'dart:ui' as ui;

/// Creates an image from the given widget by first spinning up a element and render tree,
/// then waiting for the given [wait] amount of time and then creating an image via a [RepaintBoundary].
///
/// The final image will be of size [imageSize] and the the widget will be layout, ... with the given [logicalSize].
Future<Uint8List> createImageFromWidget(BuildContext context, Widget widget,
    {Duration? wait, Size? logicalSize, Size? imageSize}) async {
  final flutterView = View.of(context);
  final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
  logicalSize ??= flutterView.physicalSize / flutterView.devicePixelRatio;
  imageSize ??= flutterView.physicalSize;

  assert(logicalSize.aspectRatio == imageSize.aspectRatio);

  final RenderView renderView = RenderView(
    view: flutterView,
    child: RenderPositionedBox(
        alignment: Alignment.center, child: repaintBoundary),
    configuration: ViewConfiguration(
      size: logicalSize,
      devicePixelRatio: 1.0,
    ),
  );

  final PipelineOwner pipelineOwner = PipelineOwner();
  final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

  pipelineOwner.rootNode = renderView;
  renderView.prepareInitialFrame();

  final RenderObjectToWidgetElement<RenderBox> rootElement =
      RenderObjectToWidgetAdapter<RenderBox>(
    container: repaintBoundary,
    child: widget,
  ).attachToRenderTree(buildOwner);

  buildOwner.buildScope(rootElement);

  if (wait != null) {
    await Future.delayed(wait);
  }

  buildOwner.buildScope(rootElement);
  buildOwner.finalizeTree();

  pipelineOwner.flushLayout();
  pipelineOwner.flushCompositingBits();
  pipelineOwner.flushPaint();

  final ui.Image image = await repaintBoundary.toImage(
      pixelRatio: imageSize.width / logicalSize.width);
  final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);

  return byteData!.buffer.asUint8List();
}

Future saveImageFile(Uint8List imageData) async {
  String? outputFile = await FilePicker.platform.saveFile(
    dialogTitle: 'Please select an output file:',
    allowedExtensions: ['png'],
    fileName: "export.png",
  );
  if (outputFile != null) {
    await File(outputFile).writeAsBytes(imageData);
  }
}

Future<Uint8List> createImageFromWidget2(BuildContext context, Widget widget) {
  final flutterView = View.of(context);
  final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
  final RenderView renderView = RenderView(
    view: flutterView,
    child: RenderPositionedBox(
        alignment: Alignment.center, child: repaintBoundary),
    configuration: ViewConfiguration(
        size: const Size.square(300.0),
        devicePixelRatio: flutterView.devicePixelRatio),
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

class LayoutPage extends StatelessWidget {
  const LayoutPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    GlobalKey testKeyLeft = GlobalKey();
    GlobalKey testKeyRight = GlobalKey();
    var textTheme = Theme.of(context).textTheme;
    var lrPreviewPadding = 8.0;
    var leftSide = Padding(
      padding: EdgeInsets.all(lrPreviewPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: PagePreview(
                SizeWidthHeight(21, 29.7),
                SizeWidthHeight(6.3, 8.8),
                SizeWidthHeight(0.3, 0.3),
                SizeWidthHeight(0.7, 0.7),
                0.5,
                0.02,
                [],
                globalKey: testKeyLeft),
          ),
          SizedBox(height: 4),
          Text(
            "Front",
            style: textTheme.labelSmall,
          )
        ],
      ),
    );

    var rightSide = Padding(
      padding: EdgeInsets.all(lrPreviewPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: PagePreview(
                SizeWidthHeight(21, 29.7),
                SizeWidthHeight(6.3, 8.8),
                SizeWidthHeight(0.3, 0.3),
                SizeWidthHeight(0.7, 0.7),
                0.5,
                0.02,
                [],
                globalKey: testKeyRight),
          ),
          SizedBox(height: 4),
          Text(
            "Front",
            style: textTheme.labelSmall,
          )
        ],
      ),
    );

    var dualPreviewRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: leftSide,
        ),
        Flexible(
          child: rightSide,
        ),
      ],
    );

    return Column(
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          child: SizedBox(
            height: 500,
            child: Column(
              children: [
                Expanded(
                  child: dualPreviewRow,
                ),
                SizedBox(
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              final imageUint = await createImageFromWidget2(
                                  context, leftSide);
                              await saveImageFile(imageUint);
                            },
                            child: Text("Print")),
                        SegmentedButton(
                          segments: [
                            ButtonSegment(value: 0, label: Text("Dual")),
                            ButtonSegment(value: 1, label: Text("Front")),
                            ButtonSegment(value: 2, label: Text("Back")),
                          ],
                          selected: {0},
                          onSelectionChanged: (p0) {
                            print("do something");
                          },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Flexible(child: OutputLayoutControl())
      ],
    );
  }
}
