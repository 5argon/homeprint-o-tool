import 'package:flutter/material.dart';

import 'layout_struct.dart';

/// Use for both output preview and actual image export. On preview it stretches
/// to the parent object. On export we can control parent to have the same aspect
/// then make it as big as required.
///
/// This renders just 1 page and how many cards can fit depends on the layout struct.
/// [cards] sequentially fill these slots from left to right, then top to bottom. If cards
/// are over available slots, it throws an error.
class PagePreview extends StatelessWidget {
  final LayoutData layoutData;
  final SizePhysical cardSize;
  final List<CardGame> cards;

  PagePreview(
    this.layoutData,
    this.cardSize,
    this.cards,
  );

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
    final ld = layoutData;
    var cardSpaceHorizontal = ld.paperSize.widthCm -
        (2 * (ld.marginSize.widthCm + ld.edgeCutGuideSize.widthCm));
    var cardSpaceVertical = ld.paperSize.heightCm -
        (2 * (ld.marginSize.heightCm + ld.edgeCutGuideSize.heightCm));
    int horizontalCards = cardSpaceHorizontal ~/ cardSize.widthCm;
    int verticalCards = cardSpaceVertical ~/ cardSize.heightCm;

    assert(horizontalCards >= 1);
    assert(verticalCards >= 1);

    const flexMultiplier = 1000000;
    int marginFlex =
        (ld.marginSize.heightCm / ld.paperSize.heightCm * flexMultiplier)
            .round();
    int guideFlex =
        (ld.edgeCutGuideSize.heightCm / ld.paperSize.heightCm * flexMultiplier)
            .round();
    int cardFlex =
        (cardSize.heightCm / ld.paperSize.heightCm * flexMultiplier).round();

    int guideCornerFlex =
        (ld.marginSize.widthCm / ld.paperSize.widthCm * flexMultiplier).round();
    int guideCornerSecondFlex =
        (ld.edgeCutGuideSize.widthCm / ld.paperSize.widthCm * flexMultiplier)
            .round();
    int guideCardFlex = ((ld.paperSize.widthCm -
                ((ld.marginSize.widthCm + ld.edgeCutGuideSize.widthCm) * 2)) /
            horizontalCards /
            ld.paperSize.widthCm *
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
        (ld.edgeCutGuideSize.widthCm / ld.paperSize.widthCm * flexMultiplier)
            .round();
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

    var repaintBoundary = AspectRatio(
        aspectRatio: ld.paperSize.widthCm / ld.paperSize.heightCm,
        child: Placeholder(
          child: Column(children: [
            marginRow,
            guideRow,
            ...allCardRows,
            guideRow,
            marginRow
          ]),
        ));
    return repaintBoundary;
  }
}
