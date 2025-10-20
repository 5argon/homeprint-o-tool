import 'package:homeprint_o_tool/page/layout/back_arrangement.dart';
import 'package:homeprint_o_tool/page/layout/layout_data.dart';
import 'package:flutter/material.dart';

import 'package:homeprint_o_tool/core/json.dart';

class ProjectSettings extends ChangeNotifier {
  late SizePhysical cardSize;

  late Alignment defaultContentCenterOffset;
  late double defaultContentExpand;
  late Rotation defaultRotation;

  // New: store layout data inside project settings
  late LayoutData layoutSettings;

  ProjectSettings(this.cardSize, this.defaultContentCenterOffset,
      this.defaultContentExpand, this.defaultRotation,
      {LayoutData? layoutSettings}) {
    // If not provided, initialize with a basic default to maintain backward compatibility
    this.layoutSettings = layoutSettings ??
        LayoutData(
          paperSize: SizePhysical(21, 29.7, PhysicalSizeType.centimeter),
          marginSize: SizePhysical(0.25, 0.25, PhysicalSizeType.inch),
          edgeCutGuideSize: SizePhysical(0.5, 0.5, PhysicalSizeType.centimeter),
          backArrangement: BackArrangement.invertedRow,
          skips: [],
          removeOneColumn: false,
          removeOneRow: false,
          frontPostRotation: Rotation.none,
          backPostRotation: Rotation.none,
        );
  }

  ProjectSettings.fromJson(Map<String, dynamic> json) {
    cardSize = SizePhysical.fromJson(json['cardSize']);
    final defaultContentCenterOffsetJson = json['defaultContentCenterOffset'];
    if (defaultContentCenterOffsetJson != null) {
      defaultContentCenterOffset =
          alignmentFromJson(defaultContentCenterOffsetJson);
    } else {
      defaultContentCenterOffset = Alignment.center;
    }
    final defaultContentExpandJson = json['defaultContentExpand'];
    if (defaultContentExpandJson != null) {
      defaultContentExpand = jsonToDouble(defaultContentExpandJson);
    } else {
      defaultContentExpand = 1.0;
    }
    final defaultRotationJson = json['defaultRotation'];
    if (defaultRotationJson != null) {
      defaultRotation = Rotation.values.byName(defaultRotationJson);
    } else {
      defaultRotation = Rotation.none;
    }

    final layoutSettingsJson = json['layoutSettings'];
    if (layoutSettingsJson != null) {
      layoutSettings = LayoutData.fromJson(layoutSettingsJson);
    } else {
      layoutSettings = LayoutData(
        paperSize: SizePhysical(21, 29.7, PhysicalSizeType.centimeter),
        marginSize: SizePhysical(0.25, 0.25, PhysicalSizeType.inch),
        edgeCutGuideSize: SizePhysical(0.5, 0.5, PhysicalSizeType.centimeter),
        backArrangement: BackArrangement.invertedRow,
        skips: [],
        removeOneColumn: false,
        removeOneRow: false,
        frontPostRotation: Rotation.none,
        backPostRotation: Rotation.none,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'cardSize': cardSize.toJson(),
      'defaultContentCenterOffset': alignmentToJson(defaultContentCenterOffset),
      'defaultContentExpand': defaultContentExpand,
      'defaultRotation': defaultRotation.name,
      'layoutSettings': layoutSettings.toJson(),
    };
  }
}
