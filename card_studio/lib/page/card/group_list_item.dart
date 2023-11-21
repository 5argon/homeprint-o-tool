import 'package:card_studio/core/save_file.dart';
import 'package:card_studio/page/card/group_member_list_item.dart';
import 'package:card_studio/page/layout/layout_struct.dart';
import 'package:flutter/material.dart';

import '../../core/card.dart';

class GroupListItem extends StatelessWidget {
  final bool includeMode;
  final String basePath;
  final CardGroup cardGroup;
  final SizePhysical cardSize;
  final DefinedInstances definedInstances;
  final Function(CardGroup cardGroup) onCardGroupChange;
  final Function() onDelete;

  GroupListItem(
      {super.key,
      required this.includeMode,
      required this.basePath,
      required this.cardGroup,
      required this.cardSize,
      required this.definedInstances,
      required this.onCardGroupChange,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final removeButton = IconButton(
      onPressed: () {
        onDelete();
      },
      icon: Icon(Icons.delete),
    );
    final groupName = TextFormField(
      initialValue: cardGroup.name ?? "",
      decoration: InputDecoration(
        labelText: "Group Name",
      ),
      onChanged: (value) {
        final newCardGroup = cardGroup;
        newCardGroup.name = value;
        onCardGroupChange(newCardGroup);
      },
    );
    final totalQuantity = Text(
        "Cards: ${cardGroup.count()} (Unique: ${cardGroup.uniqueCount()})");
    final addButton = ElevatedButton(
      onPressed: () {
        final newCardGroup = cardGroup;
        newCardGroup.cards.add(CardEach(null, null, 1, ""));
        onCardGroupChange(newCardGroup);
      },
      child: const Text('Add Card'),
    );
    final List<GroupMemberListItem> groupMembers = [];
    for (var i = 0; i < cardGroup.cards.length; i++) {
      final card = cardGroup.cards[i];
      groupMembers.add(GroupMemberListItem(
          basePath: basePath,
          cardEach: card,
          cardSize: cardSize,
          definedInstances: definedInstances,
          onCardEachChange: (card) {
            final newCardGroup = cardGroup;
            newCardGroup.cards[i] = card;
            onCardGroupChange(newCardGroup);
          },
          onDelete: () {
            final newCardGroup = cardGroup;
            newCardGroup.cards.removeAt(i);
            onCardGroupChange(newCardGroup);
          },
          order: i + 1));
    }

    final head = Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(child: groupName),
          totalQuantity,
          removeButton,
        ],
      ),
    );

    final inside = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [...groupMembers, addButton]),
    );

    final expansion = ExpansionTile(title: head, children: [inside]);
    return expansion;
  }
}
