import 'package:homeprint_o_tool/core/card_face.dart';
import 'package:homeprint_o_tool/core/page_preview/parallel_guide.dart';
import 'package:homeprint_o_tool/page/layout/layout_helper.dart';
import 'package:homeprint_o_tool/page/layout/layout_logic.dart';
import 'package:homeprint_o_tool/page/review/pagination.dart';
import 'package:flutter/material.dart';

import '../../page/layout/layout_data.dart';
import '../project_settings.dart';
import 'card_area.dart';

/// Use for both output preview and actual image export. On preview it stretches
/// to the parent object. On export we can control parent to have the same aspect
/// then make it as big as required.
///
/// This renders just 1 page and how many cards can fit depends on the layout struct.
/// [cards] is an array of array. The first layer is a row. The second layer is each card
/// in the row (e.g. column). Overflows are discarded.
class PagePreview extends StatefulWidget {
  final LayoutData layoutData;
  final RowColCards cards;
  final bool layout;
  final bool previewCutLine;
  final bool hideInnerCutLine;
  final bool back;

  /// Must provide to show any image.
  final String? baseDirectory;
  final ProjectSettings projectSettings;

  PagePreview({
    required this.layoutData,
    required this.cards,
    required this.layout,
    required this.previewCutLine,
    required this.baseDirectory,
    required this.projectSettings,
    required this.hideInnerCutLine,
    required this.back,
  });

  @override
  State<PagePreview> createState() => _PagePreviewState();
}

class _PagePreviewState extends State<PagePreview> {
  late int horizontalCards;
  late int verticalCards;

  @override
  void initState() {
    super.initState();
    final cardCount = calculateCardCountPerPage(
        widget.layoutData, widget.projectSettings.cardSize);
    horizontalCards = cardCount.columns;
    verticalCards = cardCount.rows;
  }

  @override
  void didUpdateWidget(covariant PagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    final cardCount = calculateCardCountPerPage(
        widget.layoutData, widget.projectSettings.cardSize);
    horizontalCards = cardCount.columns;
    verticalCards = cardCount.rows;
  }

  @override
  Widget build(BuildContext context) {
    if (horizontalCards <= 0 || verticalCards <= 0) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("(No card can fit in this page.)"),
      );
    }
    final ld = widget.layoutData;

    const flexMultiplier = 10000000;
    int marginFlex =
        (ld.marginSize.heightCm / ld.paperSize.heightCm * flexMultiplier)
            .round();
    int guideFlex =
        (ld.edgeCutGuideSize.heightCm / ld.paperSize.heightCm * flexMultiplier)
            .round();

    int guideCornerFlex =
        (ld.marginSize.widthCm / ld.paperSize.widthCm * flexMultiplier).round();
    int guideCornerSecondFlex =
        (ld.edgeCutGuideSize.widthCm / ld.paperSize.widthCm * flexMultiplier)
            .round();

    double horizontalAllEachCardCm = (ld.paperSize.widthCm -
            ((ld.marginSize.widthCm + ld.edgeCutGuideSize.widthCm) * 2)) /
        horizontalCards;
    double verticalAllEachCardCm = (ld.paperSize.heightCm -
            ((ld.marginSize.heightCm + ld.edgeCutGuideSize.heightCm) * 2)) /
        verticalCards;

    int cardFlexVertical =
        (verticalAllEachCardCm / ld.paperSize.heightCm * flexMultiplier)
            .round();

    int cardFlexHorizontal =
        (horizontalAllEachCardCm / ld.paperSize.widthCm * flexMultiplier)
            .round();

    Widget verticalMargin = Expanded(
        flex: guideCornerFlex,
        child: LayoutHelper(
          color: Colors.grey,
          visible: widget.layout,
          flashing: false,
        ));

    final cardSize = widget.projectSettings.cardSize;

    double horizontalBleedEachCard = horizontalAllEachCardCm - cardSize.widthCm;
    double horizontalActualEachCard =
        horizontalAllEachCardCm - horizontalBleedEachCard;
    double horizontalSpace = horizontalActualEachCard / horizontalAllEachCardCm;
    double guideHorizontal = cardSize.widthCm / horizontalAllEachCardCm;

    List<Widget> allCardRows = [];
    for (var i = 0; i < verticalCards; i++) {
      int cutFlex =
          (ld.edgeCutGuideSize.widthCm / ld.paperSize.widthCm * flexMultiplier)
              .round();

      double verticalBleedEachCardCm =
          verticalAllEachCardCm - cardSize.heightCm;
      double verticalActualEachCardCm =
          verticalAllEachCardCm - verticalBleedEachCardCm;
      double verticalSpace = verticalActualEachCardCm / verticalAllEachCardCm;
      double guideVertical = cardSize.heightCm / verticalAllEachCardCm;

      Widget cut = Expanded(
          flex: cutFlex,
          child: Stack(
            children: [
              LayoutHelper(
                color: Colors.blue,
                visible: widget.layout,
                flashing: false,
              ),
              ParallelGuide(
                  spaceTaken: guideVertical,
                  axis: Axis.horizontal,
                  color: Colors.black)
            ],
          ));

      List<Widget> realCards = [];
      for (var j = 0; j < horizontalCards; j++) {
        CardFace? card;
        if (widget.cards.length > i && widget.cards[i].length > j) {
          card = widget.cards[i][j];
        }

        final cardArea = CardArea(
          horizontalSpace: horizontalSpace,
          verticalSpace: verticalSpace,
          guideHorizontal: guideHorizontal,
          guideVertical: guideVertical,
          baseDirectory: widget.baseDirectory,
          projectSettings: widget.projectSettings,
          card: card,
          cardSize: cardSize,
          layoutMode: widget.layout,
          previewCutLine: widget.previewCutLine,
          showHorizontalInnerCutLine: !widget.hideInnerCutLine,
          showVerticalInnerCutLine: !widget.hideInnerCutLine,
          back: widget.back,
          backArrangement: widget.layoutData.backArrangement,
        );
        Widget entireCardArea =
            Expanded(flex: cardFlexHorizontal, child: cardArea);
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
          visible: widget.layout,
          flashing: false,
        ));
    Widget guideCard = Expanded(
        flex: cardFlexHorizontal,
        child: Stack(
          children: [
            LayoutHelper(
              color: Colors.blue,
              visible: widget.layout,
              flashing: false,
            ),
            ParallelGuide(
                spaceTaken: guideHorizontal,
                axis: Axis.vertical,
                color: Colors.black)
          ],
        ));
    List<Widget> guideCards = List.filled(horizontalCards, guideCard);
    Widget marginRow = Expanded(
        flex: marginFlex,
        child: LayoutHelper(
          color: Colors.grey,
          visible: widget.layout,
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
