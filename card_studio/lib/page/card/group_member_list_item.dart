import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/core/save_file.dart';
import 'package:homeprint_o_tool/page/card/group_member_list_item_one_side.dart';
import 'package:homeprint_o_tool/page/card/single_card_preview.dart';
import 'package:homeprint_o_tool/page/layout/layout_struct.dart';
import 'package:flutter/material.dart';

import '../../core/card.dart';

class GroupMemberListItem extends StatefulWidget {
  final String basePath;
  final CardEach cardEach;
  final SizePhysical cardSize;
  final DefinedInstances definedInstances;
  final ProjectSettings projectSettings;
  final int order;
  final Function(CardEach card) onCardEachChange;
  final Function() onDelete;

  GroupMemberListItem({
    super.key,
    required this.basePath,
    required this.cardEach,
    required this.cardSize,
    required this.definedInstances,
    required this.projectSettings,
    required this.order,
    required this.onCardEachChange,
    required this.onDelete,
  });

  @override
  State<GroupMemberListItem> createState() => _GroupMemberListItemState();
}

class _GroupMemberListItemState extends State<GroupMemberListItem> {
  late TextEditingController _cardNameController;

  @override
  void initState() {
    super.initState();
    _cardNameController =
        TextEditingController(text: widget.cardEach.name ?? "");
  }

  @override
  void didUpdateWidget(covariant GroupMemberListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cardEach.name != widget.cardEach.name) {
      _cardNameController.text = widget.cardEach.name ?? "";
    }
  }

  @override
  void dispose() {
    _cardNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final numberLabel = SizedBox(
      width: 50,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
        child: Text("#${widget.order}"),
      ),
    );
    final cardNameBox = TextFormField(
      controller: _cardNameController,
      decoration: InputDecoration(
        labelText: "Card Name",
      ),
      onChanged: (value) {
        final newCardEach = widget.cardEach;
        newCardEach.name = value;
        widget.onCardEachChange(newCardEach);
      },
    );
    final quantityBox = TextFormField(
      initialValue: widget.cardEach.amount.toString(),
      decoration: InputDecoration(
        labelText: "Copies",
      ),
      onChanged: (value) {
        final newCardEach = widget.cardEach;
        final tryParsed = int.tryParse(value);
        if (tryParsed != null) {
          newCardEach.amount = tryParsed;
          widget.onCardEachChange(newCardEach);
        }
      },
    );
    final removeButton = IconButton(
      onPressed: () {
        widget.onDelete();
      },
      icon: Icon(Icons.delete),
    );
    final cardIcon = Icon(
      Icons.credit_card,
      size: 32,
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
                  basePath: widget.basePath,
                  cardSize: widget.cardSize,
                  bleedFactor: widget.cardEach.front
                          ?.effectiveContentExpand(widget.projectSettings) ??
                      1.0,
                  instance: widget.cardEach.front?.isInstance ?? false,
                  cardEachSingle: widget.cardEach.front,
                )),
            SizedBox(width: 4),
            SizedBox(
                width: 100,
                height: 100,
                child: SingleCardPreview(
                  basePath: widget.basePath,
                  cardSize: widget.cardSize,
                  bleedFactor: widget.cardEach.back
                          ?.effectiveContentExpand(widget.projectSettings) ??
                      1.0,
                  instance: widget.cardEach.back?.isInstance ?? false,
                  cardEachSingle: widget.cardEach.back,
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
                          showCardSideLabel: true,
                          cardEachSingle: widget.cardEach.front,
                          definedInstances: widget.definedInstances,
                          instance: widget.cardEach.front?.isInstance ?? false,
                          basePath: widget.basePath,
                          showEditButton: true,
                          onCardEachSingleChange: (card) {
                            final newCardEach = widget.cardEach;
                            newCardEach.front = card;
                            widget.onCardEachChange(newCardEach);
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: GroupMemberListItemOneSide(
                          isBack: true,
                          showCardSideLabel: true,
                          cardEachSingle: widget.cardEach.back,
                          definedInstances: widget.definedInstances,
                          instance: widget.cardEach.back?.isInstance ?? false,
                          basePath: widget.basePath,
                          showEditButton: true,
                          onCardEachSingleChange: (card) {
                            final newCardEach = widget.cardEach;
                            newCardEach.back = card;
                            widget.onCardEachChange(newCardEach);
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
