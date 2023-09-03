import 'package:card_studio/core/save_file.dart';
import 'package:card_studio/page/card/group_member_list_item.dart';
import 'package:flutter/material.dart';

import '../../core/card.dart';

class GroupListItem extends StatelessWidget {
  final CardGroup cardGroup;
  final DefinedInstances definedInstances;

  GroupListItem(
      {super.key, required this.cardGroup, required this.definedInstances});

  @override
  Widget build(BuildContext context) {
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
          cardEach: e, definedInstances: definedInstances);
    }).toList();
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [groupName, ...groupMembers, addButton]);
  }
}
