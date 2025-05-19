import 'package:homeprint_o_tool/page/layout/layout_data.dart';
import 'package:flutter/material.dart';

import 'package:homeprint_o_tool/core/json.dart';

class ProjectSettings extends ChangeNotifier {
  late SizePhysical cardSize;

  late Alignment defaultContentCenterOffset;
  late double defaultContentExpand;
  late Rotation defaultRotation;

  ProjectSettings(this.cardSize, this.defaultContentCenterOffset,
      this.defaultContentExpand, this.defaultRotation);

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
  }

  Map<String, dynamic> toJson() {
    return {
      'cardSize': cardSize.toJson(),
      'defaultContentCenterOffset': alignmentToJson(defaultContentCenterOffset),
      'defaultContentExpand': defaultContentExpand,
      'defaultRotation': defaultRotation.name,
    };
  }
}
