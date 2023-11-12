import 'dart:io';
import 'dart:ui';

import 'package:card_studio/core/card.dart';
import 'package:card_studio/page/layout/back_strategy.dart';
import 'package:card_studio/page/layout/layout_struct.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../page/layout/layout_helper.dart';
import 'parallel_guide.dart';

class CardArea extends StatelessWidget {
  CardArea({
    super.key,
    required this.horizontalSpace,
    required this.verticalSpace,
    required this.baseDirectory,
    required this.card,
    required this.cardSize,
    required this.layoutMode,
    required this.previewCutLine,
    required this.showVerticalInnerCutLine,
    required this.showHorizontalInnerCutLine,
    required this.back,
    required this.backStrategy,
  }) {
    final card = this.card;
    final baseDirectory = this.baseDirectory;
    if (card != null && baseDirectory != null) {
      final f = File(p.join(baseDirectory, card.relativeFilePath));
      _getDescriptorFuture = getDescriptor(f);
      fileObject = f;
    } else {
      _getDescriptorFuture = Future.value();
    }
  }

  /// If no graphic this completes immediately, if with graphic you can check
  /// if they are loaded yet here.
  Future<ImageDescriptor?>? _getDescriptorFuture;
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
  final bool showVerticalInnerCutLine;
  final bool showHorizontalInnerCutLine;
  final bool back;
  final BackStrategy backStrategy;

  Future<ImageDescriptor?> getDescriptor(File loadedFile) async {
    final bytes = await loadedFile.readAsBytes();
    final buff = await ImmutableBuffer.fromUint8List(bytes);
    final descriptor = await ImageDescriptor.encoded(buff);
    return descriptor;
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

                  final widthAfterHeightFit = heightFitScale * contentWidth;
                  // If not, then the opposite must be true.
                  final focusWidth = widthAfterHeightFit >= contentWidth;

                  // This expand was relative to the image's dimension.
                  // Card Area dimension might turns out to be different shape depending on margin settings.
                  final originalExpand = card.contentExpand;

                  final cardWidth = cardSize.widthCm;
                  final cardHeight = cardSize.heightCm;
                  final heightFitScaleCardToImage = (imageHeight / cardHeight);
                  final widthFitScaleCardToImage = (imageWidth / cardWidth);

                  // Check
                  final widthAfterHeightFit2 =
                      heightFitScaleCardToImage * cardSize.widthCm;
                  final heightAfterWidthFit2 =
                      widthFitScaleCardToImage * cardSize.heightCm;
                  final expandFocusWidth = widthAfterHeightFit2 >= imageWidth;

                  final double effectiveExpand;
                  if (expandFocusWidth != focusWidth) {
                    // Different focus, need to swap expand to the other axis.
                    if (expandFocusWidth) {
                      final scaledDown =
                          heightAfterWidthFit2 * widthFitScaleCardToImage;
                      final newExpand = scaledDown / imageHeight;
                      effectiveExpand = newExpand;
                    } else {
                      final scaledDown = widthAfterHeightFit2 * originalExpand;
                      final newExpand = scaledDown / imageWidth;
                      effectiveExpand = newExpand;
                    }
                  } else {
                    effectiveExpand = originalExpand;
                  }

                  double finalScale;
                  if (focusWidth) {
                    finalScale = widthFitScale * effectiveExpand;
                  } else {
                    finalScale = heightFitScale * effectiveExpand;
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
                  if (back &&
                      backStrategy == BackStrategy.invertedRow &&
                      card.rotation != Rotation.none) {
                    turns = turns + 2;
                  }

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
    Color previewColor = Colors.red;
    Color realColor = Color.fromARGB(60, 255, 255, 255);
    if (previewCutLine || showVerticalInnerCutLine) {
      verticalGuide = ParallelGuide(
        spaceTaken: horizontalSpace,
        axis: Axis.vertical,
        color: previewCutLine ? previewColor : realColor,
      );
    }
    if (previewCutLine || showHorizontalInnerCutLine) {
      horizontalGuide = ParallelGuide(
        spaceTaken: verticalSpace,
        axis: Axis.horizontal,
        color: previewCutLine ? previewColor : realColor,
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
