import 'package:homeprint_o_tool/core/form/help_button.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/page/include/include_data.dart';
import 'package:homeprint_o_tool/page/include/picked_list.dart';
import 'package:homeprint_o_tool/page/layout/layout_logic.dart';
import 'package:homeprint_o_tool/page/layout/layout_struct.dart';
import 'package:homeprint_o_tool/page/review/pagination.dart';
import 'package:flutter/material.dart';
import 'available_list.dart';

import '../../core/save_file.dart';

class PicksPage extends StatelessWidget {
  final String basePath;
  final ProjectSettings projectSettings;
  final LayoutData layoutData;
  final DefinedCards definedCards;
  final LinkedCardFaces linkedCardFaces;
  final Includes includes;
  final Includes skipIncludes;
  final Function(Includes) onIncludesChanged;
  final Function(Includes) onSkipIncludesChanged;
  PicksPage(
      {super.key,
      required this.basePath,
      required this.projectSettings,
      required this.layoutData,
      required this.definedCards,
      required this.linkedCardFaces,
      required this.includes,
      required this.skipIncludes,
      required this.onIncludesChanged,
      required this.onSkipIncludesChanged});

  @override
  Widget build(BuildContext context) {
    final cardCountPerPage =
        calculateCardCountPerPage(layoutData, projectSettings.cardSize);
    final pagination = calculatePagination(
        includes,
        layoutData,
        projectSettings.cardSize,
        cardCountPerPage.rows,
        cardCountPerPage.columns);
    final allCount = countIncludes(includes);

    if (pagination.perPage == 0) {
      return const Text("No cards available");
    }

    final modulo = allCount % pagination.perPage;
    final int lastPageCount;
    if (modulo == 0) {
      if (allCount == 0) {
        lastPageCount = 0;
      } else {
        lastPageCount = pagination.perPage;
      }
    } else {
      lastPageCount = modulo;
    }
    final remaining = pagination.perPage - lastPageCount;

    final lastPageText = [
      TextSpan(
        text: "Last Page : $lastPageCount / ${pagination.perPage} Cards",
      ),
    ];

    final pageHelp = HelpButton(title: "Picks Page", paragraphs: [
      "The Available tab shows all card groups that the project has defined. You can \"pick\" either a group which picks each card inside equal to their quantity, or a single copy of any individual card inside the group.",
      "Each pick appends to the list in \"Picked\" tab sequentially, and cards flow from one page to the next in that order, so the order that you click these picking buttons matters in the final layout.",
    ]);

    if (remaining > 0) {
      lastPageText.add(
        TextSpan(
          text: " ($remaining Card${remaining == 1 ? '' : 's'} Left)",
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }

    final lastPageDebugger = RichText(
      text: TextSpan(
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyMedium?.color),
        children: lastPageText,
      ),
    );

    final allCountText = Row(
      children: [
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              "Total ${pagination.totalPages} Page${pagination.totalPages > 1 ? 's' : ''}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: lastPageDebugger,
          ),
        ),
      ],
    );
    final addEachGroupOnceButton = ElevatedButton(
      onPressed: () {
        final appended = includes.toList();
        appended.addAll(definedCards.map((e) => IncludeItem.cardGroup(e, 1)));
        onIncludesChanged(appended);
      },
      child: const Text('Pick Each Group Once'),
    );
    final clearButton = ElevatedButton(
      onPressed: () {
        onIncludesChanged([]);
        onSkipIncludesChanged([]);
      },
      child: const Text('Clear Picked Cards'),
    );

    final count = includes.fold(0, (p, e) => p + e.count());

    final availableList = AvailableList(
      basePath: basePath,
      projectSettings: projectSettings,
      definedCards: definedCards,
      linkedCardFaces: linkedCardFaces,
      includes: includes,
      skipIncludes: skipIncludes,
      onIncludesChanged: onIncludesChanged,
    );

    final pickedList = PickedList(
      includes: includes,
      onIncludesChanged: onIncludesChanged,
      basePath: basePath,
      cardSize: projectSettings.cardSize,
      linkedCardFaces: linkedCardFaces,
      projectSettings: projectSettings,
      layoutData: layoutData,
    );

    final tabController = Expanded(
        child: DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: "Available"),
              Tab(text: "Picked ($count Cards)"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                availableList,
                pickedList,
              ],
            ),
          ),
        ],
      ),
    ));

    var topButtonRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          addEachGroupOnceButton,
          SizedBox(width: 8),
          clearButton
        ]),
        Row(children: [
          allCountText,
          SizedBox(width: 8),
          pageHelp,
        ]),
      ],
    );
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: topButtonRow,
          ),
          tabController,
        ],
      ),
    );
  }
}
