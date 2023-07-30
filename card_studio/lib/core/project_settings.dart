import 'package:card_studio/page/layout/layout_struct.dart';

class ProjectSettings {
  /// Prefix this path to all the individual card file name to load image from.
  /// This is where the JSON file is. There is no field inside JSON file to specify this.
  /// Moving JSON file and load it again would change this path.
  String baseDirectory;

  SizePhysical cardSize;

  ProjectSettings(this.baseDirectory, this.cardSize);
}
