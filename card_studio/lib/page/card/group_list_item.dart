import 'package:card_studio/core/save_file.dart';
import 'package:card_studio/page/card/group_member_list_item.dart';
import 'package:card_studio/page/layout/layout_struct.dart';
import 'package:flutter/material.dart';

import '../../core/card.dart';

class GroupListItem extends StatelessWidget {
  final String basePath;
  final CardGroup cardGroup;
  final SizePhysical cardSize;
  final DefinedInstances definedInstances;

  GroupListItem(
      {super.key,
      required this.basePath,
      required this.cardGroup,
      required this.cardSize,
      required this.definedInstances});

  @override
  Widget build(BuildContext context) {
    final removeButton = IconButton(
      onPressed: () {},
      icon: Icon(Icons.delete),
    );
    final groupName = TextFormField(
      initialValue: cardGroup.name ?? "",
      decoration: InputDecoration(
        labelText: "Group name",
      ),
    );
    final addButton = ElevatedButton(
      onPressed: () {},
      child: const Text('Add Card'),
    );
    final groupMembers = cardGroup.cards.map<GroupMemberListItem>((e) {
      return GroupMemberListItem(
          basePath: basePath,
          cardEach: e,
          cardSize: cardSize,
          definedInstances: definedInstances);
    }).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: [
              Expanded(child: groupName),
              removeButton,
            ],
          ),
        ),
        ...groupMembers,
        addButton
      ]),
    );
  }
}
