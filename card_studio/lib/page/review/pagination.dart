import 'dart:math';

import 'package:card_studio/page/layout/back_strategy.dart';

import '../../core/card.dart';
import '../include/include_data.dart';
import '../layout/layout_logic.dart';
import '../layout/layout_struct.dart';

/// Return how many pages it requires to render all included cards,
/// along with count per page.
({int totalPages, int perPage}) calculatePagination(Includes includes,
    LayoutData layoutData, SizePhysical cardSize, int row, int col) {
  final cardCountRowCol = calculateCardCountPerPage(layoutData, cardSize);
  final cardCountPerPage = cardCountRowCol.rows * cardCountRowCol.columns;
  final countRequired =
      includes.fold(0, (prev, includeItem) => prev + includeItem.count());
  final totalPages = (countRequired / cardCountPerPage).ceil();
  return (totalPages: totalPages, perPage: cardCountPerPage);
}

/// Card can be blank on one side or even both sides. Use null for that.
typedef RowColCards = List<List<CardEachSingle?>>;

/// Return a list of cards (both front and back as one card)
/// that should be in a given page number. Page number starts from 1.
({RowColCards front, RowColCards back}) cardsAtPage(
    Includes includes, LayoutData layoutData, SizePhysical cardSize, int page) {
  final cardCountRowCol = calculateCardCountPerPage(layoutData, cardSize);
  final pagination = calculatePagination(includes, layoutData, cardSize,
      cardCountRowCol.rows, cardCountRowCol.columns);
  if (page > pagination.totalPages) {
    return (front: [], back: []);
  }
  final allIncludes = includes.expand((e) => e.linearize()).toList();
  final start = (page - 1) * pagination.perPage;
  final end = min(
      (page - 1) * pagination.perPage + pagination.perPage, allIncludes.length);
  final onThisPage = allIncludes.sublist(start, end);

  final frontCards = onThisPage.map((e) => e.front).toList();
  final backCards = onThisPage.map((e) => e.back).toList();
  return (
    front: distributeRowCol(cardCountRowCol.rows, cardCountRowCol.columns,
        frontCards, BackStrategy.exact),
    back: distributeRowCol(cardCountRowCol.rows, cardCountRowCol.columns,
        backCards, BackStrategy.invertedRow),
  );
}

/// List of list is row then column.
RowColCards distributeRowCol(int rows, int cols, List<CardEachSingle?> cards,
    BackStrategy backStrategy) {
  RowColCards allRows = [];
  for (var v = 0; v < cards.length; v++) {
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
    allRows[row][target] = cards[v];
  }
  return allRows;
}
