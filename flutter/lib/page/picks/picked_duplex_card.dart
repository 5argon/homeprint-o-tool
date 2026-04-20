import 'package:homeprint_o_tool/core/duplex_card.dart';

/// A picked card wrapping a [DuplexCard] with an effective amount
/// that can be adjusted after picking without modifying the original.
class PickedDuplexCard {
  final DuplexCard duplexCard;

  /// Effective amount for this pick. When picked by group, starts at
  /// [duplexCard.amount]. When picked individually, starts at 1.
  int effectiveAmount;

  PickedDuplexCard({required this.duplexCard, required this.effectiveAmount});

  /// Create from a group pick — effective amount mirrors the original.
  PickedDuplexCard.fromGroup(this.duplexCard)
      : effectiveAmount = duplexCard.amount;

  /// Create from an individual pick — always 1 copy.
  PickedDuplexCard.individual(this.duplexCard) : effectiveAmount = 1;

  /// Expand to a flat list repeating the underlying [DuplexCard]
  /// by [effectiveAmount].
  List<DuplexCard> linearize() {
    return List.filled(effectiveAmount, duplexCard);
  }
}
