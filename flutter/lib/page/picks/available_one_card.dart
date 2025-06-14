import 'package:homeprint_o_tool/core/duplex_card.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/core/save_file.dart';
import 'package:homeprint_o_tool/page/picks/include_data.dart';
import 'package:homeprint_o_tool/page/picks/picked_one_card.dart';
import 'package:homeprint_o_tool/page/layout/layout_data.dart';
import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/page/picks/count_number_in_circle.dart';

class AvailabeOneCard extends StatelessWidget {
  final String basePath;
  final DuplexCard cardEach;
  final SizePhysical cardSize;
  final LinkedCardFaces linkedCardFaces;
  final ProjectSettings projectSettings;
  final int outerCount;
  final Includes includes;
  final Function(int)? onAddIncludeItem;
  final int order;

  AvailabeOneCard(
      {super.key,
      required this.basePath,
      required this.cardEach,
      required this.cardSize,
      required this.linkedCardFaces,
      required this.projectSettings,
      required this.outerCount,
      required this.onAddIncludeItem,
      required this.includes,
      required this.order});

  @override
  Widget build(BuildContext context) {
    final Widget addButton;
    final onAddIncludeItem = this.onAddIncludeItem;
    if (onAddIncludeItem != null) {
      addButton = Padding(
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
    } else {
      addButton = Container();
    }
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
    final amount = cardEach.amount;
    final cardsCount = Text(
      "× ${amount.toString()} ${amount > 1 ? "Cards" : "Card"}",
    );
    final List<Widget> extraRenderChildren = [
      countNumberInCircle,
      SizedBox(
        width: 80,
        child: cardsCount,
      ),
      individualAddInCircle,
      SizedBox(width: 16),
      addButton,
      orderLabel,
    ];
    return PickedOneCard(
      basePath: basePath,
      cardEach: cardEach,
      cardSize: cardSize,
      linkedCardFaces: linkedCardFaces,
      projectSettings: projectSettings,
      extraRender: extraRenderChildren,
    );
  }
}
