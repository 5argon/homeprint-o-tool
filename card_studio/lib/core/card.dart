import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CardGroup {
  String? name;
  late List<CardEach> cards;
  CardGroup(this.cards, this.name);

  List<CardEach> linearize() {
    final result = <CardEach>[];
    for (var card in cards) {
      result.addAll(card.linearize());
    }
    return result;
  }

  CardGroup.fromJson(
      Map<String, dynamic> json, List<CardEachSingle> instances) {
    name = json['name'];
    cards = [];
    for (var card in json['cards']) {
      cards.add(CardEach.fromJson(card, instances));
    }
  }

  Map<String, dynamic> toJson(List<CardEachSingle> instances) {
    return {
      'name': name,
      'cards': cards.map((e) => e.toJson(instances)).toList(),
    };
  }

  /// How many cards are in this group.
  int count() {
    var total = 0;
    for (var card in cards) {
      total += card.amount;
    }
    return total;
  }

  int uniqueCount() {
    return cards.length;
  }
}

/// Represent a card, which consists of front side and back side.
class CardEach {
  String? name;
  CardEachSingle? front;
  CardEachSingle? back;

  /// On including this card as a group, automatically duplicates itself by this many count.
  /// Individual add will not be affected.
  late int amount;

  CardEach(this.front, this.back, this.amount, this.name);

  List<CardEach> linearize() {
    return List.filled(amount, this);
  }

  CardEach.fromJson(Map<String, dynamic> json, List<CardEachSingle> instances) {
    amount = json['amount'] ?? 1;
    name = json['name'] ?? "";

    final frontInstance = json['frontInstance'];
    if (frontInstance is String) {
      // Search from matching UUID in instances instead.
      for (var instance in instances) {
        if (instance.uuid == frontInstance) {
          front = instance;
          break;
        }
      }
    } else {
      front = json['front'] == null
          ? null
          : CardEachSingle.fromJson(json['front'], isInstance: false);
    }

    final backInstance = json['backInstance'];
    if (backInstance is String) {
      // Search from matching UUID in instances instead.
      for (var instance in instances) {
        if (instance.uuid == backInstance) {
          back = instance;
          break;
        }
      }
    } else {
      back = json['back'] == null
          ? null
          : CardEachSingle.fromJson(json['back'], isInstance: false);
    }
  }

  Map<String, dynamic> toJson(List<CardEachSingle> instances) {
    Map<String, dynamic> writeObject = {};
    writeObject['amount'] = amount;
    writeObject['name'] = name;
    // Match this object by pointer address among instances.
    // If found, write just the UUID instead.
    var foundFront = false;
    var foundBack = false;
    for (var instance in instances) {
      if (!foundFront && identical(instance, front)) {
        writeObject['frontInstance'] = instance.uuid;
        foundFront = true;
        break;
      }
      if (!foundBack && identical(instance, back)) {
        writeObject['backInstance'] = instance.uuid;
        foundBack = true;
        break;
      }
    }
    if (!foundFront) {
      writeObject['front'] = front?.toJson();
    }
    if (!foundBack) {
      writeObject['back'] = back?.toJson();
    }
    return writeObject;
  }
}

class CardEachSingle {
  /// Relative to project's base directory. Not starting with a slash.
  late String relativeFilePath;

  late Alignment contentCenterOffset;
  late bool useDefaultContentCenterOffset;

  /// From 0.0 to 1.0. At 1.0, expand from [contentCenterOffset] until one side
  /// of the card's shape (in project settings) touches any edge.
  late double contentExpand;
  late bool useDefaultContentExpand;

  /// Rotation to apply to make this card match with project's card size.
  /// Note that [contentCenterOffset] and [contentExpand] is before rotation.
  late Rotation rotation;
  late bool useDefaultRotation;

  /// Used to override project-wide synthesized bleed settings per card.
  late PerCardSynthesizedBleed synthesizedBleed;

  /// Optional name but recommended for instances.
  /// Cards in a group can be automatically sorted by name.
  String? name;

  /// In serialized JSON, card that use instances will be linked by this UUID.
  late String uuid;

  late bool isInstance;

  CardEachSingle(
      this.relativeFilePath,
      this.contentCenterOffset,
      this.contentExpand,
      this.rotation,
      this.synthesizedBleed,
      this.name,
      this.useDefaultContentCenterOffset,
      this.useDefaultContentExpand,
      this.useDefaultRotation,
      this.isInstance)
      : uuid = Uuid().v4();

  CardEachSingle.fromJson(Map<String, dynamic> json,
      {this.isInstance = false}) {
    relativeFilePath = json['relativeFilePath'];
    contentCenterOffset = alignmentFromJson(json['contentCenterOffset']);
    useDefaultContentCenterOffset =
        jsonToBoolOrFalse(json['useDefaultContentCenterOffset']);
    contentExpand = jsonToDouble(json['contentExpand']);
    useDefaultContentExpand =
        jsonToBoolOrFalse(json['useDefaultContentExpand']);
    rotation = Rotation.values.byName(json['rotation']);
    useDefaultRotation = jsonToBoolOrFalse(json['useDefaultRotation']);
    synthesizedBleed =
        PerCardSynthesizedBleed.values.byName(json['synthesizedBleed']);
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
      'synthesizedBleed': synthesizedBleed.name,
      'name': name,
      'uuid': uuid,
    };
  }
}

enum Rotation {
  none,
  clockwise90,
  counterClockwise90,
}

enum PerCardSynthesizedBleed {
  projectSettings,
  mirror,
  none,
}

Alignment alignmentFromJson(Map<String, dynamic> json) {
  // if int, cast to double
  final double x = jsonToDouble(json['x']);
  final double y = jsonToDouble(json['y']);
  return Alignment(x, y);
}

double jsonToDouble(dynamic json) {
  if (json is int) {
    return json.toDouble();
  } else if (json is double) {
    return json;
  } else {
    throw Exception("Invalid alignment x value: $json");
  }
}

bool jsonToBoolOrFalse(dynamic json) {
  if (json is bool) {
    return json;
  }
  return false;
}

Map<String, dynamic> alignmentToJson(Alignment alignment) {
  return {
    'x': alignment.x,
    'y': alignment.y,
  };
}
