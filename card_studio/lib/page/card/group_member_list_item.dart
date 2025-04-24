import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/core/save_file.dart';
import 'package:homeprint_o_tool/page/card/group_member_list_item_one_side.dart';
import 'package:homeprint_o_tool/page/card/single_card_preview.dart';
import 'package:homeprint_o_tool/page/layout/layout_struct.dart';
import 'package:flutter/material.dart';

import '../../core/card.dart';

class GroupMemberListItem extends StatefulWidget {
  final String basePath;
  final DuplexCard card;
  final SizePhysical cardSize;
  final LinkedCardFaces linkedCardFaces;
  final ProjectSettings projectSettings;
  final int order;
  final Function(DuplexCard card) onCardChange;
  final Function() onDelete;

  GroupMemberListItem({
    super.key,
    required this.basePath,
    required this.card,
    required this.cardSize,
    required this.linkedCardFaces,
    required this.projectSettings,
    required this.order,
    required this.onCardChange,
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
    _cardNameController = TextEditingController(text: widget.card.name ?? "");
  }

  @override
  void didUpdateWidget(covariant GroupMemberListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.name != widget.card.name) {
      _cardNameController.text = widget.card.name ?? "";
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
        final newCardEach = widget.card;
        newCardEach.name = value;
        widget.onCardChange(newCardEach);
      },
    );
    final quantityBox = TextFormField(
      initialValue: widget.card.amount.toString(),
      decoration: InputDecoration(
        labelText: "Copies",
      ),
      onChanged: (value) {
        final newCardEach = widget.card;
        final tryParsed = int.tryParse(value);
        if (tryParsed != null) {
          newCardEach.amount = tryParsed;
          widget.onCardChange(newCardEach);
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
                  bleedFactor: widget.card.front
                          ?.effectiveContentExpand(widget.projectSettings) ??
                      1.0,
                  cardFace: widget.card.front,
                )),
            SizedBox(width: 4),
            SizedBox(
                width: 100,
                height: 100,
                child: SingleCardPreview(
                  basePath: widget.basePath,
                  cardSize: widget.cardSize,
                  bleedFactor: widget.card.back
                          ?.effectiveContentExpand(widget.projectSettings) ??
                      1.0,
                  cardFace: widget.card.back,
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
                          forLinkedCardFaceTab: false,
                          cardEachSingle: widget.card.front,
                          linkedCardFaces: widget.linkedCardFaces,
                          linked: widget.card.front?.isLinkedCardFace ?? false,
                          basePath: widget.basePath,
                          showEditButton: true,
                          onCardEachSingleChange: (card) {
                            final newCardEach = widget.card;
                            newCardEach.front = card;
                            widget.onCardChange(newCardEach);
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: GroupMemberListItemOneSide(
                          isBack: true,
                          forLinkedCardFaceTab: false,
                          cardEachSingle: widget.card.back,
                          linkedCardFaces: widget.linkedCardFaces,
                          linked: widget.card.back?.isLinkedCardFace ?? false,
                          basePath: widget.basePath,
                          showEditButton: true,
                          onCardEachSingleChange: (card) {
                            final newCardEach = widget.card;
                            newCardEach.back = card;
                            widget.onCardChange(newCardEach);
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
