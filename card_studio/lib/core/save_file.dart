import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../page/layout/layout_struct.dart';
import 'card.dart';
import 'project_settings.dart';

class SaveFile {
  ProjectSettings projectSettings;
  List<CardEachSingle> instances;
  List<CardGroup> cardGroups;

  /// Opens a dialog to choose JSON file.
  static Future<SaveFile?> fromFile(String path) async {
    final pickResult = await FilePicker.platform.pickFiles(
      dialogTitle: "Choose a JSON file representing the project.",
      allowedExtensions: ['json'],
    );
    if (pickResult == null) return null;
    final jsonString = pickResult.files.single.toString();
    Map<String, dynamic> jsonDynamic = jsonDecode(jsonString);
    return SaveFile.fromJson(path, jsonDynamic);
  }

  Future saveToFile(String currentBasePath, String? projectFileName) async {
    var file = File('$currentBasePath/$projectFileName.json');
    final jsonString = jsonEncode(toJson());
    await file.writeAsString(jsonString);
  }

  factory SaveFile.fromJson(String baseDirectory, Map<String, dynamic> json) {
    final projectSettings =
        ProjectSettings.fromJson(baseDirectory, json['projectSettings']);
    final instances = List<CardEachSingle>.from(
        json['instances'].map((instance) => CardEachSingle.fromJson(instance)));
    final cardGroups = List<CardGroup>.from(json['cardGroups']
        .map((instance) => CardGroup.fromJson(instance, instances)));
    return SaveFile._internal(projectSettings, instances, cardGroups);
  }

  factory SaveFile.hack() {
    var ps = ProjectSettings(
        "",
        SizePhysical(6.3, 8.15, PhysicalSizeType.centimeter),
        SynthesizedBleed.mirror);

    CardEachSingle playerCardBack = CardEachSingle(
        "coldtoes ppete/_playerback.png",
        XY(0, 0),
        1,
        Rotation.none,
        PerCardSynthesizedBleed.projectSettings,
        "Player Card Back");

    CardEachSingle peteFront = CardEachSingle(
        "coldtoes ppete/046 Parallel Ashcan Pete-1.png",
        XY(0, 0),
        1,
        Rotation.counterClockwise90,
        PerCardSynthesizedBleed.projectSettings,
        null);
    CardEachSingle peteBack = CardEachSingle(
        "coldtoes ppete/046 Parallel Ashcan Pete-2.png",
        XY(0, 0),
        1,
        Rotation.counterClockwise90,
        PerCardSynthesizedBleed.projectSettings,
        null);
    CardEachSingle guitar = CardEachSingle(
        "coldtoes ppete/047 Pete's Guitar-1.png",
        XY(0, 0),
        1,
        Rotation.none,
        PerCardSynthesizedBleed.projectSettings,
        null);
    CardEachSingle hardTimes = CardEachSingle(
        "coldtoes ppete/048 Hard Times-1.png",
        XY(0, 0),
        1,
        Rotation.none,
        PerCardSynthesizedBleed.projectSettings,
        null);
    CardEach peteCard = CardEach(peteFront, peteBack);
    CardEach guitarCard = CardEach(guitar, playerCardBack);
    CardEach hardTimesCard = CardEach(hardTimes, playerCardBack);
    return SaveFile._internal(ps, [
      playerCardBack
    ], [
      CardGroup([peteCard, guitarCard, hardTimesCard], "Default Group")
    ]);
  }

  SaveFile._internal(this.projectSettings, this.instances, this.cardGroups);

  Map<String, dynamic> toJson() {
    return {
      'projectSettings': projectSettings.toJson(),
      'instances': instances.map((e) => e.toJson()).toList(),
      'cardGroups': cardGroups.map((e) => e.toJson(instances)).toList(),
    };
  }
}
