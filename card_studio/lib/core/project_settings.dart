import 'package:card_studio/page/layout/layout_struct.dart';
import 'package:flutter/material.dart';

import 'card.dart';

class ProjectSettings extends ChangeNotifier {
  late SizePhysical cardSize;

  /// Individual card can override this settings.
  late SynthesizedBleed synthesizedBleed;

  late Alignment defaultContentCenterOffset;
  late double defaultContentExpand;
  late Rotation defaultRotation;

  ProjectSettings(this.cardSize, this.synthesizedBleed);

  ProjectSettings.fromJson(Map<String, dynamic> json) {
    cardSize = SizePhysical.fromJson(json['cardSize']);
    synthesizedBleed = SynthesizedBleed.values.byName(json['synthesizedBleed']);
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
      'synthesizedBleed': synthesizedBleed.name,
      'defaultContentCenterOffset': alignmentToJson(defaultContentCenterOffset),
      'defaultContentExpand': defaultContentExpand,
      'defaultRotation': defaultRotation.name,
    };
  }
}

enum SynthesizedBleed {
  mirror,
  none,
}
