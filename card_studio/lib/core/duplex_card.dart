import 'package:homeprint_o_tool/core/card_face.dart';
import 'package:homeprint_o_tool/core/save_file.dart';

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
