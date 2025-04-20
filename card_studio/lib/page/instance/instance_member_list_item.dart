import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/core/save_file.dart';
import 'package:homeprint_o_tool/page/card/group_member_list_item_one_side.dart';
import 'package:homeprint_o_tool/page/card/single_card_preview.dart';
import 'package:homeprint_o_tool/page/layout/layout_struct.dart';
import 'package:flutter/material.dart';

import '../../core/card.dart';

class InstanceMemberListItem extends StatefulWidget {
  final String basePath;
  final CardEachSingle instanceCardEachSingle;
  final SizePhysical cardSize;
  final DefinedInstances definedInstances;
  final ProjectSettings projectSettings;
  final int order;
  final Function(CardEachSingle card) onInstanceCardChange;
  final Function() onDelete;

  InstanceMemberListItem({
    super.key,
    required this.basePath,
    required this.instanceCardEachSingle,
    required this.cardSize,
    required this.definedInstances,
    required this.projectSettings,
    required this.order,
    required this.onInstanceCardChange,
    required this.onDelete,
  });

  @override
  State<InstanceMemberListItem> createState() => _InstanceMemberListItemState();
}

class _InstanceMemberListItemState extends State<InstanceMemberListItem> {
  late TextEditingController _cardNameController;

  @override
  void initState() {
    super.initState();
    _cardNameController =
        TextEditingController(text: widget.instanceCardEachSingle.name ?? "");
  }

  @override
  void didUpdateWidget(covariant InstanceMemberListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.instanceCardEachSingle.name !=
        widget.instanceCardEachSingle.name) {
      _cardNameController.text = widget.instanceCardEachSingle.name ?? "";
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
        labelText: "Instance Name",
      ),
      onChanged: (value) {
        final newCardEach = widget.instanceCardEachSingle;
        newCardEach.name = value;
        widget.onInstanceCardChange(newCardEach);
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
                  bleedFactor: widget.instanceCardEachSingle
                      .effectiveContentExpand(widget.projectSettings),
                  instance: widget.instanceCardEachSingle.isInstance,
                  cardEachSingle: widget.instanceCardEachSingle,
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
                          cardEachSingle: widget.instanceCardEachSingle,
                          definedInstances: widget.definedInstances,
                          instance: widget.instanceCardEachSingle.isInstance,
                          basePath: widget.basePath,
                          showEditButton: true,
                          onCardEachSingleChange: (card) {
                            widget.onInstanceCardChange(card);
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
