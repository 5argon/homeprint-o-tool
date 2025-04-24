import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'card.dart';
import 'project_settings.dart';
import 'package:path/path.dart' as p;

/// In the "Cards" tab, each card must be in a group.
typedef DefinedCards = List<CardGroup>;

// Force UI to update at all levels if UI receive the top level list.
DefinedCards deepCopyDefinedCards(DefinedCards definedCards) {
  final newList = <CardGroup>[];
  for (var group in definedCards) {
    final newGroup = group.copy();
    newList.add(newGroup);
  }
  return newList;
}

typedef LinkedCardFaces = List<CardEachSingle>;

typedef LoadResult = ({SaveFile saveFile, String basePath, String fileName});

class SaveFile {
  ProjectSettings projectSettings;
  LinkedCardFaces linkedCardFaces;
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
    var linkedCardFaces = <CardEachSingle>[];
    final instancesJson = json['instances'];
    if (instancesJson != null) {
      linkedCardFaces = List<CardEachSingle>.from(instancesJson.map(
          (instance) => CardEachSingle.fromJson(instance, isInstance: true)));
    }
    final linkedCardFacesJson = json['linkedCardFaces'];
    if (linkedCardFacesJson != null) {
      linkedCardFaces = List<CardEachSingle>.from(linkedCardFacesJson.map(
          (linkedCardFace) =>
              CardEachSingle.fromJson(linkedCardFace, isInstance: true)));
    }
    final cardGroups = List<CardGroup>.from(json['cardGroups']
        .map((instance) => CardGroup.fromJson(instance, linkedCardFaces)));
    return SaveFile(projectSettings, linkedCardFaces, cardGroups);
  }

  SaveFile(this.projectSettings, this.linkedCardFaces, this.cardGroups);

  Map<String, dynamic> toJson() {
    return {
      'projectSettings': projectSettings.toJson(),
      'linkedCardFaces': linkedCardFaces.map((e) => e.toJson()).toList(),
      'cardGroups': cardGroups.map((e) => e.toJson(linkedCardFaces)).toList(),
    };
  }
}
