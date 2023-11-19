import 'package:card_studio/core/project_settings.dart';
import 'package:card_studio/page/include/include_data.dart';
import 'package:flutter/material.dart';

import '../../core/save_file.dart';
import 'include_list_item.dart';

class IncludePage extends StatelessWidget {
  final String basePath;
  final ProjectSettings projectSettings;
  final DefinedCards definedCards;
  final DefinedInstances definedInstances;
  final Includes includes;
  final Includes skipIncludes;
  final Function(Includes) onIncludesChanged;
  final Function(Includes) onSkipIncludesChanged;
  IncludePage(
      {super.key,
      required this.basePath,
      required this.projectSettings,
      required this.definedCards,
      required this.definedInstances,
      required this.includes,
      required this.skipIncludes,
      required this.onIncludesChanged,
      required this.onSkipIncludesChanged});

  @override
  Widget build(BuildContext context) {
    final createGroupButton = ElevatedButton(
      onPressed: () {
        final appended = includes.toList();
        appended.addAll(definedCards.map((e) => IncludeItem.cardGroup(e, 1)));
        onIncludesChanged(appended);
      },
      child: const Text('Add All Groups'),
    );
    final clearButton = ElevatedButton(
      onPressed: () {
        onIncludesChanged([]);
        onSkipIncludesChanged([]);
      },
      child: const Text('Clear'),
    );

    final count = includes.fold(0, (p, e) => p + e.count());
    final extraCount = skipIncludes.fold(0, (p, e) => p + e.count());
    final tabs = DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: TabBar(
        tabs: [
          Tab(
            text: "Catalog",
          ),
          Tab(
            text: "Picked ($count)",
          ),
          Tab(
            text: "Extra ($extraCount)",
          ),
        ],
      ),
    );

    List<IncludeListItem> groups = [];
    for (var i = 0; i < definedCards.length; i++) {
      final cardGroup = definedCards[i];
      final gli = IncludeListItem(
        basePath: basePath,
        cardGroup: cardGroup,
        cardSize: projectSettings.cardSize,
        definedInstances: definedInstances,
        includes: includes,
        skipIncludes: skipIncludes,
        onAddGroup: (quantity) {
          final newIncludes = includes.toList();
          newIncludes.add(IncludeItem.cardGroup(cardGroup, quantity));
          onIncludesChanged(newIncludes);
        },
        onAddIndividual: (index, quantity) {
          final newIncludes = includes.toList();
          newIncludes
              .add(IncludeItem.cardEach(cardGroup.cards[index], quantity));
          onIncludesChanged(newIncludes);
        },
      );
      groups.add(gli);
    }

    final listView = ListView(children: groups);
    var buttonRow = Row(
      children: [
        createGroupButton,
        SizedBox(
          width: 8,
        ),
        clearButton,
      ],
    );
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: buttonRow,
          ),
          tabs,
          Expanded(child: listView),
        ],
      ),
    );
  }
}
