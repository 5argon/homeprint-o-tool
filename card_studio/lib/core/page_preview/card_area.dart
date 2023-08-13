import 'dart:io';
import 'dart:ui';

import 'package:card_studio/core/card.dart';
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

  Future<ImageDescriptor> getDescriptor(File loadedFile) async {
    final bytes = await loadedFile.readAsBytes();
    final buff = await ImmutableBuffer.fromUint8List(bytes);
    final descriptor = await ImageDescriptor.encoded(buff);
    return descriptor;
  }

  Future waitForLoad(BuildContext context) async {
    final fileObject = this.fileObject;
    if (fileObject != null) {
      final fileImageProvider = FileImage(fileObject);
      await precacheImage(fileImageProvider, context);
    }
    await _getDescriptorFuture;
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = Container();
    if (card != null && baseDirectory != null) {
      final cropRect = EdgeInsets.all(0.2);
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
                  final parentWidth = constraints.maxWidth;
                  final parentHeight = constraints.maxHeight;
                  final imageWidth = descriptorData.width;
                  final imageHeight = descriptorData.height;

                  final heightFitScale = (imageHeight / parentHeight);
                  final widthFitScale = (imageWidth / parentWidth);

                  final imageFileWidget = Image.file(
                    fileObject,
                    alignment: Alignment(0, 0),
                    scale: widthFitScale,
                    fit: BoxFit.none,
                  );

                  return SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                    child: imageFileWidget,
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
