import 'package:homeprint_o_tool/core/json.dart';
import 'package:homeprint_o_tool/page/layout/back_arrangement.dart';

enum BleedSettings {
  default_,
  extended,
  cropped,
}

class LayoutData {
  SizePhysical paperSize;

  /// Reserve area where the printer could not print.
  /// Width refer to margin of horizontal side edge.
  /// Height refer to margin of vertical side edge.
  SizePhysical marginSize;

  /// Reserve area next to the margin to print the cut line.
  /// Width refer to cut guide size of of horizontal side edge.
  /// Height refer to cut guide size of of vertical side edge.
  SizePhysical edgeCutGuideSize;

  BackArrangement backArrangement;

  /// Index of the card in each page that picked cards will always skip that spot.
  /// Used to sidestep faulty printer that made mistake at the same spot each page.
  /// Zero-based index. (But user input them as 1-based index in the UI.)
  List<int> skips;

  bool removeOneRow;
  bool removeOneColumn;
  Rotation frontPostRotation;
  Rotation backPostRotation;
  BleedSettings bleedSettings;

  /// Percentage (0.0 to 1.0) of remaining space to fill with generated bleeds.
  /// 1.0 means completely fill the space, which would obscure cut lines.
  double generatedBleedPercentage;

  /// When true and bleedSettings is cropped, increases the effective cutting guide
  /// area by the total gap space between cards, resulting in tightly fitted cards.
  /// This allows users to make fewer cuts as edges are shared between cards.
  bool collapseGaps;

  LayoutData({
    required this.paperSize,
    required this.marginSize,
    required this.edgeCutGuideSize,
    required this.backArrangement,
    required this.skips,
    required this.removeOneRow,
    required this.removeOneColumn,
    required this.frontPostRotation,
    required this.backPostRotation,
    required this.bleedSettings,
    required this.generatedBleedPercentage,
    required this.collapseGaps,
  });

  factory LayoutData.fromJson(Map<String, dynamic> json) {
    return LayoutData(
      paperSize: SizePhysical.fromJson(json['paperSize']),
      marginSize: SizePhysical.fromJson(json['marginSize']),
      edgeCutGuideSize: SizePhysical.fromJson(json['edgeCutGuideSize']),
      backArrangement: BackArrangement.values
          .byName(json['backArrangement'] ?? 'invertedRow'),
      skips: (json['skips'] as List<dynamic>? ?? [])
          .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
          .toList(),
      removeOneRow: json['removeOneRow'] ?? false,
      removeOneColumn: json['removeOneColumn'] ?? false,
      frontPostRotation:
          Rotation.values.byName(json['frontPostRotation'] ?? 'none'),
      backPostRotation:
          Rotation.values.byName(json['backPostRotation'] ?? 'none'),
      bleedSettings: BleedSettings.values.byName(
          json['bleedSettings'] ?? json['generateBleeds'] ?? 'default_'),
      generatedBleedPercentage:
          (json['generatedBleedPercentage'] ?? 0.75).toDouble(),
      collapseGaps: json['collapseGaps'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paperSize': paperSize.toJson(),
      'marginSize': marginSize.toJson(),
      'edgeCutGuideSize': edgeCutGuideSize.toJson(),
      'backArrangement': backArrangement.name,
      'skips': skips,
      'removeOneRow': removeOneRow,
      'removeOneColumn': removeOneColumn,
      'frontPostRotation': frontPostRotation.name,
      'backPostRotation': backPostRotation.name,
      'bleedSettings': bleedSettings.name,
      'generatedBleedPercentage': generatedBleedPercentage,
      'collapseGaps': collapseGaps,
    };
  }
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
