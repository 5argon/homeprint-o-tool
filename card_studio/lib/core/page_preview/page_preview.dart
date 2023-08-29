import 'dart:async';

import 'package:card_studio/core/page_preview/parallel_guide.dart';
import 'package:card_studio/page/layout/layout_helper.dart';
import 'package:card_studio/page/layout/layout_logic.dart';
import 'package:card_studio/page/review/pagination.dart';
import 'package:flutter/material.dart';

import '../../page/layout/layout_struct.dart';
import '../card.dart';
import 'card_area.dart';
import 'card_area_2.dart';

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
  final bool previewCutLine;

  /// Must provide to show any image.
  final String? baseDirectory;

  late int horizontalCards;
  late int verticalCards;
  late List<Completer> completers;

  PagePreview({
    required this.layoutData,
    required this.cardSize,
    required this.cards,
    required this.layout,
    required this.previewCutLine,
    required this.baseDirectory,
  }) {
    final cardCount = calculateCardCountPerPage(layoutData, cardSize);
    horizontalCards = cardCount.columns;
    verticalCards = cardCount.rows;
    assert(horizontalCards >= 1);
    assert(verticalCards >= 1);
    completers = [];
    for (var i = 0; i < horizontalCards * verticalCards; i++) {
      final com = Completer();
      completers.add(com);
    }
  }

  Future forceLoad(BuildContext context, String baseDirectory) async {
    for (var i = 0; i < cards.length; i++) {
      for (var j = 0; j < cards[i].length; j++) {
        final card = cards[i][j];
        if (card != null) {
          await card.forceLoad(context, baseDirectory);
        }
      }
    }
  }

  /// Check if this page is completely rendered yet.
  Future waitForAllImages() async {
    final start = DateTime.timestamp();
    for (var i = 0; i < completers.length; i++) {
      await completers[i].future;
    }
    final finish = DateTime.timestamp();
    print(
        "Page took ${finish.millisecondsSinceEpoch - start.millisecondsSinceEpoch} ms");
  }

  @override
  Widget build(BuildContext context) {
    final ld = layoutData;

    const flexMultiplier = 10000000;
    int marginFlex =
        (ld.marginSize.heightCm / ld.paperSize.heightCm * flexMultiplier)
            .round();
    int guideFlex =
        (ld.edgeCutGuideSize.heightCm / ld.paperSize.heightCm * flexMultiplier)
            .round();
    int cardFlexVertical =
        (cardSize.heightCm / ld.paperSize.heightCm * flexMultiplier).round();

    int guideCornerFlex =
        (ld.marginSize.widthCm / ld.paperSize.widthCm * flexMultiplier).round();
    int guideCornerSecondFlex =
        (ld.edgeCutGuideSize.widthCm / ld.paperSize.widthCm * flexMultiplier)
            .round();

    double horizontalAllEachCard = (ld.paperSize.widthCm -
            ((ld.marginSize.widthCm + ld.edgeCutGuideSize.widthCm) * 2)) /
        horizontalCards;
    double verticalAllEachCard = (ld.paperSize.heightCm -
            ((ld.marginSize.heightCm + ld.edgeCutGuideSize.heightCm) * 2)) /
        verticalCards;

    double cardHorizontalToPaper = horizontalAllEachCard / ld.paperSize.widthCm;
    int cardAreaFlex = (cardHorizontalToPaper * flexMultiplier).round();

    Widget verticalMargin = Expanded(
        flex: guideCornerFlex,
        child: LayoutHelper(
          color: Colors.grey,
          visible: layout,
          flashing: false,
        ));

    double horizontalBleedEachCard = horizontalAllEachCard - cardSize.widthCm;
    double horizontalActualEachCard =
        horizontalAllEachCard - horizontalBleedEachCard;
    double horizontalSpace = horizontalActualEachCard / horizontalAllEachCard;
    List<Widget> allCardRows = [];
    for (var i = 0; i < verticalCards; i++) {
      int cutFlex =
          (ld.edgeCutGuideSize.widthCm / ld.paperSize.widthCm * flexMultiplier)
              .round();

      double verticalBleedEachCard = verticalAllEachCard - cardSize.heightCm;
      double verticalActualEachCard =
          verticalAllEachCard - verticalBleedEachCard;
      double verticalSpace = verticalActualEachCard / verticalAllEachCard;

      Widget cut = Expanded(
          flex: cutFlex,
          child: Stack(
            children: [
              LayoutHelper(
                color: Colors.blue,
                visible: layout,
                flashing: false,
              ),
              ParallelGuide(
                  spaceTaken: verticalSpace,
                  axis: Axis.horizontal,
                  color: Colors.black)
            ],
          ));

      List<Widget> realCards = [];
      for (var j = 0; j < horizontalCards; j++) {
        CardEachSingle? card;
        if (cards.length > i && cards[i].length > j) {
          card = cards[i][j];
        }

        final cardArea = CardArea(
          horizontalSpace: horizontalSpace,
          verticalSpace: verticalSpace,
          baseDirectory: baseDirectory,
          card: card,
          cardSize: cardSize,
          layoutMode: layout,
          previewCutLine: previewCutLine,
        );
        cardArea.waitForLoad(context).then((value) {
          final index = (i * horizontalCards) + j;
          completers[index].complete();
        });
        Widget entireCardArea = Expanded(flex: cardAreaFlex, child: cardArea);
        realCards.add(entireCardArea);
      }

      Widget cardRow = Expanded(
          flex: cardFlexVertical,
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
        flex: cardAreaFlex,
        child: Stack(
          children: [
            LayoutHelper(
              color: Colors.blue,
              visible: layout,
              flashing: false,
            ),
            ParallelGuide(
                spaceTaken: horizontalSpace,
                axis: Axis.vertical,
                color: Colors.black)
          ],
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
        child: Stack(
          children: [
            Container(
              color: Colors.white,
            ),
            Column(children: [
              marginRow,
              guideRow,
              ...allCardRows,
              guideRow,
              marginRow
            ])
          ],
        ));
    return allRows;
  }
}
