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

enum PhysicalSizeType {
  inch,
  centimeter,
}

class SizePhysical {
  late double _width;
  late double _height;
  late PhysicalSizeType _unit;

  @override
  operator ==(Object other) {
    if (other is SizePhysical) {
      return _width == other._width &&
          _height == other._height &&
          _unit == other._unit;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(_width, _height, _unit);

  double get width => _width;
  double get height => _height;
  PhysicalSizeType get unit => _unit;

  double get widthCm =>
      _unit == PhysicalSizeType.centimeter ? _width : _width * 2.54;
  double get heightCm =>
      _unit == PhysicalSizeType.centimeter ? _height : _height * 2.54;
  double get widthInch =>
      _unit == PhysicalSizeType.inch ? _width : _width / 2.54;
  double get heightInch =>
      _unit == PhysicalSizeType.inch ? _height : _height / 2.54;

  double widthInUnit(PhysicalSizeType unit) {
    if (unit == PhysicalSizeType.centimeter) {
      return widthCm;
    } else {
      return widthInch;
    }
  }

  double heightInUnit(PhysicalSizeType unit) {
    if (unit == PhysicalSizeType.centimeter) {
      return heightCm;
    } else {
      return heightInch;
    }
  }

  SizePhysical(double width, double height, PhysicalSizeType unit) {
    _width = width;
    _height = height;
    _unit = unit;
  }

  SizePhysical.fromJson(Map<String, dynamic> json) {
    _unit = json['unit'] == 'in'
        ? PhysicalSizeType.inch
        : PhysicalSizeType.centimeter;

    // Also allow int from JSON if it was edited in manually somehow.
    if (json['width'] is int) {
      _width = (json['width'] as int).toDouble();
    } else {
      _width = json['width'];
    }
    if (json['height'] is int) {
      _height = (json['height'] as int).toDouble();
    } else {
      _height = json['height'];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'width': _width,
      'height': _height,
      'unit': _unit == PhysicalSizeType.inch ? 'in' : 'cm',
    };
  }
}

class ValuePhysical {
  late double _value;
  late PhysicalSizeType _unit;

  double get value => _value;
  PhysicalSizeType get unit => _unit;

  double get valueCm =>
      _unit == PhysicalSizeType.centimeter ? _value : _value * 2.54;
  double get valueInch =>
      _unit == PhysicalSizeType.inch ? _value : _value / 2.54;

  ValuePhysical(double value, PhysicalSizeType unit) {
    _value = value;
    _unit = unit;
  }

  ValuePhysical.fromJson(Map<String, dynamic> json) {
    _unit = json['unit'] == 'inch'
        ? PhysicalSizeType.inch
        : PhysicalSizeType.centimeter;

    // Also allow int from JSON if it was edited in manually somehow.
    if (json['value'] is int) {
      _value = (json['value'] as int).toDouble();
    } else {
      _value = json['value'];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'value': _value,
      'unit': _unit == PhysicalSizeType.inch ? 'inch' : 'centimeter',
    };
  }
}
