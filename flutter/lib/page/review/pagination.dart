import 'dart:math';

import 'package:homeprint_o_tool/core/card_face.dart';
import 'package:homeprint_o_tool/core/save_file.dart';
import 'package:homeprint_o_tool/page/layout/back_arrangement.dart';
import 'package:homeprint_o_tool/page/picks/include_data.dart';
import 'package:homeprint_o_tool/page/layout/layout_logic.dart';
import 'package:homeprint_o_tool/page/layout/layout_data.dart';

class CardsPagination {
  final int totalPages;
  final int perPage;
  CardsPagination(this.totalPages, this.perPage);
}

/// Return how many pages it requires to render all included cards,
/// along with count per page, respecting skips.
CardsPagination calculatePagination(Includes includes, LayoutData layoutData,
    SizePhysical cardSize, int row, int col) {
  final cardCountRowCol = calculateCardCountPerPage(layoutData, cardSize);
  final cardCountPerPage = cardCountRowCol.rows * cardCountRowCol.columns;
  if (cardCountPerPage <= 0) {
    return CardsPagination(0, 0);
  }
  final validSkips =
      layoutData.skips.where((e) => e >= 0 && e < cardCountPerPage).toList();
  final cardCountPerPageWithSkips = cardCountPerPage - validSkips.length;
  final countRequired =
      includes.fold(0, (prev, includeItem) => prev + includeItem.count());
  final totalPages = (countRequired / cardCountPerPageWithSkips).ceil();
  return CardsPagination(totalPages, cardCountPerPageWithSkips);
}

/// Card can be blank on one side or even both sides. Use null for that.
typedef RowColCards = List<List<CardFace?>>;

class CardsAtPage {
  RowColCards front;
  RowColCards back;
  CardsPagination pagination;
  CardsAtPage(this.front, this.back, this.pagination);
}

/// Return a list of cards (both front and back as one card)
/// that should be in a given page number. Page number starts from 1.
/// Spot that is a skip returns null card.
CardsAtPage cardsAtPage(
    Includes includes,
    Includes skipIncludes,
    LayoutData layoutData,
    SizePhysical cardSize,
    int page,
    LinkedCardFaces linkedCardFaces) {
  final cardCountRowCol = calculateCardCountPerPage(layoutData, cardSize);
  final pagination = calculatePagination(includes, layoutData, cardSize,
      cardCountRowCol.rows, cardCountRowCol.columns);
  if (page > pagination.totalPages) {
    return CardsAtPage([], [], pagination);
  }
  final allIncludes = includes.expand((e) => e.linearize()).toList();
  final allSkips = skipIncludes.expand((e) => e.linearize()).toList();

  final validSkips =
      layoutData.skips.where((e) => e <= pagination.perPage).toList();
  final perPageWithSkips = pagination.perPage - validSkips.length;

  final start = (page - 1) * perPageWithSkips;
  final end =
      min((page - 1) * perPageWithSkips + perPageWithSkips, allIncludes.length);
  final onThisPage = allIncludes.sublist(start, end);

  final frontCards =
      onThisPage.map((e) => e.getFront(linkedCardFaces)).toList();
  final backCards = onThisPage.map((e) => e.getBack(linkedCardFaces)).toList();
  final skipCardsFront =
      allSkips.map((e) => e.getFront(linkedCardFaces)).toList();
  final skipCardsBack =
      allSkips.map((e) => e.getBack(linkedCardFaces)).toList();
  return CardsAtPage(
    distributeRowCol(page, cardCountRowCol.rows, cardCountRowCol.columns,
        frontCards, skipCardsFront, BackArrangement.exact, validSkips),
    distributeRowCol(page, cardCountRowCol.rows, cardCountRowCol.columns,
        backCards, skipCardsBack, layoutData.backArrangement, validSkips),
    pagination,
  );
}

/// List of list is row then column.
RowColCards distributeRowCol(
    int page,
    int rows,
    int cols,
    List<CardFace?> cards,
    List<CardFace?> skipCards,
    BackArrangement backStrategy,
    List<int> skips) {
  RowColCards allRows = [];
  final previousSkips = skips.length * (page - 1);
  final cardCount = rows * cols;
  var realCount = 0;
  var skipCount = previousSkips;
  for (var v = 0; v < cardCount; v++) {
    final row = v ~/ cols;
    if (allRows.length <= row) {
      allRows.add(List.filled(cols, null));
    }
    final int target;
    if (backStrategy == BackArrangement.invertedRow) {
      target = cols - 1 - (v % cols);
    } else {
      target = v % cols;
    }
    final CardFace? cardToAdd;
    final isSkip = skips.contains(v);
    if (isSkip) {
      if (skipCards.isNotEmpty) {
        final skipCycleIndex = skipCount % skipCards.length;
        skipCount++;
        cardToAdd = skipCards[skipCycleIndex];
      } else {
        cardToAdd = null;
      }
    } else {
      if (cards.length > realCount) {
        cardToAdd = cards[realCount];
        realCount++;
      } else {
        cardToAdd = null;
      }
    }
    allRows[row][target] = cardToAdd;
  }
  return allRows;
}
