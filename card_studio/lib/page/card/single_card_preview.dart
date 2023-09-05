import 'dart:io';
import 'dart:ui';

import 'package:card_studio/page/layout/layout_struct.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../core/card.dart';

class SingleCardPreview extends StatelessWidget {
  final double bleedFactor;
  final String basePath;
  final SizePhysical cardSize;
  final CardEachSingle? cardEachSingle;
  final bool instance;

  Future<ImageDescriptor>? descriptorFuture;
  late File file;

  SingleCardPreview({
    super.key,
    required this.bleedFactor,
    required this.cardSize,
    required this.basePath,
    required this.cardEachSingle,
    required this.instance,
  }) {
    final cardEachSingle = this.cardEachSingle;
    if (cardEachSingle != null) {
      final joinedPath = p.join(basePath, cardEachSingle.relativeFilePath);
      final file = File(joinedPath);
      descriptorFuture = getDescriptor(file);
      this.file = file;
    }
  }

  Future<ImageDescriptor> getDescriptor(File loadedFile) async {
    final bytes = await loadedFile.readAsBytes();
    final buff = await ImmutableBuffer.fromUint8List(bytes);
    final descriptor = await ImageDescriptor.encoded(buff);
    return descriptor;
  }

  @override
  Widget build(BuildContext context) {
    final cardEachSingle = this.cardEachSingle;
    if (cardEachSingle == null) {
      return Text("None");
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

            final moreWidth = imageFileWidth > imageFileHeight;

            // Find a box of card first, then fit a content box inside of that.
            double cardInBoxWidth;
            double cardInBoxHeight;
            if (moreWidth) {
              cardInBoxWidth = frameWidth;
              cardInBoxHeight = imageFileHeight / imageFileWidth * frameWidth;
            } else {
              cardInBoxWidth = imageFileWidth / imageFileHeight * frameHeight;
              cardInBoxHeight = frameHeight;
            }

            double cardShapeWidth;
            double cardShapeHeight;
            if (cardEachSingle.rotation == Rotation.none) {
              cardShapeWidth = cardSize.widthCm;
              cardShapeHeight = cardSize.heightCm;
            } else {
              cardShapeWidth = cardSize.heightCm;
              cardShapeHeight = cardSize.widthCm;
            }

            // Fit card shape inside card in box.
            double cardShapeInBoxWidth;
            double cardShapeInBoxHeight;
            if (cardShapeWidth > cardShapeHeight) {
              cardShapeInBoxWidth = cardInBoxWidth;
              cardShapeInBoxHeight =
                  cardShapeHeight / cardShapeWidth * cardInBoxWidth;
            } else {
              cardShapeInBoxWidth =
                  cardShapeWidth / cardShapeHeight * cardInBoxHeight;
              cardShapeInBoxHeight = cardInBoxHeight;
            }

            cardShapeInBoxWidth = cardShapeInBoxWidth * bleedFactor;
            cardShapeInBoxHeight = cardShapeInBoxHeight * bleedFactor;

            final image = Image.file(
              file,
            );

            final imageFitBox = Container(
                width: cardShapeInBoxWidth,
                height: cardShapeInBoxHeight,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 1)));
            return Stack(
                alignment: AlignmentDirectional.center,
                children: [image, imageFitBox]);
          },
        );
      },
      future: descriptorFuture,
    );
  }
}
