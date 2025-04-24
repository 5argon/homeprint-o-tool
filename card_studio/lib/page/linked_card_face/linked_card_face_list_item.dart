import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/core/save_file.dart';
import 'package:homeprint_o_tool/page/card/group_member_list_item_one_side.dart';
import 'package:homeprint_o_tool/page/card/single_card_preview.dart';
import 'package:homeprint_o_tool/page/layout/layout_struct.dart';
import 'package:flutter/material.dart';

import '../../core/card.dart';

class LinkedCardFaceListItem extends StatefulWidget {
  final String basePath;
  final CardFace linkedCardFace;
  final SizePhysical cardSize;
  final LinkedCardFaces linkedCardFaces;
  final ProjectSettings projectSettings;
  final int order;
  final Function(CardFace card) onLinkedCardFaceChange;
  final Function() onDelete;

  LinkedCardFaceListItem({
    super.key,
    required this.basePath,
    required this.linkedCardFace,
    required this.cardSize,
    required this.linkedCardFaces,
    required this.projectSettings,
    required this.order,
    required this.onLinkedCardFaceChange,
    required this.onDelete,
  });

  @override
  State<LinkedCardFaceListItem> createState() => _LinkedCardFaceListItemState();
}

class _LinkedCardFaceListItemState extends State<LinkedCardFaceListItem> {
  late TextEditingController _cardNameController;

  @override
  void initState() {
    super.initState();
    _cardNameController =
        TextEditingController(text: widget.linkedCardFace.name ?? "");
  }

  @override
  void didUpdateWidget(covariant LinkedCardFaceListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.linkedCardFace.name != widget.linkedCardFace.name) {
      _cardNameController.text = widget.linkedCardFace.name ?? "";
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
        labelText: "Name",
      ),
      onChanged: (value) {
        final newCardEach = widget.linkedCardFace;
        newCardEach.name = value;
        widget.onLinkedCardFaceChange(newCardEach);
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
                  bleedFactor: widget.linkedCardFace
                      .effectiveContentExpand(widget.projectSettings),
                  cardFace: widget.linkedCardFace,
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
                      removeButton,
                      numberLabel,
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GroupMemberListItemOneSide(
                          isBack: false,
                          forLinkedCardFaceTab: true,
                          cardFace: widget.linkedCardFace,
                          linkedCardFaces: widget.linkedCardFaces,
                          linked: widget.linkedCardFace.isLinkedCardFace,
                          basePath: widget.basePath,
                          showEditButton: true,
                          onCardChange: (card) {
                            // Linked Card Face is only one side of a card,
                            // so we can't allow it to disappear on removing
                            // like normal double sided cards.
                            if (card == null) {
                              widget.onLinkedCardFaceChange(
                                  CardFace.emptyLinked());
                            } else {
                              widget.onLinkedCardFaceChange(card);
                            }
                          },
                        ),
                      ),
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
