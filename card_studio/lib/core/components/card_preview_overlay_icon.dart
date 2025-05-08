import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/core/card.dart';
import 'package:homeprint_o_tool/core/save_file.dart';

/// An overlay icon component that displays on top of card previews
/// Shows different icons based on card properties:
/// - Pencil icon for custom content area
/// - Chain link icon for linked card faces
class CardPreviewOverlayIcon extends StatelessWidget {
  final CardFace? cardFace;

  const CardPreviewOverlayIcon({
    Key? key,
    required this.cardFace,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardFace = this.cardFace;
    if (cardFace == null) {
      return const SizedBox.shrink();
    }

    // Determine which icon to show
    IconData? iconData;
    String? tooltip;

    // Check if it has a linked card face
    if (cardFace!.isLinkedCardFace) {
      iconData = Icons.link;
      tooltip = "Using Linked Card Face";
    }
    // Check if it has custom content area
    else if (cardFace.useDefaultContentExpand == false) {
      iconData = Icons.edit;
      tooltip = "Custom Content Area";
    }

    // If no special properties, don't show an icon
    if (iconData == null) {
      return const SizedBox.shrink();
    }

    // Show the overlay icon with a semi-transparent background
    return Positioned(
      top: 0,
      left: 0,
      child: Tooltip(
        message: tooltip ?? "",
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Icon(
            iconData,
            size: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
