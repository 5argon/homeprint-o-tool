import 'layout_struct.dart';

/// Find out how many cards fit in a page in a given layout and card size in
/// terms of rows and columns. (Multiply to get true count.)
({int rows, int columns}) calculateCardCountPerPage(
    LayoutData layoutData, SizePhysical cardSize) {
  final ld = layoutData;
  var cardSpaceHorizontal = ld.paperSize.widthCm -
      (2 * (ld.marginSize.widthCm + ld.edgeCutGuideSize.widthCm));
  var cardSpaceVertical = ld.paperSize.heightCm -
      (2 * (ld.marginSize.heightCm + ld.edgeCutGuideSize.heightCm));
  int horizontalCards = cardSpaceHorizontal ~/ cardSize.widthCm;
  int verticalCards = cardSpaceVertical ~/ cardSize.heightCm;
  if (ld.removeOneRow) {
    verticalCards--;
    if (verticalCards < 0) {
      verticalCards = 0;
    }
  }
  if (ld.removeOneColumn) {
    horizontalCards--;
    if (horizontalCards < 0) {
      horizontalCards = 0;
    }
  }
  return (rows: verticalCards, columns: horizontalCards);
}
