import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/page/card/group_list_item.dart';
import 'package:flutter/material.dart';

import '../../core/card.dart';
import '../../core/save_file.dart';

class CardPage extends StatefulWidget {
  final String basePath;
  final ProjectSettings projectSettings;
  final DefinedCards definedCards;
  final DefinedInstances definedInstances;
  final Function(DefinedCards definedCards) onDefinedCardsChange;
  CardPage(
      {super.key,
      required this.basePath,
      required this.projectSettings,
      required this.definedCards,
      required this.definedInstances,
      required this.onDefinedCardsChange});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  final ExpansionTileController controller = ExpansionTileController();
  @override
  Widget build(BuildContext context) {
    final createGroupButton = ElevatedButton(
      onPressed: () {
        final newCardGroup = CardGroup([], "New Group");
        final newDefinedCards = widget.definedCards;
        newDefinedCards.add(newCardGroup);
        widget.onDefinedCardsChange(newDefinedCards);
      },
      child: const Text('Create Group'),
    );
    final sortAllButton = ElevatedButton(
      onPressed: () {
        final newDefinedCards = widget.definedCards;
        newDefinedCards.sort((a, b) {
          final aName = a.name;
          final bName = b.name;
          if (aName == null && bName == null) {
            return 0;
          } else if (aName == null) {
            return -1;
          } else if (bName == null) {
            return 1;
          } else {
            return aName.compareTo(bName);
          }
        });
        for (var df in newDefinedCards) {
          df.cards.sort((a, b) {
            final aName = a.name;
            final bName = b.name;
            if (aName == null && bName == null) {
              return 0;
            } else if (aName == null) {
              return -1;
            } else if (bName == null) {
              return 1;
            } else {
              return aName.compareTo(bName);
            }
          });
        }
        widget.onDefinedCardsChange(newDefinedCards);
      },
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
        projectSettings: widget.projectSettings,
        onCardGroupChange: (cardGroup) {
          final newDefinedCards = widget.definedCards;
          newDefinedCards[i] = cardGroup;
          widget.onDefinedCardsChange(newDefinedCards);
        },
        onDelete: () {
          final newDefinedCards = widget.definedCards;
          newDefinedCards.removeAt(i);
          widget.onDefinedCardsChange(newDefinedCards);
        },
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
