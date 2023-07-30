import '../../core/card.dart';

/// CardGroup or page break. Array of this became the output.
class IncludeItem {
  CardGroup? cardGroup;
  bool pageBreak;

  IncludeItem.cardGroup(CardGroup this.cardGroup) : pageBreak = false;
  IncludeItem.pageBreak() : pageBreak = true;
}
