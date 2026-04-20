import 'package:homeprint_o_tool/core/card_group.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/core/save_file.dart';
import 'package:homeprint_o_tool/page/layout/layout_data.dart';
import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/page/picks/count_number_in_circle.dart';
import 'package:homeprint_o_tool/page/picks/include_data.dart';
import 'package:homeprint_o_tool/page/picks/available_one_card.dart';

class AvailableListItem extends StatelessWidget {
  final String basePath;
  final CardGroup cardGroup;
  final SizePhysical cardSize;
  final LinkedCardFaces linkedCardFaces;
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
    required this.linkedCardFaces,
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

    final individualAddCount = includes.fold(0, (previousValue, element) {
      // Count individual cards in unlocked groups that reference cards from this group
      if (!element.isLocked) {
        return previousValue +
            element.pickedCards
                .where((p) => cardGroup.cards.any((c) => c == p.duplexCard))
                .fold(0, (p, e) => p + e.effectiveAmount);
      }
      return previousValue;
    });

    final totalQuantityDisplay =
        SizedBox(width: 90, child: Text("× ${cardGroup.count()} Cards"));
    final groupIncludedCount =
        includes.where((element) => element.isFromCardGroup(cardGroup)).length;

    final countNumberInCircle = CountNumberInCircle(value: groupIncludedCount);
    final individualNumberInCircle =
        CountNumberInCircle(value: individualAddCount, plus: true);

    final List<AvailabeOneCard> groupMembers = [];
    for (var i = 0; i < cardGroup.cards.length; i++) {
      final card = cardGroup.cards[i];
      groupMembers.add(AvailabeOneCard(
          basePath: basePath,
          cardEach: card,
          cardSize: cardSize,
          linkedCardFaces: linkedCardFaces,
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
