import 'package:card_studio/core/save_file.dart';
import 'package:card_studio/page/card/group_member_list_item_one_side.dart';
import 'package:flutter/material.dart';

import '../../core/card.dart';

class GroupMemberListItem extends StatelessWidget {
  final CardEach cardEach;
  final DefinedInstances definedInstances;

  GroupMemberListItem(
      {super.key, required this.cardEach, required this.definedInstances});

  @override
  Widget build(BuildContext context) {
    final numberLabel = SizedBox(
      width: 50,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
        child: Text("#1"),
      ),
    );
    final cardNameBox = TextFormField(
      initialValue: cardEach.name ?? "",
      decoration: InputDecoration(
        labelText: "Card name",
      ),
    );
    final quantityBox = TextFormField(
      initialValue: cardEach.amount.toString(),
      decoration: InputDecoration(
        labelText: "Qty.",
      ),
    );
    final removeButton = IconButton(
      onPressed: () {},
      icon: Icon(Icons.delete),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            SizedBox(width: 100, height: 100, child: Placeholder()),
            SizedBox(width: 100, height: 100, child: Placeholder()),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: cardNameBox),
                      SizedBox(width: 16),
                      SizedBox(
                        width: 50,
                        child: quantityBox,
                      ),
                      SizedBox(width: 16),
                      removeButton,
                      numberLabel,
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GroupMemberListItemOneSide(
                          isBack: false,
                          cardEachSingle: cardEach.front,
                          definedInstances: definedInstances,
                          instance: cardEach.front?.isInstance ?? false,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: GroupMemberListItemOneSide(
                          isBack: true,
                          cardEachSingle: cardEach.back,
                          definedInstances: definedInstances,
                          instance: cardEach.back?.isInstance ?? false,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
