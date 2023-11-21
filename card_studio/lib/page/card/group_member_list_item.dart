import 'package:card_studio/core/save_file.dart';
import 'package:card_studio/page/card/group_member_list_item_one_side.dart';
import 'package:card_studio/page/card/single_card_preview.dart';
import 'package:card_studio/page/layout/layout_struct.dart';
import 'package:flutter/material.dart';

import '../../core/card.dart';

class GroupMemberListItem extends StatelessWidget {
  final String basePath;
  final CardEach cardEach;
  final SizePhysical cardSize;
  final DefinedInstances definedInstances;
  final int order;
  final Function(CardEach card) onCardEachChange;
  final Function() onDelete;

  GroupMemberListItem({
    super.key,
    required this.basePath,
    required this.cardEach,
    required this.cardSize,
    required this.definedInstances,
    required this.order,
    required this.onCardEachChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final numberLabel = SizedBox(
      width: 50,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
        child: Text("#$order"),
      ),
    );
    final cardNameBox = TextFormField(
      initialValue: cardEach.name ?? "",
      decoration: InputDecoration(
        labelText: "Card name",
      ),
      onChanged: (value) {
        final newCardEach = cardEach;
        newCardEach.name = value;
        onCardEachChange(newCardEach);
      },
    );
    final quantityBox = TextFormField(
      initialValue: cardEach.amount.toString(),
      decoration: InputDecoration(
        labelText: "Copies",
      ),
      onChanged: (value) {
        final newCardEach = cardEach;
        final tryParsed = int.tryParse(value);
        if (tryParsed != null) {
          newCardEach.amount = onCardEachChange(newCardEach);
        }
      },
    );
    final removeButton = IconButton(
      onPressed: () {
        onDelete();
      },
      icon: Icon(Icons.delete),
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
                      removeButton,
                      numberLabel,
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
                          basePath: basePath,
                          showEditButton: true,
                          onCardEachSingleChange: (card) {
                            final newCardEach = cardEach;
                            newCardEach.front = card;
                            onCardEachChange(newCardEach);
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: GroupMemberListItemOneSide(
                          isBack: true,
                          cardEachSingle: cardEach.back,
                          definedInstances: definedInstances,
                          instance: cardEach.back?.isInstance ?? false,
                          basePath: basePath,
                          showEditButton: true,
                          onCardEachSingleChange: (card) {
                            final newCardEach = cardEach;
                            newCardEach.back = card;
                            onCardEachChange(newCardEach);
                          },
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
