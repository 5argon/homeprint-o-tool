import 'package:homeprint_o_tool/page/layout/back_strategy.dart';

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

  /// The layout maximizes amount of cards rows and column.
  /// This setting will ensure it has at least this much white padding on each card,
  /// while still trying to maximize amount of cards. (So you get reduced rows and columns.)
  SizePhysical perCardPadding;

  /// Print cut line in the white padding on each card.
  /// Value must be no more than [perCardPadding].
  ValuePhysical perCardCutGuideLength;

  /// Defines how would you use the printed paper to make a double sided card.
  LayoutStyle layoutStyle;

  BackStrategy backStrategy;

  ExportRotation exportRotation;

  List<int> skips;

  LayoutData({
    required this.paperSize,
    required this.pixelPerInch,
    required this.marginSize,
    required this.edgeCutGuideSize,
    required this.perCardPadding,
    required this.perCardCutGuideLength,
    required this.layoutStyle,
    required this.backStrategy,
    required this.exportRotation,
    required this.skips,
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

enum ExportRotation {
  none,
  rotate90SameWay,
  rotate90OppositeWay,
}

class SizePhysical {
  late double _widthCm;
  late double _heightCm;

  @override
  operator ==(Object other) {
    if (other is SizePhysical) {
      return _widthCm == other._widthCm && _heightCm == other._heightCm;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(_widthCm, _heightCm);

  double get widthCm => _widthCm;
  double get heightCm => _heightCm;
  double get widthInch => _widthCm / 2.54;
  double get heightInch => _heightCm / 2.54;

  double width(PhysicalSizeType physicalSizeType) {
    return physicalSizeType == PhysicalSizeType.centimeter
        ? _widthCm
        : widthInch;
  }

  double height(PhysicalSizeType physicalSizeType) {
    return physicalSizeType == PhysicalSizeType.centimeter
        ? _heightCm
        : heightInch;
  }

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
