import 'package:homeprint_o_tool/core/card_group.dart';
import 'package:homeprint_o_tool/core/duplex_card.dart';
import 'package:homeprint_o_tool/core/save_file.dart';
import 'package:homeprint_o_tool/page/picks/picked_duplex_card.dart';

typedef Includes = List<IncludeItem>;

const String editablePickedGroupName = "Editable Picked Group";

int countIncludes(Includes includes) {
  return includes.fold(
      0, (previousValue, element) => previousValue + element.count());
}

bool frontSideOnlyIncludes(Includes includes, LinkedCardFaces linkedCardFaces) {
  for (var i = 0; i < includes.length; i++) {
    for (var picked in includes[i].pickedCards) {
      if (picked.duplexCard.getBack(linkedCardFaces) != null) {
        return false;
      }
    }
  }
  return true;
}

/// Each IncludeItem is always a group of [PickedDuplexCard], or a page break.
///
/// If [pickedFromCardGroup] is non-null the group is "locked" — it was
/// picked as a card-group and has not been modified. Once any child is
/// changed (quantity, removal, etc.) the reference is nulled and the group
/// becomes an "Editable Picked Group".
class IncludeItem {
  /// Soft reference to the original [CardGroup] this was picked from.
  /// Non-null means the group is still locked (unmodified).
  CardGroup? pickedFromCardGroup;

  /// The picked cards inside this group.
  List<PickedDuplexCard> pickedCards;

  /// User-editable name for this picked group.
  String groupName;

  /// If true, this item is a page break rather than a card group.
  bool pageBreak;

  bool get isLocked => pickedFromCardGroup != null;
  bool get isPageBreak => pageBreak;

  /// Create from a card-group pick. Locked by default.
  IncludeItem.fromCardGroup(CardGroup cardGroup)
      : pickedFromCardGroup = cardGroup,
        groupName = cardGroup.name ?? editablePickedGroupName,
        pageBreak = false,
        pickedCards =
            cardGroup.cards.map((c) => PickedDuplexCard.fromGroup(c)).toList();

  /// Create an empty freely picked (unlocked) group.
  IncludeItem.freelyPicked()
      : pickedFromCardGroup = null,
        groupName = editablePickedGroupName,
        pageBreak = false,
        pickedCards = [];

  /// Create an unlocked group pre-populated with one individual card.
  IncludeItem.withIndividual(DuplexCard card)
      : pickedFromCardGroup = null,
        groupName = editablePickedGroupName,
        pageBreak = false,
        pickedCards = [PickedDuplexCard.individual(card)];

  /// Create a page break item.
  IncludeItem.newPageBreak()
      : pickedFromCardGroup = null,
        groupName = 'Page Break',
        pageBreak = true,
        pickedCards = [];

  /// Deep clone this item (new list of new PickedDuplexCard instances).
  IncludeItem clone() {
    if (pageBreak) return IncludeItem.newPageBreak();
    final cloned = IncludeItem.freelyPicked();
    cloned.groupName = groupName;
    cloned.pickedFromCardGroup = pickedFromCardGroup;
    cloned.pickedCards = pickedCards
        .map((p) => PickedDuplexCard(
            duplexCard: p.duplexCard, effectiveAmount: p.effectiveAmount))
        .toList();
    return cloned;
  }

  /// Unlock this group (make it an Editable Picked Group).
  void unlock() {
    pickedFromCardGroup = null;
  }

  /// Add a card to this (unlocked) group.
  void addCard(DuplexCard card) {
    pickedCards.add(PickedDuplexCard.individual(card));
  }

  /// Remove a card at [index], auto-unlocks.
  void removeCardAt(int index) {
    pickedFromCardGroup = null;
    pickedCards.removeAt(index);
  }

  /// Update effective amount of a card at [index], auto-unlocks.
  void setCardAmount(int index, int amount) {
    pickedFromCardGroup = null;
    pickedCards[index].effectiveAmount = amount;
  }

  /// Sort picked cards by name and merge duplicates (same DuplexCard)
  /// by combining their effective amounts.
  void sortAndMerge() {
    pickedFromCardGroup = null;
    pickedCards.sort(
        (a, b) => (a.duplexCard.name ?? '').compareTo(b.duplexCard.name ?? ''));
    final merged = <PickedDuplexCard>[];
    for (var card in pickedCards) {
      if (merged.isNotEmpty && merged.last.duplexCard == card.duplexCard) {
        merged.last.effectiveAmount += card.effectiveAmount;
      } else {
        merged.add(PickedDuplexCard(
            duplexCard: card.duplexCard,
            effectiveAmount: card.effectiveAmount));
      }
    }
    pickedCards = merged;
  }

  List<DuplexCard> linearize() {
    final result = <DuplexCard>[];
    for (var picked in pickedCards) {
      result.addAll(picked.linearize());
    }
    return result;
  }

  /// Total card count in this group.
  int count() {
    return pickedCards.fold(0, (p, e) => p + e.effectiveAmount);
  }

  /// Whether any picked card in this group references [card].
  bool containsDuplexCard(DuplexCard card) {
    return pickedCards.any((p) => p.duplexCard == card);
  }

  /// Whether this group was originally picked from [cardGroup].
  bool isFromCardGroup(CardGroup cardGroup) {
    return pickedFromCardGroup == cardGroup;
  }
}
