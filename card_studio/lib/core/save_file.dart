import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../page/layout/layout_struct.dart';
import 'card.dart';
import 'project_settings.dart';
import 'package:path/path.dart' as p;

/// In the "Cards" tab, each card must be in a group.
typedef DefinedCards = List<CardGroup>;
typedef DefinedInstances = List<CardEachSingle>;

typedef LoadResult = ({SaveFile saveFile, String basePath, String fileName});

class SaveFile {
  ProjectSettings projectSettings;
  DefinedInstances instances;
  DefinedCards cardGroups;

  /// Opens a dialog to choose JSON file. Return `null` if cancel out of dialog.
  static Future<LoadResult?> loadFromFilePicker() async {
    final pickResult = await FilePicker.platform.pickFiles(
      dialogTitle: "Choose a JSON file representing the project.",
      allowedExtensions: ['json'],
    );
    if (pickResult == null) return null;
    final filePath = pickResult.files.single.path;
    if (filePath == null) return null;
    return await loadFromPath(filePath);
  }

  static Future<LoadResult> loadFromPath(String filePath) async {
    final fileToLoad = File(filePath);
    final jsonString = await fileToLoad.readAsString();
    Map<String, dynamic> jsonDynamic = jsonDecode(jsonString);
    final LoadResult result = (
      saveFile: SaveFile.fromJson(jsonDynamic),
      basePath: p.dirname(filePath),
      fileName: p.basename(filePath),
    );
    return result;
  }

  /// [path] includes extension (.json).
  /// Returns file name and directory of the file.
  Future<({String fileName, String baseDirectory})> saveToFile(
      String path) async {
    var file = File(path);
    final jsonString = jsonEncode(toJson());
    await file.writeAsString(jsonString);
    final baseDirectory = p.dirname(path);
    final fileName = p.basename(path);
    return (fileName: fileName, baseDirectory: baseDirectory);
  }

  factory SaveFile.fromJson(Map<String, dynamic> json) {
    final projectSettings = ProjectSettings.fromJson(json['projectSettings']);
    final instances = List<CardEachSingle>.from(
        json['instances'].map((instance) => CardEachSingle.fromJson(instance)));
    final cardGroups = List<CardGroup>.from(json['cardGroups']
        .map((instance) => CardGroup.fromJson(instance, instances)));
    return SaveFile(projectSettings, instances, cardGroups);
  }

  factory SaveFile.hack() {
    var ps = ProjectSettings(
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
    return SaveFile(ps, [
      playerCardBack
    ], [
      CardGroup([peteCard, guitarCard, hardTimesCard], "Default Group")
    ]);
  }

  SaveFile(this.projectSettings, this.instances, this.cardGroups);

  Map<String, dynamic> toJson() {
    return {
      'projectSettings': projectSettings.toJson(),
      'instances': instances.map((e) => e.toJson()).toList(),
      'cardGroups': cardGroups.map((e) => e.toJson(instances)).toList(),
    };
  }
}
