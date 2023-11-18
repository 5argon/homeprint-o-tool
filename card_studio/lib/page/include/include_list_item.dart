import 'package:card_studio/core/save_file.dart';
import 'package:card_studio/page/layout/layout_struct.dart';
import 'package:flutter/material.dart';

import '../../core/card.dart';
import 'count_number_in_circle.dart';
import 'include_data.dart';
import 'include_member_list_item.dart';

class IncludeListItem extends StatelessWidget {
  final String basePath;
  final CardGroup cardGroup;
  final SizePhysical cardSize;
  final DefinedInstances definedInstances;
  final Includes includes;
  final Includes skipIncludes;
  final Function(int) onGroupQuantityChanged;
  final Function(int, int) onGroupMemberQuantityChanged;

  IncludeListItem({
    super.key,
    required this.basePath,
    required this.cardGroup,
    required this.cardSize,
    required this.definedInstances,
    required this.includes,
    required this.skipIncludes,
    required this.onGroupQuantityChanged,
    required this.onGroupMemberQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final groupName = Text(cardGroup.name ?? "");
    final totalQuantity = Text("x${cardGroup.count()} Cards");
    final groupIncludedCount = includes
        .where((element) => element.cardGroup == cardGroup)
        .fold(0, (p, e) => p + e.amount);

    final countNumberInCircle = CountNumberInCircle(value: groupIncludedCount);

    final List<IncludeMemberListItem> groupMembers = [];
    for (var i = 0; i < cardGroup.cards.length; i++) {
      final card = cardGroup.cards[i];
      groupMembers.add(IncludeMemberListItem(
          basePath: basePath,
          cardEach: card,
          cardSize: cardSize,
          definedInstances: definedInstances,
          order: i + 1));
    }

    final head = Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(child: groupName),
          totalQuantity,
          countNumberInCircle,
        ],
      ),
    );
    final expansion = ExpansionTile(title: head, children: groupMembers);
    return expansion;
  }
}
