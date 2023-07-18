import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Use for both output preview and actual image export. On preview it stretches
/// to the parent object. On export we can control parent to have the same aspect
/// then make it as big as required.
class PagePreview extends StatelessWidget {
  Size paperSize;
  Size cardSize;
  Size marginSize;
  Size edgeCutGuideSize;
  double whitePadding;
  double cutGuideLineWidth;
  List<CardGame> cards;
  GlobalKey? globalKey;

  PagePreview(
      this.paperSize,
      this.cardSize,
      this.marginSize,
      this.edgeCutGuideSize,
      this.whitePadding,
      this.cutGuideLineWidth,
      this.cards,
      {this.globalKey}) {}

  // Future<Uint8List> _capturePng() async {
  //       print('inside');
  //       RenderObject? ro = globalKey!.currentContext!.findRenderObject();
  //       ui.Image image = await ro.toImage(pixelRatio: 3.0);
  //       ByteData byteData =
  //           await image.toByteData(format: ui.ImageByteFormat.png);
  //       var pngBytes = byteData.buffer.asUint8List();
  //       var bs64 = base64Encode(pngBytes);
  //       print(pngBytes);
  //       print(bs64);
  //       return pngBytes;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    var cardSpaceHorizontal =
        paperSize.width - (2 * (marginSize.width + edgeCutGuideSize.width));
    var cardSpaceVertical =
        paperSize.height - (2 * (marginSize.height + edgeCutGuideSize.height));
    int horizontalCards = cardSpaceHorizontal ~/ cardSize.width;
    int verticalCards = cardSpaceVertical ~/ cardSize.height;

    const flexMultiplier = 1000000;
    int marginFlex =
        (marginSize.height / paperSize.height * flexMultiplier).round();
    int guideFlex =
        (edgeCutGuideSize.height / paperSize.height * flexMultiplier).round();
    int cardFlex =
        (cardSize.height / paperSize.height * flexMultiplier).round();

    int guideCornerFlex =
        (marginSize.width / paperSize.width * flexMultiplier).round();
    int guideCornerSecondFlex =
        (edgeCutGuideSize.width / paperSize.width * flexMultiplier).round();
    int guideCardFlex =
        ((paperSize.width - ((marginSize.width + edgeCutGuideSize.width) * 2)) /
                horizontalCards /
                paperSize.width *
                flexMultiplier)
            .round();

    Widget verticalMargin = Expanded(
        flex: guideCornerFlex,
        child: Placeholder(strokeWidth: 1, color: Colors.grey));
    Widget guideCorner = Expanded(
        flex: guideCornerSecondFlex,
        child: Placeholder(strokeWidth: 1, color: Colors.grey));
    Widget guideCard = Expanded(
        flex: guideCardFlex,
        child: Placeholder(strokeWidth: 1, color: Colors.blue));
    List<Widget> guideCards = List.filled(horizontalCards, guideCard);

    Widget marginRow = Expanded(
        flex: marginFlex,
        child: Placeholder(
          strokeWidth: 1,
          color: Colors.grey,
        ));

    Widget guideRow = Expanded(
        flex: guideFlex,
        child: Row(children: [
          verticalMargin,
          guideCorner,
          ...guideCards,
          guideCorner,
          verticalMargin
        ]));

    int cutFlex =
        (edgeCutGuideSize.width / paperSize.width * flexMultiplier).round();
    Widget cut = Expanded(
        flex: cutFlex, child: Placeholder(strokeWidth: 1, color: Colors.blue));
    Widget realCard = Expanded(
        flex: guideCardFlex,
        child: Placeholder(strokeWidth: 1, color: Colors.orange));
    List<Widget> realCards = List.filled(horizontalCards, realCard);

    Widget cardRow = Expanded(
        flex: cardFlex,
        child: Row(children: [
          verticalMargin,
          cut,
          ...realCards,
          cut,
          verticalMargin
        ]));
    List<Widget> allCardRows = List.filled(verticalCards, cardRow);

    var repaintBoundary = RepaintBoundary(
      key: globalKey,
      child: AspectRatio(
          aspectRatio: paperSize.width / paperSize.height,
          child: Placeholder(
            child: Column(children: [
              marginRow,
              guideRow,
              ...allCardRows,
              guideRow,
              marginRow
            ]),
          )),
    );
    return repaintBoundary;
  }
}

class Size {
  double width;
  double height;

  Size(this.width, this.height);
  // Size.fromPhysical(double cmWidth, double cmHeight, double ppi)
  //     : width = (cmWidth * ppi / 2.54).round(),
  //       height = (cmHeight * ppi / 2.54).round();
}

class CardGame {}
