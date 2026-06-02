import 'dart:io';
import 'dart:ui' as ui;

import 'package:homeprint_o_tool/core/json.dart';
import 'package:homeprint_o_tool/core/card_face.dart';
import 'package:homeprint_o_tool/core/page_preview/corner_paint.dart';
import 'package:homeprint_o_tool/core/page_preview/cut_guide_style.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/page/layout/back_arrangement.dart';
import 'package:homeprint_o_tool/page/layout/layout_data.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'package:homeprint_o_tool/page/layout/layout_helper.dart';
import 'package:homeprint_o_tool/core/page_preview/parallel_guide.dart';
import 'package:homeprint_o_tool/core/page_preview/mirrored_bleed_builder.dart';

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
    required this.cutGuideStyle,
    required this.showVerticalInnerCutLine,
    required this.showHorizontalInnerCutLine,
    required this.back,
    required this.backArrangement,
    required this.layoutData,
    this.preloadedImages,
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
  final CutGuideStyle cutGuideStyle;
  final bool showVerticalInnerCutLine;
  final bool showHorizontalInnerCutLine;
  final bool back;
  final BackArrangement backArrangement;
  final LayoutData layoutData;

  /// Pre-decoded images keyed by card relative file path. When non-null this
  /// widget is in "export mode": it paints the card image synchronously with
  /// [RawImage] from the already-decoded `ui.Image`, instead of the
  /// asynchronous `Image.file`/`FutureBuilder` path used for the live preview.
  ///
  /// This is what makes off-screen export deterministic — there is nothing
  /// asynchronous left to wait for. See `preloadPageImages` in render.dart.
  final Map<String, ui.Image>? preloadedImages;

  @override
  State<CardArea> createState() => _CardAreaState();
}

class _CardAreaState extends State<CardArea> {
  /// If no graphic this completes immediately, if with graphic you can check
  /// if they are loaded yet here. Only used by the interactive (preview) path;
  /// the export path uses [CardArea.preloadedImages] instead.
  Future<ui.ImageDescriptor?>? _getDescriptorFuture;
  File? fileObject;

