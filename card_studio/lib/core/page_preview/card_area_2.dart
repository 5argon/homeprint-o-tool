import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:card_studio/core/card.dart';
import 'package:card_studio/page/layout/layout_struct.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../../page/layout/layout_helper.dart';
import 'parallel_guide.dart';

class ImagePainter extends CustomPainter {
  final ui.Image image;

  ImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, const Offset(0, 0), Paint());
  }

  @override
  bool shouldRepaint(ImagePainter oldDelegate) {
    return false;
  }
}

class CardAreaV2 extends StatelessWidget {
  CardAreaV2({
    super.key,
    required this.horizontalSpace,
    required this.verticalSpace,
    required this.baseDirectory,
    required this.card,
    required this.cardSize,
    required this.layoutMode,
    required this.previewCutLine,
  }) {
    final card = this.card;
    final baseDirectory = this.baseDirectory;
    if (card != null && baseDirectory != null) {
      final f = File(p.join(baseDirectory, card.relativeFilePath));
      loadImageFuture = loadImage(f);
      _getDescriptorFuture = getDescriptor(f);
      fileObject = f;
    } else {
      _getDescriptorFuture = Future.value();
    }
  }

  /// If no graphic this completes immediately, if with graphic you can check
  /// if they are loaded yet here.
  Future<ImageDescriptor?>? _getDescriptorFuture;
  Future<ui.Image>? loadImageFuture;

  File? fileObject;

  /// Card is centered in this area. It takes this much space horizontally. (Max 1.0)
  final double horizontalSpace;

  /// Card is centered in this area. It takes this much space vertically. (Max 1.0)
  final double verticalSpace;
  final String? baseDirectory;
  final CardEachSingle? card;
  final SizePhysical cardSize;
  final bool layoutMode;
  final bool previewCutLine;

  Future<ImageDescriptor> getDescriptor(File loadedFile) async {
    final bytes = await loadedFile.readAsBytes();
    final buff = await ImmutableBuffer.fromUint8List(bytes);
    final descriptor = await ImageDescriptor.encoded(buff);
    return descriptor;
  }

  Future waitForLoad(BuildContext context) async {
    final begin = DateTime.timestamp();
    await _getDescriptorFuture;
    await loadImageFuture;
    final end = DateTime.timestamp();
    print(
        "${card?.relativeFilePath ?? ""} Load took ${end.millisecondsSinceEpoch - begin.millisecondsSinceEpoch} ms");
    return;

    final fileObject = this.fileObject;
    if (fileObject != null) {
      final fileImageProvider = FileImage(fileObject);
      final begin = DateTime.timestamp();
      await precacheImage(
        fileImageProvider,
        context,
        onError: (exception, stackTrace) {
          print("Error loading image: $exception");
        },
      );
      final end = DateTime.timestamp();
      print(
          "${card?.relativeFilePath ?? ""} Precache took ${end.millisecondsSinceEpoch - begin.millisecondsSinceEpoch} ms");
    }
    await _getDescriptorFuture;
  }

  Future<ui.Image> loadImage(File file) async {
    // final fileImage = FileImage(file);
    final Completer<ui.Image> completer = Completer();
    final fileBytes = await file.readAsBytes();
    ui.decodeImageFromList(fileBytes, (ui.Image img) {
      // setState(() {
      //   isImageloaded = true;
      // });
      return completer.complete(img);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = Container();
    if (card != null && baseDirectory != null) {
      // final renderChild =
      //     Image.file(File(p.join(baseDirectory, card.relativeFilePath)));
      // imageWidget = Cropper(cropRect: cropRect, renderChild: renderChild);
      final fileObject = this.fileObject;
      final card = this.card;
      if (fileObject != null && card != null) {
        imageWidget = FutureBuilder(
            builder: (context, snapshot) {
              final descriptorData = snapshot.data;
              if (descriptorData == null) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return LayoutBuilder(
                builder: (context, constraints) {
                  final expand = card.contentExpand;

                  final rotated = card.rotation == Rotation.clockwise90 ||
                      card.rotation == Rotation.counterClockwise90;

                  final parentWidth = constraints.maxWidth;
                  final imageWidth =
                      rotated ? descriptorData.height : descriptorData.width;
                  final contentWidth = parentWidth * horizontalSpace;
                  final widthFitScale = (imageWidth / contentWidth);

                  final parentHeight = constraints.maxHeight;
                  final imageHeight =
                      rotated ? descriptorData.width : descriptorData.height;
                  final contentHeight = parentHeight * verticalSpace;
                  final heightFitScale = (imageHeight / contentHeight);

                  final widthAfterHeightFit = heightFitScale / contentWidth;
                  // If not, then the opposite must be true.
                  final focusWidth = widthAfterHeightFit >= contentWidth;

                  double finalScale;
                  if (focusWidth) {
                    finalScale = widthFitScale * expand;
                  } else {
                    finalScale = heightFitScale * expand;
                  }

                  final imageFileWidget = Image.file(
                    fileObject,
                    alignment: card.contentCenterOffset * finalScale,
                    scale: finalScale,
                    fit: BoxFit.none,
                  );

                  int turns;
                  switch (card.rotation) {
                    case Rotation.none:
                      turns = 0;
                      break;
                    case Rotation.clockwise90:
                      turns = 1;
                      break;
                    case Rotation.counterClockwise90:
                      turns = 3;
                      break;
                  }

                  return FutureBuilder(
                      builder: (context, snapshot) {
                        final image = snapshot.data;
                        if (image == null) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return RotatedBox(
                          quarterTurns: turns,
                          child: SizedBox(
                            height: double.infinity,
                            width: double.infinity,
                            child: CustomPaint(
                              painter: ImagePainter(image),
                            ),
                          ),
                        );
                      },
                      future: loadImageFuture);

                  return RotatedBox(
                    quarterTurns: turns,
                    child: SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: imageFileWidget,
                    ),
                  );
                },
              );
            },
            future: _getDescriptorFuture);
      }
    }
    Widget verticalGuide = Container();
    Widget horizontalGuide = Container();
    if (previewCutLine) {
      verticalGuide = ParallelGuide(
        spaceTaken: horizontalSpace,
        axis: Axis.vertical,
        color: Colors.red,
      );
      horizontalGuide = ParallelGuide(
        spaceTaken: verticalSpace,
        axis: Axis.horizontal,
        color: Colors.red,
      );
    }
    Widget eachCardFrame = Container();
    if (layoutMode) {
      eachCardFrame = Container(
        decoration: BoxDecoration(
            border: Border.all(
                color: Colors.purple,
                strokeAlign: BorderSide.strokeAlignCenter)),
      );
    }
    List<Widget> stackChildren = [
      LayoutHelper(color: Colors.orange, visible: layoutMode, flashing: false),
      eachCardFrame,
      imageWidget,
      verticalGuide,
      horizontalGuide
    ];
    return Stack(
      children: stackChildren,
    );
  }
}
