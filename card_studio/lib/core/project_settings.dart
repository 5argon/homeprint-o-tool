import 'package:card_studio/page/layout/layout_struct.dart';
import 'package:flutter/foundation.dart';

class ProjectSettings extends ChangeNotifier {
  /// Prefix this path to all the individual card file name to load image from.
  /// This is where the JSON file is. There is no field inside JSON file to specify this.
  /// Moving JSON file and load it again would change this path.
  late String baseDirectory;

  late SizePhysical cardSize;

  /// Individual card can override this settings.
  late SynthesizedBleed synthesizedBleed;

  ProjectSettings(this.baseDirectory, this.cardSize, this.synthesizedBleed);

  ProjectSettings.fromJson(this.baseDirectory, Map<String, dynamic> json) {
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
