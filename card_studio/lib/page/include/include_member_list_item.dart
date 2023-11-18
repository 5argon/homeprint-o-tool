import 'package:card_studio/core/save_file.dart';
import 'package:card_studio/page/card/group_member_list_item_one_side.dart';
import 'package:card_studio/page/card/single_card_preview.dart';
import 'package:card_studio/page/layout/layout_struct.dart';
import 'package:flutter/material.dart';

import '../../core/card.dart';

class IncludeMemberListItem extends StatelessWidget {
  final String basePath;
  final CardEach cardEach;
  final SizePhysical cardSize;
  final DefinedInstances definedInstances;
  final int order;

  IncludeMemberListItem(
      {super.key,
      required this.basePath,
      required this.cardEach,
      required this.cardSize,
      required this.definedInstances,
      required this.order});

  @override
  Widget build(BuildContext context) {
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
    final quantityBox = Text(
      "x ${cardEach.amount.toString()} Cards",
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
                  bleedFactor: cardEach.front?.contentExpand ?? 1.0,
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
                  bleedFactor: cardEach.back?.contentExpand ?? 1.0,
                  instance: cardEach.back?.isInstance ?? false,
                  cardEachSingle: cardEach.back,
                )),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: cardNameBox),
                      SizedBox(width: 16),
                      SizedBox(
                        width: 50,
                        child: quantityBox,
                      ),
                      SizedBox(width: 16),
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
