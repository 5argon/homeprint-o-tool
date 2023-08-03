class LayoutData {
  SizePhysical paperSize;

  /// Transform [paperSize] to output pixels.
  int pixelPerInch;

  /// Reserve area where the printer could not print.
  /// Width refer to margin of horizontal side edge.
  /// Height refer to margin of vertical side edge.
  SizePhysical marginSize;

  /// Reserve area next to the margin to print the cut line.
  /// Width refer to cut guide size of of horizontal side edge.
  /// Height refer to cut guide size of of vertical side edge.
  SizePhysical edgeCutGuideSize;

  /// Force white padding between cards even when they
  /// have enough bleed to fill up the space. In this area it is possible
  /// to print more cut guides if those on the edge are not enough.
  SizePhysical perCardWhitePadding;

  /// Print cut line in the white padding on each card.
  /// Value must be no more than [perCardWhitePadding].
  ValuePhysical perCardCutGuideLength;

  /// Defines how would you use the printed paper to make a double sided card.
  LayoutStyle layoutStyle;

  LayoutData(
    this.paperSize,
    this.pixelPerInch,
    this.marginSize,
    this.edgeCutGuideSize,
    this.perCardWhitePadding,
    this.perCardCutGuideLength,
    this.layoutStyle,
  );
}

enum LayoutStyle {
  /// Print two times on the same paper on different side to get double sided card.
  duplex,

  /// Print once and fold after cutting to get double sided card. Folding line is on the longer side of the card.
  foldingLong,

  /// Print once and fold after cutting to get double sided card. Folding line is on the shorter side of the card.
  foldingShort,

  /// Back side of the card are listed next to the front side. Requires gluing together front and back graphics.
  separate,
}

class SizePhysical {
  late double _widthInch;
  late double _heightInch;

  double get widthInch => _widthInch;
  double get heightInch => _heightInch;

  SizePhysical(double width, double height, PhysicalSizeType physicalSizeType) {
    if (physicalSizeType == PhysicalSizeType.centimeter) {
      _widthInch = width / 2.54;
      _heightInch = height / 2.54;
    }
  }
}

enum PhysicalSizeType {
  inch,
  centimeter,
}

class ValuePhysical {
  late double _valueInch;
  double get valueInch => _valueInch;

  ValuePhysical(double value, PhysicalSizeType physicalSizeType) {
    if (physicalSizeType == PhysicalSizeType.centimeter) {
      _valueInch = value / 2.54;
    }
  }
}

class CardGame {}
