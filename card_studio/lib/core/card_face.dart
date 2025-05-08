import 'dart:io';
import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/core/json.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class CardFace {
  /// Relative to project's base directory. Not starting with a slash.
  late String relativeFilePath;

  late Alignment contentCenterOffset;
  late bool useDefaultContentCenterOffset;

  /// From 0.0 to 1.0. At 1.0, expand from [contentCenterOffset] until one side
  /// of the card's shape (in project settings) touches any edge.
  late double contentExpand;

  /// Ignore [contentExpand] and use the default value from project settings.
  late bool useDefaultContentExpand;

  /// Rotation to apply to make this card match with project's card size.
  /// Note that [contentCenterOffset] and [contentExpand] is before rotation.
  late Rotation rotation;
  late bool useDefaultRotation;

  /// Cards in a group can be automatically sorted by name.
  String? name;

  /// In serialized JSON, card that use links will be linked by this UUID.
  late String uuid;

  /// This means this object is defined separately in the Linked Card Face tab.
  late bool isLinkedCardFace;

  CardFace(
    this.relativeFilePath,
    this.contentCenterOffset,
    this.contentExpand,
    this.rotation,
    this.name,
    this.useDefaultContentCenterOffset,
    this.useDefaultContentExpand,
    this.useDefaultRotation,
    this.isLinkedCardFace,
  ) : uuid = Uuid().v4();

  CardFace.withRelativeFilePath(String relativeFilePath,
      {bool isLinked = false})
      : this(
          relativeFilePath,
          Alignment.center,
          1.0,
          Rotation.none,
          null,
          true,
          true,
          true,
          isLinked,
        );

  CardFace.emptyLinked() : this.withRelativeFilePath("", isLinked: true);

  CardFace copyChangingRelativeFilePath(String newRelativeFilePath) {
    final newCard = CardFace(
      newRelativeFilePath,
      contentCenterOffset,
      contentExpand,
      rotation,
      name,
      useDefaultContentCenterOffset,
      useDefaultContentExpand,
      useDefaultRotation,
      isLinkedCardFace,
    );
    // Constructor always assign a new UUID, reassign the same UUID.
    newCard.uuid = uuid;
    return newCard;
  }

  CardFace.copyFrom(CardFace cardFace)
      : this(
          cardFace.relativeFilePath,
          cardFace.contentCenterOffset,
          cardFace.contentExpand,
          cardFace.rotation,
          cardFace.name,
          cardFace.useDefaultContentCenterOffset,
          cardFace.useDefaultContentExpand,
          cardFace.useDefaultRotation,
          cardFace.isLinkedCardFace,
        );

  CardFace copyIncludingUuid() {
    final newCard = CardFace(
      relativeFilePath,
      contentCenterOffset,
      contentExpand,
      rotation,
      name,
      useDefaultContentCenterOffset,
      useDefaultContentExpand,
      useDefaultRotation,
      isLinkedCardFace,
    );
    // Constructor always assign a new UUID, reassign the same UUID.
    newCard.uuid = uuid;
    return newCard;
  }

  bool isImageMissing(String baseDirectory) {
    final path = p.join(baseDirectory, relativeFilePath);
    final f = File(path);
    return !f.existsSync();
  }

  double effectiveContentExpand(ProjectSettings projectSettings) {
    if (useDefaultContentExpand) {
      return projectSettings.defaultContentExpand;
    }
    return contentExpand;
  }

  Alignment effectiveContentCenterOffset(ProjectSettings projectSettings) {
    if (useDefaultContentCenterOffset) {
      return projectSettings.defaultContentCenterOffset;
    }
    return contentCenterOffset;
  }

  Rotation effectiveRotation(ProjectSettings projectSettings) {
    if (useDefaultRotation) {
      return projectSettings.defaultRotation;
    }
    return rotation;
  }

  CardFace.fromJson(Map<String, dynamic> json,
      {this.isLinkedCardFace = false}) {
    relativeFilePath = json['relativeFilePath'];
    contentCenterOffset = alignmentFromJson(json['contentCenterOffset']);
    useDefaultContentCenterOffset =
        jsonToBoolOrTrue(json['useDefaultContentCenterOffset']);
    contentExpand = jsonToDouble(json['contentExpand']);
    useDefaultContentExpand = jsonToBoolOrTrue(json['useDefaultContentExpand']);
    rotation = Rotation.values.byName(json['rotation']);
    useDefaultRotation = jsonToBoolOrTrue(json['useDefaultRotation']);
    name = json['name'];
    uuid = json['uuid'] ?? Uuid().v4();
  }

  Map<String, dynamic> toJson() {
    return {
      'relativeFilePath': relativeFilePath,
      'contentCenterOffset': alignmentToJson(contentCenterOffset),
      'useDefaultContentCenterOffset': useDefaultContentCenterOffset,
      'contentExpand': contentExpand,
      'useDefaultContentExpand': useDefaultContentExpand,
      'rotation': rotation.name,
      'useDefaultRotation': useDefaultRotation,
      'name': name,
      'uuid': uuid,
    };
  }
}
