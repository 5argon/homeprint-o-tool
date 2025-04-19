import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/core/save_file.dart';
import 'package:homeprint_o_tool/page/layout/layout_struct.dart';
import 'package:flutter/material.dart';

import '../../core/card.dart';
import 'count_number_in_circle.dart';
import 'include_data.dart';
import 'include_member_list_item.dart';

class AvailableListItem extends StatelessWidget {
  final String basePath;
  final CardGroup cardGroup;
  final SizePhysical cardSize;
  final DefinedInstances definedInstances;
  final ProjectSettings projectSettings;
  final Includes includes;
  final Includes skipIncludes;
  final Function(int quantity) onAddGroup;
  final Function(int index, int quantity) onAddIndividual;

  AvailableListItem({
    super.key,
    required this.basePath,
    required this.cardGroup,
    required this.cardSize,
    required this.definedInstances,
    required this.projectSettings,
    required this.includes,
    required this.skipIncludes,
    required this.onAddGroup,
    required this.onAddIndividual,
  });

  @override
  Widget build(BuildContext context) {
    final cardCount = cardGroup.count();
    final addButton = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Tooltip(
        message: "Pick all $cardCount cards in this group.",
        child: ElevatedButton(
          onPressed: () {
            onAddGroup(1);
          },
          child: Icon(Icons.add),
        ),
      ),
    );
    final groupName = Text(cardGroup.name ?? "");

    final individualAddCount = includes.where((element) {
      final ce = element.cardEach;
      // Find if individual card is a part of this group
      if (cardGroup.cards.any((element) => element == ce)) {
        return true;
      } else {
        return false;
      }
    }).fold(0, (previousValue, element) => previousValue + element.count());

    final totalQuantityDisplay =
        SizedBox(width: 90, child: Text("x${cardGroup.count()} Cards"));
    final groupIncludedCount = includes
        .where((element) => element.cardGroup == cardGroup)
        .fold(0, (p, e) => p + e.amount);

    final countNumberInCircle = CountNumberInCircle(value: groupIncludedCount);
    final individualNumberInCircle =
        CountNumberInCircle(value: individualAddCount, plus: true);

    final List<IncludeMemberListItem> groupMembers = [];
    for (var i = 0; i < cardGroup.cards.length; i++) {
      final card = cardGroup.cards[i];
      groupMembers.add(IncludeMemberListItem(
          basePath: basePath,
          cardEach: card,
          cardSize: cardSize,
          definedInstances: definedInstances,
          projectSettings: projectSettings,
          includes: includes,
          onAddIncludeItem: (p0) {
            onAddIndividual(i, p0);
          },
          outerCount: groupIncludedCount,
          order: i + 1));
    }

    final groupIcon = Icon(
      Icons.folder,
      size: 32,
    );
    final head = Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          groupIcon,
          SizedBox(width: 8),
          Expanded(child: groupName),
          countNumberInCircle,
          totalQuantityDisplay,
          individualNumberInCircle,
          addButton,
        ],
      ),
    );
    final expansion = ExpansionTile(title: head, children: groupMembers);
    return expansion;
  }
}
