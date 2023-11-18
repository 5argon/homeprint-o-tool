import '../../core/card.dart';

typedef Includes = List<IncludeItem>;

/// CardGroup, CardEach or a page break. Array of this became the output.
class IncludeItem {
  CardGroup? cardGroup;
  CardEach? cardEach;

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

  List<CardEach> linearize() {
    final cardGroup = this.cardGroup;
    final cardEach = this.cardEach;
    final result = <CardEach>[];
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
