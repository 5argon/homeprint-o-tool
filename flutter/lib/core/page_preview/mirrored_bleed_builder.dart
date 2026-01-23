import 'dart:io';
import 'package:flutter/material.dart';

/// Builds a widget with mirrored bleeds around the edges.
///
/// This creates mirrored copies of the image edges to fill margin areas,
/// providing a bleed effect for printing.
Widget buildMirroredBleedWidget({
  required Widget centerImageWidget,
  required File imageFile,
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
                child: Image.file(
                  imageFile,
                  alignment: Alignment.topCenter,
                  width: parentWidth,
                  height: parentHeight,
                  scale: finalScale,
                  fit: BoxFit.none,
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
                child: Image.file(
                  imageFile,
                  alignment: Alignment.bottomCenter,
                  width: parentWidth,
                  height: parentHeight,
                  scale: finalScale,
                  fit: BoxFit.none,
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
                child: Image.file(
                  imageFile,
                  alignment: Alignment.centerRight,
                  width: parentWidth,
                  height: parentHeight,
                  scale: finalScale,
                  fit: BoxFit.none,
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
                child: Image.file(
                  imageFile,
                  alignment: Alignment.centerLeft,
                  width: parentWidth,
                  height: parentHeight,
                  scale: finalScale,
                  fit: BoxFit.none,
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
                child: Image.file(
                  imageFile,
                  alignment: Alignment.topLeft,
                  width: parentWidth,
                  height: parentHeight,
                  scale: finalScale,
                  fit: BoxFit.none,
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
                child: Image.file(
                  imageFile,
                  alignment: Alignment.topRight,
                  width: parentWidth,
                  height: parentHeight,
                  scale: finalScale,
                  fit: BoxFit.none,
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
                child: Image.file(
                  imageFile,
                  alignment: Alignment.bottomLeft,
                  width: parentWidth,
                  height: parentHeight,
                  scale: finalScale,
                  fit: BoxFit.none,
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
                child: Image.file(
                  imageFile,
                  alignment: Alignment.bottomRight,
                  width: parentWidth,
                  height: parentHeight,
                  scale: finalScale,
                  fit: BoxFit.none,
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
