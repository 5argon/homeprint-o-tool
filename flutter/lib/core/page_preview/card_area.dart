import 'dart:io';
import 'dart:ui';

import 'package:homeprint_o_tool/core/json.dart';
import 'package:homeprint_o_tool/core/card_face.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/page/layout/back_arrangement.dart';
import 'package:homeprint_o_tool/page/layout/layout_data.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'package:homeprint_o_tool/page/layout/layout_helper.dart';
import 'package:homeprint_o_tool/core/page_preview/parallel_guide.dart';

class CardArea extends StatefulWidget {
  CardArea({
    super.key,
    required this.horizontalSpace,
    required this.verticalSpace,
    required this.guideHorizontal,
    required this.guideVertical,
    required this.baseDirectory,
    required this.projectSettings,
    required this.card,
    required this.cardSize,
    required this.layoutMode,
    required this.previewCutLine,
    required this.showVerticalInnerCutLine,
    required this.showHorizontalInnerCutLine,
    required this.back,
    required this.backArrangement,
  });

  /// Card is centered in this area. It takes this much space horizontally. (Max 1.0)
  final double horizontalSpace;

  /// Card is centered in this area. It takes this much space vertically. (Max 1.0)
  final double verticalSpace;

  final double guideHorizontal;
  final double guideVertical;

  final String? baseDirectory;
  final ProjectSettings projectSettings;
  final CardFace? card;
  final SizePhysical cardSize;
  final bool layoutMode;
  final bool previewCutLine;
  final bool showVerticalInnerCutLine;
  final bool showHorizontalInnerCutLine;
  final bool back;
  final BackArrangement backArrangement;

  @override
  State<CardArea> createState() => _CardAreaState();
}

class _CardAreaState extends State<CardArea> {
  /// If no graphic this completes immediately, if with graphic you can check
  /// if they are loaded yet here.
  Future<ImageDescriptor?>? _getDescriptorFuture;
  File? fileObject;

  Future<ImageDescriptor?> getDescriptor(File loadedFile) async {
    final bytes = await loadedFile.readAsBytes();
    final buff = await ImmutableBuffer.fromUint8List(bytes);
    final descriptor = await ImageDescriptor.encoded(buff);
    return descriptor;
  }

  @override
  void initState() {
    super.initState();
    final card = widget.card;
    final baseDirectory = widget.baseDirectory;
    if (card != null && baseDirectory != null) {
      final f = File(p.join(baseDirectory, card.relativeFilePath));
      if (f.existsSync()) {
        _getDescriptorFuture = getDescriptor(f);
        fileObject = f;
      } else {
        // Shows missing image warning.
        _getDescriptorFuture = null;
        fileObject = null;
      }
    } else {
      // Shows white.
      _getDescriptorFuture = Future.value();
      fileObject = null;
    }
  }

  @override
  void didUpdateWidget(covariant CardArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    final card = widget.card;
    final baseDirectory = widget.baseDirectory;
    if (card != null && baseDirectory != null) {
      final f = File(p.join(baseDirectory, card.relativeFilePath));
      if (f.existsSync()) {
        _getDescriptorFuture = getDescriptor(f);
        fileObject = f;
      } else {
        _getDescriptorFuture = null;
        fileObject = null;
      }
    } else {
      _getDescriptorFuture = Future.value();
      fileObject = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_getDescriptorFuture == null) {
      return Placeholder(
        color: Colors.red,
      );
    }
    Widget imageWidget = Container();
    if (widget.card != null && widget.baseDirectory != null) {
      // final renderChild =
      //     Image.file(File(p.join(baseDirectory, card.relativeFilePath)));
      // imageWidget = Cropper(cropRect: cropRect, renderChild: renderChild);
      final card = widget.card;
      final fileObject = this.fileObject;
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
                  final contentWidth = parentWidth * widget.horizontalSpace;
                  final widthFitScale = (imageWidth / contentWidth);

                  final parentHeight = constraints.maxHeight;
                  final imageHeight =
                      rotated ? descriptorData.width : descriptorData.height;
                  final contentHeight = parentHeight * widget.verticalSpace;
                  final heightFitScale = (imageHeight / contentHeight);

                  final widthAfterHeightFit = heightFitScale * contentWidth;
                  // If not, then the opposite must be true.
                  final focusWidth = widthAfterHeightFit >= contentWidth;

                  // This expand was relative to the image's dimension.
                  // Card Area dimension might turns out to be different shape depending on margin settings.
                  final originalExpand =
                      card.effectiveContentExpand(widget.projectSettings);

                  final cardWidth = widget.cardSize.widthCm;
                  final cardHeight = widget.cardSize.heightCm;
                  final heightFitScaleCardToImage = (imageHeight / cardHeight);
                  final widthFitScaleCardToImage = (imageWidth / cardWidth);

                  // Check
                  final widthAfterHeightFit2 =
                      heightFitScaleCardToImage * widget.cardSize.widthCm;
                  final heightAfterWidthFit2 =
                      widthFitScaleCardToImage * widget.cardSize.heightCm;
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
                  if (widget.back &&
                      widget.backArrangement == BackArrangement.invertedRow &&
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
    Widget verticalGuideUnder = Container();
    Widget horizontalGuideUnder = Container();
    Color previewColor = Colors.red;
    Color realColor = Color.fromARGB(60, 255, 255, 255);
    Color underColor = Colors.black;

    if (widget.previewCutLine || widget.showVerticalInnerCutLine) {
      verticalGuide = ParallelGuide(
        spaceTaken: widget.guideHorizontal,
        axis: Axis.vertical,
        color: widget.previewCutLine ? previewColor : realColor,
      );
    }
    if (widget.previewCutLine || widget.showHorizontalInnerCutLine) {
      horizontalGuide = ParallelGuide(
        spaceTaken: widget.guideVertical,
        axis: Axis.horizontal,
        color: widget.previewCutLine ? previewColor : realColor,
      );
    }
    horizontalGuideUnder = ParallelGuide(
      spaceTaken: widget.guideVertical,
      axis: Axis.horizontal,
      color: underColor,
    );
    verticalGuideUnder = ParallelGuide(
      spaceTaken: widget.guideHorizontal,
      axis: Axis.vertical,
      color: underColor,
    );
    Widget eachCardFrame = Container();
    if (widget.layoutMode) {
      eachCardFrame = Container(
        decoration: BoxDecoration(
            border: Border.all(
                color: Colors.purple,
                strokeAlign: BorderSide.strokeAlignCenter)),
      );
    }
    List<Widget> stackChildren = [
      LayoutHelper(
          color: Colors.orange, visible: widget.layoutMode, flashing: false),
      eachCardFrame,
      verticalGuideUnder,
      horizontalGuideUnder,
      imageWidget,
      verticalGuide,
      horizontalGuide
    ];
    return Stack(
      children: stackChildren,
    );
  }
}
