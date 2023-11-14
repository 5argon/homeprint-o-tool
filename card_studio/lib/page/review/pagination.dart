import 'dart:math';

import 'package:card_studio/page/layout/back_strategy.dart';

import '../../core/card.dart';
import '../include/include_data.dart';
import '../layout/layout_logic.dart';
import '../layout/layout_struct.dart';

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
  final countRequired =
      includes.fold(0, (prev, includeItem) => prev + includeItem.count());
  final totalPages = (countRequired / cardCountPerPage).ceil();
  final validSkips =
      layoutData.skips.where((e) => e <= cardCountPerPage).toList();
  final totalSkips = validSkips.length * totalPages;
  final totalPagesWithSkips =
      ((countRequired + totalSkips) / cardCountPerPage).ceil();
  return CardsPagination(totalPagesWithSkips, cardCountPerPage);
}

/// Card can be blank on one side or even both sides. Use null for that.
typedef RowColCards = List<List<CardEachSingle?>>;

class CardsAtPage {
  RowColCards front;
  RowColCards back;
  CardsPagination pagination;
  CardsAtPage(this.front, this.back, this.pagination);
}

/// Return a list of cards (both front and back as one card)
/// that should be in a given page number. Page number starts from 1.
/// Spot that is a skip returns null card.
CardsAtPage cardsAtPage(Includes includes, Includes skipIncludes,
    LayoutData layoutData, SizePhysical cardSize, int page) {
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

  final frontCards = onThisPage.map((e) => e.front).toList();
  final backCards = onThisPage.map((e) => e.back).toList();
  final skipCardsFront = allSkips.map((e) => e.front).toList();
  final skipCardsBack = allSkips.map((e) => e.back).toList();
  return CardsAtPage(
    distributeRowCol(page, cardCountRowCol.rows, cardCountRowCol.columns,
        frontCards, skipCardsFront, BackStrategy.exact, validSkips),
    distributeRowCol(page, cardCountRowCol.rows, cardCountRowCol.columns,
        backCards, skipCardsBack, BackStrategy.invertedRow, validSkips),
    pagination,
  );
}

/// List of list is row then column.
RowColCards distributeRowCol(
    int page,
    int rows,
    int cols,
    List<CardEachSingle?> cards,
    List<CardEachSingle?> skipCards,
    BackStrategy backStrategy,
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
    if (backStrategy == BackStrategy.invertedRow) {
      target = cols - 1 - (v % cols);
    } else {
      target = v % cols;
    }
    final CardEachSingle? cardToAdd;
    final isSkip = skips.contains(v + 1);
    if (isSkip) {
      if (skipCards.isNotEmpty) {
        final skipCycleIndex = skipCount % skipCards.length;
        skipCount++;
        cardToAdd = skipCards[skipCycleIndex];
      } else {
        cardToAdd = null;
      }
    } else {
      cardToAdd = cards[realCount];
      realCount++;
    }
    allRows[row][target] = cardToAdd;
  }
  return allRows;
}
