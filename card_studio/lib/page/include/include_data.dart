import '../../core/card.dart';

typedef Includes = List<IncludeItem>;

/// CardGroup or page break. Array of this became the output.
class IncludeItem {
  CardGroup? cardGroup;
  int amount;
  bool pageBreak;

  IncludeItem.cardGroup(this.cardGroup, this.amount) : pageBreak = false;
  IncludeItem.pageBreak()
      : cardGroup = null,
        amount = 0,
        pageBreak = true;
}
