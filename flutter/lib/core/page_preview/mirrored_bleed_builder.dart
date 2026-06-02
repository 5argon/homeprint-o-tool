import 'package:flutter/material.dart';

/// Signature for lazily building one copy of the card image — either the center
/// image or a single mirrored bleed piece — at a given [alignment]/[scale] and
/// optional [width]/[height].
///
/// This indirection lets the exact same bleed layout drive two backends:
///   * an asynchronous `Image.file` for the interactive on-screen preview, and
///   * a synchronous `RawImage` backed by a pre-decoded `ui.Image` for the
///     deterministic export renderer.
typedef BleedImageBuilder = Widget Function({
  required Alignment alignment,
  required double scale,
  double? width,
  double? height,
});

/// Builds a widget with mirrored bleeds around the edges.
///
/// This creates mirrored copies of the image edges to fill margin areas,
/// providing a bleed effect for printing.
Widget buildMirroredBleedWidget({
  required Widget centerImageWidget,
  required BleedImageBuilder imageBuilder,
  required double parentWidth,
  required double parentHeight,
  required double contentWidth,
  required double contentHeight,
  required double imageWidth,
  required double imageHeight,
  required double finalScale,
  required double generatedBleedLimitPercentage,
}) {
  final scaledImageWidth = imageWidth / finalScale;
  final leftRightBleed = (scaledImageWidth - contentWidth) / 2;
  final topBottomBleed = (imageHeight / finalScale - contentHeight) / 2;
  final whiteFromLeftEdge = (parentWidth - contentWidth) / 2;
  final whiteFromTopEdge = (parentHeight - contentHeight) / 2;
  final topMargin = (parentHeight - contentHeight) / 2;
  final bottomMargin = (parentHeight - contentHeight) / 2;
  final leftMargin = (parentWidth - contentWidth) / 2;
  final rightMargin = (parentWidth - contentWidth) / 2;

  // Clamp bleeds to not exceed available margin space
  final effectiveLeftRightBleed = leftRightBleed.clamp(0.0, leftMargin);
  final effectiveTopBottomBleed = topBottomBleed.clamp(0.0, topMargin);

  final topPiece = (topMargin <= 0)
      ? Container()
      : Positioned(
          left: whiteFromLeftEdge - effectiveLeftRightBleed,
          top: (topMargin - effectiveTopBottomBleed) *
              (1 - generatedBleedLimitPercentage),
          width: contentWidth + (effectiveLeftRightBleed * 2),
          height: (topMargin - effectiveTopBottomBleed) *
              generatedBleedLimitPercentage,
          child: Stack(
            children: [
              Transform(
                transform: Matrix4.identity()..scale(1.0, -1.0),
                alignment: Alignment.center,
                child: imageBuilder(
                  alignment: Alignment.topCenter,
                  scale: finalScale,
                  width: parentWidth,
                  height: parentHeight,
                ),
              ),
            ],
          ),
        );

  final bottomPiece = (bottomMargin <= 0)
      ? Container()
      : Positioned(
          left: whiteFromLeftEdge - effectiveLeftRightBleed,
          bottom: (bottomMargin - effectiveTopBottomBleed) *
              (1 - generatedBleedLimitPercentage),
          width: contentWidth + (effectiveLeftRightBleed * 2),
          height: (bottomMargin - effectiveTopBottomBleed) *
              generatedBleedLimitPercentage,
          child: Stack(
            children: [
              Transform(
                transform: Matrix4.identity()..scale(1.0, -1.0),
                alignment: Alignment.center,
                child: imageBuilder(
                  alignment: Alignment.bottomCenter,
                  scale: finalScale,
                  width: parentWidth,
                  height: parentHeight,
                ),
              ),
            ],
          ),
        );

  final rightPiece = (rightMargin <= 0)
      ? Container()
      : Positioned(
          right: (rightMargin - effectiveLeftRightBleed) *
              (1 - generatedBleedLimitPercentage),
          top: whiteFromTopEdge - effectiveTopBottomBleed,
          width: (rightMargin - effectiveLeftRightBleed) *
              generatedBleedLimitPercentage,
          height: contentHeight + (effectiveTopBottomBleed * 2),
          child: Stack(
            children: [
              Transform(
                transform: Matrix4.identity()..scale(-1.0, 1.0),
                alignment: Alignment.center,
                child: imageBuilder(
                  alignment: Alignment.centerRight,
                  scale: finalScale,
                  width: parentWidth,
                  height: parentHeight,
                ),
              ),
            ],
          ),
        );

  final leftPiece = (leftMargin <= 0)
      ? Container()
      : Positioned(
          left: (leftMargin - effectiveLeftRightBleed) *
              (1 - generatedBleedLimitPercentage),
          top: whiteFromTopEdge - effectiveTopBottomBleed,
          width: (leftMargin - effectiveLeftRightBleed) *
              generatedBleedLimitPercentage,
          height: contentHeight + (effectiveTopBottomBleed * 2),
          child: Stack(
            children: [
              Transform(
                transform: Matrix4.identity()..scale(-1.0, 1.0),
                alignment: Alignment.center,
                child: imageBuilder(
                  alignment: Alignment.centerLeft,
                  scale: finalScale,
                  width: parentWidth,
                  height: parentHeight,
                ),
              ),
            ],
          ),
        );

  final topLeftPiece = (topMargin <= 0 || leftMargin <= 0)
      ? Container()
      : Positioned(
          left: (leftMargin - effectiveLeftRightBleed) *
              (1 - generatedBleedLimitPercentage),
          top: (topMargin - effectiveTopBottomBleed) *
              (1 - generatedBleedLimitPercentage),
          width: (leftMargin - effectiveLeftRightBleed) *
              generatedBleedLimitPercentage,
          height: (topMargin - effectiveTopBottomBleed) *
              generatedBleedLimitPercentage,
          child: Stack(
            children: [
              Transform(
                transform: Matrix4.identity()..scale(-1.0, -1.0),
                alignment: Alignment.center,
                child: imageBuilder(
                  alignment: Alignment.topLeft,
                  scale: finalScale,
                  width: parentWidth,
                  height: parentHeight,
                ),
              ),
            ],
          ),
        );

  final topRightPiece = (topMargin <= 0 || rightMargin <= 0)
      ? Container()
      : Positioned(
          right: (rightMargin - effectiveLeftRightBleed) *
              (1 - generatedBleedLimitPercentage),
          top: (topMargin - effectiveTopBottomBleed) *
              (1 - generatedBleedLimitPercentage),
          width: (rightMargin - effectiveLeftRightBleed) *
              generatedBleedLimitPercentage,
          height: (topMargin - effectiveTopBottomBleed) *
              generatedBleedLimitPercentage,
          child: Stack(
            children: [
              Transform(
                transform: Matrix4.identity()..scale(-1.0, -1.0),
                alignment: Alignment.center,
                child: imageBuilder(
                  alignment: Alignment.topRight,
                  scale: finalScale,
                  width: parentWidth,
                  height: parentHeight,
                ),
              ),
            ],
          ),
        );

  final bottomLeftPiece = (bottomMargin <= 0 || leftMargin <= 0)
      ? Container()
      : Positioned(
          left: (leftMargin - effectiveLeftRightBleed) *
              (1 - generatedBleedLimitPercentage),
          bottom: (bottomMargin - effectiveTopBottomBleed) *
              (1 - generatedBleedLimitPercentage),
          width: (leftMargin - effectiveLeftRightBleed) *
              generatedBleedLimitPercentage,
          height: (bottomMargin - effectiveTopBottomBleed) *
              generatedBleedLimitPercentage,
          child: Stack(
            children: [
              Transform(
                transform: Matrix4.identity()..scale(-1.0, -1.0),
                alignment: Alignment.center,
                child: imageBuilder(
                  alignment: Alignment.bottomLeft,
                  scale: finalScale,
                  width: parentWidth,
                  height: parentHeight,
                ),
              ),
            ],
          ),
        );

  final bottomRightPiece = (bottomMargin <= 0 || rightMargin <= 0)
      ? Container()
      : Positioned(
          right: (rightMargin - effectiveLeftRightBleed) *
              (1 - generatedBleedLimitPercentage),
          bottom: (bottomMargin - effectiveTopBottomBleed) *
              (1 - generatedBleedLimitPercentage),
          width: (rightMargin - effectiveLeftRightBleed) *
              generatedBleedLimitPercentage,
          height: (bottomMargin - effectiveTopBottomBleed) *
              generatedBleedLimitPercentage,
          child: Stack(
            children: [
              Transform(
                transform: Matrix4.identity()..scale(-1.0, -1.0),
                alignment: Alignment.center,
                child: imageBuilder(
                  alignment: Alignment.bottomRight,
                  scale: finalScale,
                  width: parentWidth,
                  height: parentHeight,
                ),
              ),
            ],
          ),
        );

  return Stack(
    fit: StackFit.expand,
    clipBehavior: Clip.none,
    children: [
      topPiece,
      bottomPiece,
      rightPiece,
      leftPiece,
      topLeftPiece,
      topRightPiece,
      bottomLeftPiece,
      bottomRightPiece,
      centerImageWidget,
    ],
  );
}
