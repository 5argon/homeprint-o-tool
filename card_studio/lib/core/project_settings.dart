import 'package:card_studio/page/layout/layout_struct.dart';
import 'package:flutter/foundation.dart';

class ProjectSettings extends ChangeNotifier {
  late SizePhysical cardSize;

  /// Individual card can override this settings.
  late SynthesizedBleed synthesizedBleed;

  ProjectSettings(this.cardSize, this.synthesizedBleed);

  ProjectSettings.fromJson(Map<String, dynamic> json) {
    cardSize = SizePhysical.fromJson(json['cardSize']);
    synthesizedBleed = SynthesizedBleed.values.byName(json['synthesizedBleed']);
  }

  Map<String, dynamic> toJson() {
    return {
      'cardSize': cardSize.toJson(),
      'synthesizedBleed': synthesizedBleed.name,
    };
  }
}

enum SynthesizedBleed {
  mirror,
  none,
}
