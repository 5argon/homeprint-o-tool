import 'package:card_studio/page/card/group_list_item.dart';
import 'package:flutter/material.dart';

import '../../core/save_file.dart';

class CardPage extends StatelessWidget {
  final DefinedCards definedCards;
  final DefinedInstances definedInstances;
  CardPage(
      {super.key, required this.definedCards, required this.definedInstances});

  @override
  Widget build(BuildContext context) {
    final addButton = ElevatedButton(
      onPressed: () {},
      child: const Text('Add'),
    );
    List<GroupListItem> groups = definedCards.map<GroupListItem>((e) {
      return GroupListItem(cardGroup: e, definedInstances: definedInstances);
    }).toList();
    final listView = ListView(children: groups);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: listView,
    );
  }
}
