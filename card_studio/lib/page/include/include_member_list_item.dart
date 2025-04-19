import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/core/save_file.dart';
import 'package:homeprint_o_tool/page/card/group_member_list_item_one_side.dart';
import 'package:homeprint_o_tool/page/card/single_card_preview.dart';
import 'package:homeprint_o_tool/page/include/include_data.dart';
import 'package:homeprint_o_tool/page/layout/layout_struct.dart';
import 'package:flutter/material.dart';

import '../../core/card.dart';
import 'count_number_in_circle.dart';

class IncludeMemberListItem extends StatelessWidget {
  final String basePath;
  final CardEach cardEach;
  final SizePhysical cardSize;
  final DefinedInstances definedInstances;
  final ProjectSettings projectSettings;
  final int outerCount;
  final Includes includes;
  final Function(int) onAddIncludeItem;
  final int order;

  IncludeMemberListItem(
      {super.key,
      required this.basePath,
      required this.cardEach,
      required this.cardSize,
      required this.definedInstances,
      required this.projectSettings,
      required this.outerCount,
      required this.onAddIncludeItem,
      required this.includes,
      required this.order});

  @override
  Widget build(BuildContext context) {
    final addButton = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Tooltip(
        message: "Pick one copy of this card.",
        child: ElevatedButton(
          onPressed: () {
            onAddIncludeItem(1);
          },
          child: Icon(Icons.add),
        ),
      ),
    );
    final countNumberInCircle = CountNumberInCircle(value: outerCount);
    final individualCount = includes
        .where((element) => element.cardEach == cardEach)
        .fold(0, (previousValue, element) => previousValue + element.count());
    final individualAddInCircle =
        CountNumberInCircle(value: individualCount, plus: true);
    final orderLabel = SizedBox(
      width: 50,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
        child: Text("#$order"),
      ),
    );
    final cardNameBox = Text(
      cardEach.name ?? "",
    );
    final amount = cardEach.amount;
    final cardsCount = Text(
      "x ${amount.toString()} ${amount > 1 ? "Cards" : "Card"}",
    );
    final cardIcon = Icon(
      Icons.credit_card,
      size: 20,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            SizedBox(
                width: 100,
                height: 100,
                child: SingleCardPreview(
                  basePath: basePath,
                  cardSize: cardSize,
                  bleedFactor:
                      cardEach.front?.effectiveContentExpand(projectSettings) ??
                          1.0,
                  instance: cardEach.front?.isInstance ?? false,
                  cardEachSingle: cardEach.front,
                )),
            SizedBox(width: 4),
            SizedBox(
                width: 100,
                height: 100,
                child: SingleCardPreview(
                  basePath: basePath,
                  cardSize: cardSize,
                  bleedFactor:
                      cardEach.back?.effectiveContentExpand(projectSettings) ??
                          1.0,
                  instance: cardEach.back?.isInstance ?? false,
                  cardEachSingle: cardEach.back,
                )),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      cardIcon,
                      SizedBox(width: 8),
                      Expanded(child: cardNameBox),
                      SizedBox(width: 16),
                      countNumberInCircle,
                      SizedBox(width: 16),
                      SizedBox(
                        width: 80,
                        child: cardsCount,
                      ),
                      individualAddInCircle,
                      SizedBox(width: 16),
                      addButton,
                      orderLabel,
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
                          showEditButton: false,
                          basePath: basePath,
                          onCardEachSingleChange: (card) {},
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: GroupMemberListItemOneSide(
                          isBack: true,
                          cardEachSingle: cardEach.back,
                          definedInstances: definedInstances,
                          instance: cardEach.back?.isInstance ?? false,
                          showEditButton: false,
                          basePath: basePath,
                          onCardEachSingleChange: (card) {},
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