  Future<ui.ImageDescriptor?> getDescriptor(File loadedFile) async {
    final bytes = await loadedFile.readAsBytes();
    final buff = await ui.ImmutableBuffer.fromUint8List(bytes);
    final descriptor = await ui.ImageDescriptor.encoded(buff);
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

  /// Lays out and composes the card graphic given its intrinsic pixel size and
  /// an [imageBuilder] that knows how to materialise one copy of the image
  /// (async `Image.file` for preview, sync `RawImage` for export).
  ///
  /// All of the fit/expand/rotation math here is identical for both paths and
  /// independent of how big the source image is.
  Widget _composeImage(
    BoxConstraints constraints,
    CardFace card,
    int imageRawWidth,
    int imageRawHeight,
    BleedImageBuilder imageBuilder,
  ) {
    final effectiveRotation = card.useDefaultRotation
        ? widget.projectSettings.defaultRotation
        : card.rotation;
    final rotated = effectiveRotation == Rotation.clockwise90 ||
        effectiveRotation == Rotation.counterClockwise90;

    final parentWidth = constraints.maxWidth;
    final imageWidth = rotated ? imageRawHeight : imageRawWidth;
    final contentWidth = parentWidth * widget.horizontalSpace;
    final widthFitScale = (imageWidth / contentWidth);

    final parentHeight = constraints.maxHeight;
    final imageHeight = rotated ? imageRawWidth : imageRawHeight;
    final contentHeight = parentHeight * widget.verticalSpace;
    final heightFitScale = (imageHeight / contentHeight);

    // Scale the image to *cover* the content cell, then apply the content
    // expand. `contentExpand == 1.0` is defined as growing from
    // contentCenterOffset until one side of the card's shape touches an edge,
    // which is exactly the smaller of the two fit-scales (a smaller scale yields
    // a larger displayed image). Being a pure ratio of dimensions, this is
    // independent of the render resolution, so preview and export agree.
    final originalExpand = card.effectiveContentExpand(widget.projectSettings);
    final coverScale =
        widthFitScale < heightFitScale ? widthFitScale : heightFitScale;
    final finalScale = coverScale * originalExpand;

    final imageFileWidget = imageBuilder(
      alignment: card.contentCenterOffset * finalScale,
      scale: finalScale,
    );

    Widget finalImageWidget;
    if (widget.layoutData.bleedSettings == BleedSettings.extended) {
      finalImageWidget = buildMirroredBleedWidget(
        centerImageWidget: imageFileWidget,
        imageBuilder: imageBuilder,
        parentWidth: parentWidth,
        parentHeight: parentHeight,
        contentWidth: contentWidth,
        contentHeight: contentHeight,
        imageWidth: imageWidth.toDouble(),
        imageHeight: imageHeight.toDouble(),
        finalScale: finalScale,
        generatedBleedLimitPercentage:
            widget.layoutData.generatedBleedPercentage,
      );
    } else if (widget.layoutData.bleedSettings == BleedSettings.cropped) {
      finalImageWidget = Center(
        child: ClipRect(
          child: SizedBox(
            width: contentWidth,
            height: contentHeight,
            child: imageFileWidget,
          ),
        ),
      );
    } else {
      finalImageWidget = imageFileWidget;
    }

    int turns;
    switch (effectiveRotation) {
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
        effectiveRotation != Rotation.none) {
      turns = turns + 2;
    }

    return RotatedBox(
      quarterTurns: turns,
      child: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: widget.cutGuideStyle == CutGuideStyle.cutCorners
            ? CustomPaint(
                foregroundPainter: CornerPainter(
                  guideHorizontal: widget.guideHorizontal,
                  guideVertical: widget.guideVertical,
                  color: Colors.red,
                  strokeWidth: 2.0,
                  cornerLength: 10,
                ),
                child: finalImageWidget)
            : finalImageWidget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = Container();
    final card = widget.card;
    final baseDirectory = widget.baseDirectory;
    final preloadedImages = widget.preloadedImages;

    if (card != null && baseDirectory != null) {
      if (preloadedImages != null) {
        // Export mode: everything is already decoded, so paint synchronously.
        final ui.Image? decoded = preloadedImages[card.relativeFilePath];
        if (decoded == null) {
          // Missing / undecodable graphic — same red placeholder as preview.
          return Placeholder(color: Colors.red);
        }
        imageWidget = LayoutBuilder(
          builder: (context, constraints) {
            return _composeImage(
              constraints,
              card,
              decoded.width,
              decoded.height,
              ({required alignment, required scale, width, height}) => RawImage(
                // Each RawImage's RenderImage takes ownership of the image it is
                // given, so hand every copy its own clone. The master images in
                // [preloadedImages] are disposed by the caller after capture.
                image: decoded.clone(),
                alignment: alignment,
                scale: scale,
                width: width,
                height: height,
                fit: BoxFit.none,
              ),
            );
          },
        );
      } else {
        // Preview mode: asynchronous load (unchanged behaviour).
        if (_getDescriptorFuture == null) {
          return Placeholder(color: Colors.red);
        }
        final fileObject = this.fileObject;
        if (fileObject != null) {
          imageWidget = FutureBuilder<ui.ImageDescriptor?>(
            future: _getDescriptorFuture,
            builder: (context, snapshot) {
              final descriptorData = snapshot.data;
              if (descriptorData == null) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return LayoutBuilder(
                builder: (context, constraints) {
                  return _composeImage(
                    constraints,
                    card,
                    descriptorData.width,
                    descriptorData.height,
                    ({required alignment, required scale, width, height}) =>
                        Image.file(
                      fileObject,
                      alignment: alignment,
                      scale: scale,
                      width: width,
                      height: height,
                      fit: BoxFit.none,
                    ),
                  );
                },
              );
            },
          );
        }
      }
    }
    Widget verticalGuide = Container();
    Widget horizontalGuide = Container();
    Widget verticalGuideUnder = Container();
    Widget horizontalGuideUnder = Container();
    Color previewColor = Colors.red;
    Color realColor = Color.fromARGB(60, 255, 255, 255);
    Color underColor = Colors.black;

    bool showCutLines = widget.cutGuideStyle == CutGuideStyle.cutLine;

    if (showCutLines || widget.showVerticalInnerCutLine) {
      verticalGuide = ParallelGuide(
        spaceTaken: widget.guideHorizontal,
        axis: Axis.vertical,
        color: showCutLines ? previewColor : realColor,
      );
    }
    if (showCutLines || widget.showHorizontalInnerCutLine) {
      horizontalGuide = ParallelGuide(
        spaceTaken: widget.guideVertical,
        axis: Axis.horizontal,
        color: showCutLines ? previewColor : realColor,
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
    final doNotShowGuideUnder =
        card?.effectiveContentExpand(widget.projectSettings) == 1;
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
      doNotShowGuideUnder ? Container() : verticalGuideUnder,
      doNotShowGuideUnder ? Container() : horizontalGuideUnder,
      imageWidget,
      verticalGuide,
      horizontalGuide
    ];
    return Stack(
      children: stackChildren,
    );
  }
}
