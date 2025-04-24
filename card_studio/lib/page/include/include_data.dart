import '../../core/card.dart';

typedef Includes = List<IncludeItem>;

int countIncludes(Includes includes) {
  return includes.fold(
      0, (previousValue, element) => previousValue + element.count());
}

bool frontSideOnlyIncludes(Includes includes) {
  for (var i = 0; i < includes.length; i++) {
    final cardGroup = includes[i].cardGroup;
    final cardEach = includes[i].cardEach;
    if (cardGroup != null) {
      for (var j = 0; j < cardGroup.cards.length; j++) {
        final card = cardGroup.cards[j];
        if (card.back != null) {
          return false;
        }
      }
    } else if (cardEach != null) {
      if (cardEach.back != null) {
        return false;
      }
    }
  }
  return true;
}

/// CardGroup, CardEach or a page break. Array of this became the output.
class IncludeItem {
  CardGroup? cardGroup;
  DuplexCard? cardEach;

  bool isGroup() {
    return cardGroup != null;
  }

  /// Copies of group or individual card. If individual card also has amount,
  /// it will be multiplied with this.
  int amount;

  bool pageBreak;

  IncludeItem.cardGroup(this.cardGroup, this.amount) : pageBreak = false;
  IncludeItem.cardEach(this.cardEach, this.amount) : pageBreak = false;
  IncludeItem.pageBreak()
      : cardGroup = null,
        amount = 0,
        pageBreak = true;

  List<DuplexCard> linearize() {
    final cardGroup = this.cardGroup;
    final cardEach = this.cardEach;
    final result = <DuplexCard>[];
    if (cardGroup != null) {
      final linearized = cardGroup.linearize();
      for (var i = 0; i < amount; i++) {
        result.addAll(linearized);
      }
    } else if (cardEach != null) {
      for (var i = 0; i < amount; i++) {
        result.add(cardEach);
      }
    }
    return result;
  }

  /// How many cards for this one include item.
  int count() {
    final cardGroup = this.cardGroup;
    final cardEach = this.cardEach;
    if (cardGroup != null) {
      return cardGroup.count() * amount;
    } else if (cardEach != null) {
      return amount;
    } else {
      return 0;
    }
  }
}
