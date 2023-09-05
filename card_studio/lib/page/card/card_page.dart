import 'package:card_studio/core/project_settings.dart';
import 'package:card_studio/page/card/group_list_item.dart';
import 'package:flutter/material.dart';

import '../../core/save_file.dart';

class CardPage extends StatelessWidget {
  final String basePath;
  final ProjectSettings projectSettings;
  final DefinedCards definedCards;
  final DefinedInstances definedInstances;
  CardPage(
      {super.key,
      required this.basePath,
      required this.projectSettings,
      required this.definedCards,
      required this.definedInstances});

  @override
  Widget build(BuildContext context) {
    final createGroupButton = ElevatedButton(
      onPressed: () {},
      child: const Text('Create Group'),
    );
    final sortAllButton = ElevatedButton(
      onPressed: () {},
      child: const Text('Sort All'),
    );
    List<GroupListItem> groups = definedCards.map<GroupListItem>((e) {
      return GroupListItem(
          basePath: basePath,
          cardGroup: e,
          cardSize: projectSettings.cardSize,
          definedInstances: definedInstances);
    }).toList();
    final listView = ListView(children: groups);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                createGroupButton,
                SizedBox(
                  width: 8,
                ),
                sortAllButton,
              ],
            ),
          ),
          Expanded(child: listView),
        ],
      ),
    );
  }
}
