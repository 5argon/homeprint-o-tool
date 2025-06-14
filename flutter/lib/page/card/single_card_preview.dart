import 'dart:io';
import 'dart:ui';

import 'package:homeprint_o_tool/core/card_face.dart';
import 'package:homeprint_o_tool/core/components/full_screen_card_preview.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/page/layout/layout_data.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'package:homeprint_o_tool/core/json.dart';

class SingleCardPreview extends StatefulWidget {
  final double bleedFactor;
  final String basePath;
  final SizePhysical cardSize;
  final CardFace? cardFace;
  final Function(double width, double height)? onImageDescriptorLoaded;
  final bool showBorder; // Whether to show the border around the card
  final bool disableClick; // Whether to disable the click to fullscreen feature
  final ProjectSettings projectSettings;

  SingleCardPreview({
    super.key,
    required this.bleedFactor,
    required this.cardSize,
    required this.basePath,
    required this.cardFace,
    required this.projectSettings,
    this.onImageDescriptorLoaded,
    this.showBorder = true,
    this.disableClick = false,
  });

  @override
  State<SingleCardPreview> createState() => _SingleCardPreviewState();
}

class _SingleCardPreviewState extends State<SingleCardPreview> {
  Future<ImageDescriptor>? descriptorFuture;
  late File file;

  Future<ImageDescriptor> getDescriptor(File loadedFile) async {
    final bytes = await loadedFile.readAsBytes();
    final buff = await ImmutableBuffer.fromUint8List(bytes);
    final descriptor = await ImageDescriptor.encoded(buff);

    // Notify parent about image dimensions if callback is provided
    if (widget.onImageDescriptorLoaded != null) {
      widget.onImageDescriptorLoaded!(
          descriptor.width.toDouble(), descriptor.height.toDouble());
    }

    return descriptor;
  }

  @override
  void initState() {
    super.initState();
    final cardFace = widget.cardFace;
    if (cardFace != null) {
      final filePath = cardFace.relativeFilePath;
      file = File(p.join(widget.basePath, filePath));
      if (file.existsSync()) {
        descriptorFuture = getDescriptor(file);
      } else {
        descriptorFuture = null;
      }
    }
  }

  @override
  void didUpdateWidget(covariant SingleCardPreview oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if cardFace has changed or its properties have changed
    final oldCardFace = oldWidget.cardFace;
    final newCardFace = widget.cardFace;
    if (oldCardFace != newCardFace) {
      // Card face has changed, update the file and descriptorFuture
      if (newCardFace != null) {
        final filePath = newCardFace.relativeFilePath;
        file = File(p.join(widget.basePath, filePath));
        if (file.existsSync()) {
          descriptorFuture = getDescriptor(file);
        } else {
          descriptorFuture = null;
        }
      } else {
        descriptorFuture = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardFace = widget.cardFace;
    if (cardFace == null) {
      return Container();
    }

    // Check if descriptorFuture is null (file does not exist)
    if (descriptorFuture == null) {
      return Center(
        child: Placeholder(
          color: Colors.red,
        ),
      );
    }

    return FutureBuilder(
      builder: (context, snapshot) {
        final snapshotData = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshotData == null) {
          // spinner
          return CircularProgressIndicator();
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final imageFileWidth = snapshotData.width;
            final imageFileHeight = snapshotData.height;
            final frameWidth = constraints.maxWidth;
            final frameHeight = constraints.maxHeight;

            double cardShapeWidth;
            double cardShapeHeight;
            final effectiveRotation = cardFace.useDefaultRotation
                ? widget.projectSettings.defaultRotation
                : cardFace.rotation;

            if (effectiveRotation == Rotation.none) {
              cardShapeWidth = widget.cardSize.widthCm;
              cardShapeHeight = widget.cardSize.heightCm;
            } else {
              cardShapeWidth = widget.cardSize.heightCm;
              cardShapeHeight = widget.cardSize.widthCm;
            }

            // The Image widget always fit the frame, but we need to simulate
            // an another rectangle that fits inside the Image widget at 100%, and
            // not fitting if percentage is different.

            // Test if card shape expanded from the center of image would hit
            // which edge of the image first.

            // The preview is always size maximized proportionally until the image hits the frame.
            final bool widthTouchFirstGraphicVsFrame =
                (imageFileWidth / imageFileHeight) * frameHeight >= frameWidth;

            final bool widthTouchFirstRedBoxVsGraphic =
                (cardShapeWidth / cardShapeHeight) * imageFileHeight >=
                    imageFileWidth;

            double graphicInFrameWidth;
            double graphicInFrameHeight;
            if (widthTouchFirstGraphicVsFrame) {
              graphicInFrameWidth = frameWidth;
              graphicInFrameHeight =
                  imageFileHeight / imageFileWidth * frameWidth;
            } else {
              graphicInFrameWidth =
                  imageFileWidth / imageFileHeight * frameHeight;
              graphicInFrameHeight = frameHeight;
            }

            // Fit red box inside the graphic next.
            double cardShapeInBoxWidth;
            double cardShapeInBoxHeight;
            if (widthTouchFirstRedBoxVsGraphic) {
              cardShapeInBoxWidth = graphicInFrameWidth;
              cardShapeInBoxHeight =
                  cardShapeHeight / cardShapeWidth * graphicInFrameWidth;
            } else {
              cardShapeInBoxWidth =
                  cardShapeWidth / cardShapeHeight * graphicInFrameHeight;
              cardShapeInBoxHeight = graphicInFrameHeight;
            }

            cardShapeInBoxWidth = cardShapeInBoxWidth * widget.bleedFactor;
            cardShapeInBoxHeight = cardShapeInBoxHeight * widget.bleedFactor;

            final image = Image.file(
              file,
            );

            Color borderColor;
            switch (effectiveRotation) {
              case Rotation.none:
                borderColor = Colors.redAccent.shade400;
                break;
              case Rotation.clockwise90:
                borderColor = Colors.limeAccent.shade400;
                break;
              case Rotation.counterClockwise90:
                borderColor = Colors.tealAccent.shade400;
                break;
            }

            final imageFitBox = Container(
                width: cardShapeInBoxWidth,
                height: cardShapeInBoxHeight,
                decoration: widget.showBorder
                    ? BoxDecoration(
                        border: Border.all(color: borderColor, width: 1))
                    : null);

            Widget previewStack = Stack(
                alignment: AlignmentDirectional.center,
                children: [image, imageFitBox]);

            // If clicking is enabled, wrap the stack in a GestureDetector
            if (!widget.disableClick && cardFace.relativeFilePath.isNotEmpty) {
              return GestureDetector(
                onTap: () {
                  FullScreenCardPreview.show(
                    context,
                    basePath: widget.basePath,
                    cardSize: widget.cardSize,
                    bleedFactor: widget.bleedFactor,
                    cardFace: cardFace,
                    projectSettings: widget.projectSettings,
                  );
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: previewStack,
                ),
              );
            }

            return previewStack;
          },
        );
      },
      future: descriptorFuture,
    );
  }
}
