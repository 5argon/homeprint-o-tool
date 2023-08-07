import 'package:card_studio/page/layout/layout_helper.dart';
import 'package:card_studio/page/layout/layout_logic.dart';
import 'package:card_studio/page/review/pagination.dart';
import 'package:flutter/material.dart';

import '../../page/layout/cut_guide.dart';
import '../../page/layout/layout_struct.dart';
import '../card.dart';
import 'card_area.dart';

/// Use for both output preview and actual image export. On preview it stretches
/// to the parent object. On export we can control parent to have the same aspect
/// then make it as big as required.
///
/// This renders just 1 page and how many cards can fit depends on the layout struct.
/// [cards] is an array of array. The first layer is a row. The second layer is each card
/// in the row (e.g. column). Overflows are discarded.
class PagePreview extends StatelessWidget {
  final LayoutData layoutData;
  final SizePhysical cardSize;
  final RowColCards cards;
  final bool layout;
  final bool previewCuttingLine;

  /// Must provide to show any image.
  final String? baseDirectory;

  PagePreview(
    this.layoutData,
    this.cardSize,
    this.cards,
    this.layout,
    this.previewCuttingLine,
    this.baseDirectory,
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
    final cardCount = calculateCardCountPerPage(layoutData, cardSize);
    final horizontalCards = cardCount.rows;
    final verticalCards = cardCount.columns;

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
        child: LayoutHelper(
          color: Colors.grey,
          visible: layout,
          flashing: false,
        ));

    List<Widget> allCardRows = [];
    for (var i = 0; i < verticalCards; i++) {
      int cutFlex =
          (ld.edgeCutGuideSize.widthCm / ld.paperSize.widthCm * flexMultiplier)
              .round();
      Widget cut = Expanded(
          flex: cutFlex,
          child: LayoutHelper(
            color: Colors.blue,
            visible: layout,
            flashing: false,
          ));

      List<Widget> realCards = [];
      for (var j = 0; j < horizontalCards; j++) {
        CardEachSingle? card;
        if (cards.length > i && cards[i].length > j) {
          card = cards[i][j];
        }
        Widget entireCardArea = Expanded(
            flex: guideCardFlex,
            child: CardArea(
                baseDirectory: baseDirectory, card: card, layout: layout));
        realCards.add(entireCardArea);
      }

      Widget cardRow = Expanded(
          flex: cardFlex,
          child: Row(children: [
            verticalMargin,
            cut,
            ...realCards,
            cut,
            verticalMargin
          ]));
      allCardRows.add(cardRow);
    }

    Widget guideCorner = Expanded(
        flex: guideCornerSecondFlex,
        child: LayoutHelper(
          color: Colors.blue,
          visible: layout,
          flashing: false,
        ));
    Widget guideCard = Expanded(
        flex: guideCardFlex,
        child: CutGuide(
          direction: GuideDirection.horizontal,
          lineSize: ld.edgeCutGuideSize,
          layoutMode: layout,
          layoutGuideColor: Colors.blue,
          totalSize: guideCardFlex.toDouble(),
          cardSize: guideCardFlex.toDouble(),
        ));
    List<Widget> guideCards = List.filled(horizontalCards, guideCard);
    Widget marginRow = Expanded(
        flex: marginFlex,
        child: LayoutHelper(
          color: Colors.grey,
          visible: layout,
          flashing: false,
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

    var allRows = AspectRatio(
        aspectRatio: ld.paperSize.widthCm / ld.paperSize.heightCm,
        child: Column(children: [
          marginRow,
          guideRow,
          ...allCardRows,
          guideRow,
          marginRow
        ]));
    return allRows;
  }
}
