import 'package:card_studio/page/layout/back_strategy.dart';

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

  BackStrategy backStrategy;

  LayoutData({
    required this.paperSize,
    required this.pixelPerInch,
    required this.marginSize,
    required this.edgeCutGuideSize,
    required this.perCardWhitePadding,
    required this.perCardCutGuideLength,
    required this.layoutStyle,
    required this.backStrategy,
  });
}

enum LayoutStyle {
  /// Print two times on the same paper on different side to get double sided card.
  duplex,

  /// Print once and fold after cutting to get double sided card. Folding line is on the longer side of the card.
  foldingLong,

  /// Print once and fold after cutting to get double sided card. Folding line is on the shorter side of the card.
  foldingShort,
}

class SizePhysical {
  late double _widthCm;
  late double _heightCm;

  double get widthCm => _widthCm;
  double get heightCm => _heightCm;
  double get widthInch => _widthCm / 2.54;
  double get heightInch => _heightCm / 2.54;

  SizePhysical(double width, double height, PhysicalSizeType physicalSizeType) {
    if (physicalSizeType == PhysicalSizeType.centimeter) {
      _widthCm = width;
      _heightCm = height;
    } else {
      _widthCm = width * 2.54;
      _heightCm = height * 2.54;
    }
  }

  SizePhysical.fromJson(Map<String, dynamic> json) {
    _widthCm = json['width'];
    _heightCm = json['height'];
  }

  Map<String, dynamic> toJson() {
    return {'width': _widthCm, 'height': _heightCm};
  }
}

enum PhysicalSizeType {
  inch,
  centimeter,
}

class ValuePhysical {
  late double _valueCm;
  double get valueCm => _valueCm;
  double get valueInch => _valueCm / 2.54;

  ValuePhysical(double value, PhysicalSizeType physicalSizeType) {
    if (physicalSizeType == PhysicalSizeType.centimeter) {
      _valueCm = value;
    } else {
      _valueCm = value * 2.54;
    }
  }
}
