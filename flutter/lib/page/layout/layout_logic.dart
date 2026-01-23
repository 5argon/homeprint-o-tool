import 'package:homeprint_o_tool/page/layout/layout_data.dart';

/// Calculate the effective cutting guide size when collapse gaps is enabled.
/// Returns the original cutting guide size plus the total gap space per side.
({double widthCm, double heightCm}) calculateEffectiveCutGuideSize(
    LayoutData layoutData, SizePhysical cardSize) {
  final ld = layoutData;

  if (!ld.collapseGaps || ld.bleedSettings != BleedSettings.cropped) {
    return (
      widthCm: ld.edgeCutGuideSize.widthCm,
      heightCm: ld.edgeCutGuideSize.heightCm,
    );
  }

  // First, calculate the card count using the SAME logic as calculateCardCountPerPage
  // This ensures we're working with the actual number of cards that will fit
  var cardSpaceHorizontal = ld.paperSize.widthCm -
      (2 * (ld.marginSize.widthCm + ld.edgeCutGuideSize.widthCm));
  var cardSpaceVertical = ld.paperSize.heightCm -
      (2 * (ld.marginSize.heightCm + ld.edgeCutGuideSize.heightCm));

  int horizontalCards = cardSpaceHorizontal ~/ cardSize.widthCm;
  int verticalCards = cardSpaceVertical ~/ cardSize.heightCm;

  // Apply remove row/column settings BEFORE calculating gaps
  // This ensures we calculate the gap from the actual final card count
  if (ld.removeOneRow) {
    verticalCards--;
    if (verticalCards < 0) verticalCards = 0;
  }
  if (ld.removeOneColumn) {
    horizontalCards--;
    if (horizontalCards < 0) horizontalCards = 0;
  }

  if (horizontalCards <= 0 || verticalCards <= 0) {
    return (
      widthCm: ld.edgeCutGuideSize.widthCm,
      heightCm: ld.edgeCutGuideSize.heightCm,
    );
  }

  // Calculate total gap space based on the FINAL card count (after removing rows/columns)
  double totalContentHorizontal = horizontalCards * cardSize.widthCm;
  double totalContentVertical = verticalCards * cardSize.heightCm;
  double gapSpaceHorizontal = cardSpaceHorizontal - totalContentHorizontal;
  double gapSpaceVertical = cardSpaceVertical - totalContentVertical;

  // Add half of the gap space to each side of the cutting guide
  double effectiveWidthCm =
      ld.edgeCutGuideSize.widthCm + (gapSpaceHorizontal / 2);
  double effectiveHeightCm =
      ld.edgeCutGuideSize.heightCm + (gapSpaceVertical / 2);

  return (widthCm: effectiveWidthCm, heightCm: effectiveHeightCm);
}

/// Find out how many cards fit in a page in a given layout and card size in
/// terms of rows and columns. (Multiply to get true count.)
({int rows, int columns}) calculateCardCountPerPage(
    LayoutData layoutData, SizePhysical cardSize) {
  final ld = layoutData;
  final effectiveCutGuide =
      calculateEffectiveCutGuideSize(layoutData, cardSize);

  var cardSpaceHorizontal = ld.paperSize.widthCm -
      (2 * (ld.marginSize.widthCm + effectiveCutGuide.widthCm));
  var cardSpaceVertical = ld.paperSize.heightCm -
      (2 * (ld.marginSize.heightCm + effectiveCutGuide.heightCm));
  int horizontalCards = cardSpaceHorizontal ~/ cardSize.widthCm;
  int verticalCards = cardSpaceVertical ~/ cardSize.heightCm;

  // Only apply remove row/column if collapse gaps is NOT active
  // because when collapse gaps is active, these were already factored into the effective cut guide
  if (!(ld.collapseGaps && ld.bleedSettings == BleedSettings.cropped)) {
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
  }
  return (rows: verticalCards, columns: horizontalCards);
}
