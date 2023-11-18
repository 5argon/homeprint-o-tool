import 'package:card_studio/core/project_settings.dart';
import 'package:card_studio/page/card/group_list_item.dart';
import 'package:flutter/material.dart';

import '../../core/save_file.dart';

class CardPage extends StatefulWidget {
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
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  final ExpansionTileController controller = ExpansionTileController();
  @override
  Widget build(BuildContext context) {
    final createGroupButton = ElevatedButton(
      onPressed: null,
      child: const Text('Create Group'),
    );
    final sortAllButton = ElevatedButton(
      onPressed: null,
      child: const Text('Sort All'),
    );

    List<GroupListItem> groups = [];
    for (var i = 0; i < widget.definedCards.length; i++) {
      final cardGroup = widget.definedCards[i];
      final gli = GroupListItem(
        includeMode: true,
        basePath: widget.basePath,
        cardGroup: cardGroup,
        cardSize: widget.projectSettings.cardSize,
        definedInstances: widget.definedInstances,
      );
      groups.add(gli);
    }

    final collapseAllButton = ElevatedButton(
      onPressed: null,
      child: const Text('Collapse All'),
    );

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
                SizedBox(
                  width: 8,
                ),
                collapseAllButton,
              ],
            ),
          ),
          Expanded(child: listView),
        ],
      ),
    );
  }
}
