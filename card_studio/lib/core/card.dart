import 'dart:io';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/core/save_file.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

class CardGroupCheckIntegrityResult {
  int missingFileCount;

  CardGroupCheckIntegrityResult(
    this.missingFileCount,
  );
}

class CardGroup {
  String? name;
  late List<DuplexCard> cards;
  String id = Uuid().v4();
  CardGroup(this.cards, this.name);

  List<DuplexCard> linearize() {
    final result = <DuplexCard>[];
    for (var card in cards) {
      result.addAll(card.linearize());
    }
    return result;
  }

  CardGroupCheckIntegrityResult checkIntegrity(
      String baseDirectory, LinkedCardFaces linkedCardFaces) {
    var missingFileCount = 0;
    for (var card in cards) {
      final front = card.getFront(linkedCardFaces);
      final back = card.getBack(linkedCardFaces);
      if (front != null) {
        if (front.isImageMissing(baseDirectory)) {
          missingFileCount++;
        }
      }
      if (back != null) {
        if (back.isImageMissing(baseDirectory)) {
          missingFileCount++;
        }
      }
    }
    return CardGroupCheckIntegrityResult(missingFileCount);
  }

  CardGroup copy() {
    final newCards = <DuplexCard>[];
    for (var card in cards) {
      newCards.add(card.copy());
    }
    return CardGroup(newCards, name);
  }

  CardGroup.fromJson(Map<String, dynamic> json, List<CardFace> cardFaces) {
    name = json['name'];
    cards = [];
    for (var card in json['cards']) {
      cards.add(DuplexCard.fromJson(card, cardFaces));
    }
  }

  Map<String, dynamic> toJson(LinkedCardFaces linkedCardFaces) {
    return {
      'name': name,
      'cards': cards.map((e) => e.toJson(linkedCardFaces)).toList(),
    };
  }

  /// Count to the amount of each card in this group.
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

class DuplexCard {
  CardFace? _front;
  CardFace? _back;

  CardFace? getFront(LinkedCardFaces linkedCardFaces) {
    final front = _front;
    if (front == null) {
      return null;
    }
    if (front.isLinkedCardFace) {
      // Always try to get the latest linked card face by matching UUID.
      for (var linkedCardFace in linkedCardFaces) {
        if (linkedCardFace.uuid == front.uuid) {
          return linkedCardFace;
        }
      }
      return null;
    }
    return front;
  }

  set front(CardFace? front) {
    _front = front;
  }

  CardFace? getBack(LinkedCardFaces linkedCardFaces) {
    final back = _back;
    if (back == null) {
      return null;
    }
    if (back.isLinkedCardFace) {
      // Always try to get the latest linked card face by matching UUID.
      for (var linkedCardFace in linkedCardFaces) {
        if (linkedCardFace.uuid == back.uuid) {
          return linkedCardFace;
        }
      }
      return null;
    }
    return back;
  }

  set back(CardFace? back) {
    _back = back;
  }

  /// On including this card as a group, automatically duplicates itself by this many count.
  /// Individual add will not be affected.
  late int amount;
  String? name;

  DuplexCard(this._front, this._back, this.amount, this.name);

  List<DuplexCard> linearize() {
    return List.filled(amount, this);
  }

  DuplexCard copy() {
    return DuplexCard(_front, _back, amount, name);
  }

  DuplexCard.fromJson(Map<String, dynamic> json, List<CardFace> cardFaces) {
    amount = json['amount'] ?? 1;
    name = json['name'] ?? "";

    {
      final frontLink = json['frontLink'];
      if (frontLink is String) {
        for (var cardFace in cardFaces) {
          if (cardFace.uuid == frontLink) {
            _front = cardFace;
            break;
          }
        }
      } else {
        _front = json['front'] == null
            ? null
            : CardFace.fromJson(json['front'], isLinkedCardFace: false);
      }
    }

    {
      final backLink = json['backLink'];
      if (backLink is String) {
        // Search from matching UUID in instances instead.
        for (var cardFace in cardFaces) {
          if (cardFace.uuid == backLink) {
            _back = cardFace;
            break;
          }
        }
      } else {
        _back = json['back'] == null
            ? null
            : CardFace.fromJson(json['back'], isLinkedCardFace: false);
      }
    }
  }

  Map<String, dynamic> toJson(LinkedCardFaces linkedCardFaces) {
    Map<String, dynamic> writeObject = {};
    writeObject['amount'] = amount;
    writeObject['name'] = name;
    var foundFront = false;
    var foundBack = false;
    for (var cardFace in linkedCardFaces) {
      final front = _front;
      if (!foundFront && front != null && cardFace.uuid == front.uuid) {
        writeObject['frontLink'] = cardFace.uuid;
        foundFront = true;
        break;
      }
      final back = _back;
      if (!foundBack && back != null && cardFace.uuid == back.uuid) {
        writeObject['backLink'] = cardFace.uuid;
        foundBack = true;
        break;
      }
    }
    if (!foundFront) {
      writeObject['front'] = _front?.toJson();
    }
    if (!foundBack) {
      writeObject['back'] = _back?.toJson();
    }
    return writeObject;
  }
}

/// Remote destination to pull card graphic from.
class Remote {
  RemoteType type;
  String url;
  String? token;

  Remote(this.type, this.url, this.token);
  Remote.fromJson(Map<String, dynamic> json)
      : type = RemoteType.values.byName(json['type']),
        url = json['url'],
        token = json['token'];

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'url': url,
      'token': token,
    };
  }
}

enum RemoteType { unknown, googleDrive }

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

  late Remote? remote;

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
      this.remote)
      : uuid = Uuid().v4();

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
          null,
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
      remote,
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
            cardFace.remote);

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
        remote);
    // Constructor always assign a new UUID, reassign the same UUID.
    newCard.uuid = uuid;
    return newCard;
  }

  bool isImageMissing(String baseDirectory) {
    final f = File(p.join(baseDirectory, relativeFilePath));
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

enum Rotation {
  none,
  clockwise90,
  counterClockwise90,
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

bool jsonToBoolOrTrue(dynamic json) {
  if (json is bool) {
    return json;
  }
  return true;
}

Map<String, dynamic> alignmentToJson(Alignment alignment) {
  return {
    'x': alignment.x,
    'y': alignment.y,
  };
}
