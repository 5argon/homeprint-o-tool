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
}

/// Represent a card, which consists of front side and back side.
class CardEach {
  CardEachSingle? front;
  CardEachSingle? back;

  /// On including this card, automatically duplicates itself by this many count.
  late int amount;

  CardEach(this.front, this.back, this.amount);

  List<CardEach> linearize() {
    return List.filled(amount, this);
  }

  CardEach.fromJson(Map<String, dynamic> json, List<CardEachSingle> instances) {
    amount = json['amount'] ?? 1;

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
      front =
          json['front'] == null ? null : CardEachSingle.fromJson(json['front']);
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
      back =
          json['back'] == null ? null : CardEachSingle.fromJson(json['back']);
    }
  }

  Map<String, dynamic> toJson(List<CardEachSingle> instances) {
    Map<String, dynamic> writeObject = {};
    writeObject['amount'] = amount;
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

  /// Use 0,0 for exactly at center. Use 1,1 or -1,-1 for exactly at the edge.
  late XY contentCenterOffset;

  /// Content area's aspect ratio is always the same as project's card size.
  /// Expand 1 meant that the frame is touching the edge of image. Expand until
  /// the first edge touches.
  late double contentExpand;

  /// Rotation to apply to make this card match with project's card size.
  /// Note that [contentCenterOffset] and [contentExpand] is before rotation.
  late Rotation rotation;

  /// Used to override project-wide synthesized bleed settings per card.
  late PerCardSynthesizedBleed synthesizedBleed;

  /// Optional name but recommended for instances.
  String? name;

  /// In serialized JSON, card that use instances will be linked by this UUID.
  late String uuid;

  CardEachSingle(this.relativeFilePath, this.contentCenterOffset,
      this.contentExpand, this.rotation, this.synthesizedBleed, this.name)
      : uuid = Uuid().v4();

  CardEachSingle.fromJson(Map<String, dynamic> json) {
    relativeFilePath = json['relativeFilePath'];
    contentCenterOffset = XY.fromJson(json['contentCenterOffset']);
    contentExpand = json['contentExpand'];
    rotation = Rotation.values.byName(json['rotation']);
    synthesizedBleed =
        PerCardSynthesizedBleed.values.byName(json['synthesizedBleed']);
    name = json['name'];
    uuid = json['uuid'];
  }

  Map<String, dynamic> toJson() {
    return {
      'relativeFilePath': relativeFilePath,
      'contentCenterOffset': contentCenterOffset.toJson(),
      'contentExpand': contentExpand,
      'rotation': rotation.name,
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

class XY {
  late double x;
  late double y;
  XY(this.x, this.y);

  XY.fromJson(Map<String, dynamic> json) {
    x = json['x'];
    y = json['y'];
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }
}
