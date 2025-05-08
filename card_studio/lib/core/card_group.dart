import 'package:homeprint_o_tool/core/card_face.dart';
import 'package:homeprint_o_tool/core/duplex_card.dart';
import 'package:homeprint_o_tool/core/save_file.dart';
import 'package:uuid/uuid.dart';

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
