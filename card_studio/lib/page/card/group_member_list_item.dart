import 'package:homeprint_o_tool/core/layout_const.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/core/save_file.dart';
import 'package:homeprint_o_tool/page/card/group_member_list_item_one_side.dart';
import 'package:homeprint_o_tool/page/card/single_card_preview.dart';
import 'package:homeprint_o_tool/page/layout/layout_struct.dart';
import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/page/picks/include_data.dart';

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
  final Includes includes;
  final Includes skipIncludes;
  final Function(Includes includes)? onIncludesChanged;
  final Function(Includes skipIncludes)? onSkipIncludesChanged;

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
    required this.includes,
    required this.skipIncludes,
    this.onIncludesChanged,
    this.onSkipIncludesChanged,
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

  // Check if the card is used in any of the includes
  bool _isCardInPicks() {
    // Check in includes
    for (var includeItem in widget.includes) {
      if (includeItem.cardGroup != null) {
        // Check within each card in the group
        for (var card in includeItem.cardGroup!.cards) {
          if (card == widget.card) {
            return true;
          }
        }
      } else if (includeItem.cardEach == widget.card) {
        // Direct card reference
        return true;
      }
    }

    // Check in skipIncludes as well
    for (var includeItem in widget.skipIncludes) {
      if (includeItem.cardGroup != null) {
        for (var card in includeItem.cardGroup!.cards) {
          if (card == widget.card) {
            return true;
          }
        }
      } else if (includeItem.cardEach == widget.card) {
        return true;
      }
    }

    return false;
  }

  // Show warning dialog if the card is in the picks list
  Future<void> _handleDelete() async {
    if (_isCardInPicks() &&
        widget.onIncludesChanged != null &&
        widget.onSkipIncludesChanged != null) {
      // Show warning dialog
      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Warning'),
          content: const Text(
              'This card is currently in your Picks list. Deleting it will clear your Picks list. Do you want to proceed?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete Anyway'),
            ),
          ],
        ),
      );

      if (shouldProceed == true) {
        // Clear the picks lists
        widget.onIncludesChanged!([]);
        widget.onSkipIncludesChanged!([]);

        // Delete the card
        widget.onDelete();

        // Show snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card deleted and Picks list cleared'),
          ),
        );
      }
    } else {
      // If card is not in picks or callbacks are not provided, just delete
      widget.onDelete();
    }
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
        _handleDelete();
      },
      icon: Icon(Icons.delete),
    );
    final cardIcon = Icon(
      Icons.credit_card,
      size: 32,
    );
    var cardSettingsRow = Row(
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
    );
    final frontFace = widget.card.getFront(widget.linkedCardFaces);
    var frontFaceSide = GroupMemberListItemOneSide(
      isBack: false,
      forLinkedCardFaceTab: false,
      cardFace: frontFace,
      linkedCardFaces: widget.linkedCardFaces,
      basePath: widget.basePath,
      showEditButton: true,
      onCardChange: (card) {
        final newCardEach = widget.card;
        newCardEach.front = card;
        widget.onCardChange(newCardEach);
      },
      projectSettings: widget.projectSettings,
    );
    final backFace = widget.card.getBack(widget.linkedCardFaces);
    var backFaceSide = GroupMemberListItemOneSide(
      isBack: true,
      forLinkedCardFaceTab: false,
      cardFace: backFace,
      linkedCardFaces: widget.linkedCardFaces,
      basePath: widget.basePath,
      showEditButton: true,
      onCardChange: (card) {
        final newCardEach = widget.card;
        newCardEach.back = card;
        widget.onCardChange(newCardEach);
      },
      projectSettings: widget.projectSettings,
    );
    var cardFacesRow = LayoutBuilder(builder: (context, constraints) {
      var lowWidth = constraints.maxWidth < cardListLowWidth;
      if (lowWidth) {
        return Column(
          children: [
            frontFaceSide,
            SizedBox(height: 16),
            backFaceSide,
          ],
        );
      }
      return Row(
        children: [
          Expanded(
            child: frontFaceSide,
          ),
          SizedBox(width: 16),
          Expanded(
            child: backFaceSide,
          )
        ],
      );
    });
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
                  bleedFactor: frontFace
                          ?.effectiveContentExpand(widget.projectSettings) ??
                      1.0,
                  cardFace: frontFace,
                )),
            SizedBox(width: 4),
            SizedBox(
                width: 100,
                height: 100,
                child: SingleCardPreview(
                  basePath: widget.basePath,
                  cardSize: widget.cardSize,
                  bleedFactor: backFace
                          ?.effectiveContentExpand(widget.projectSettings) ??
                      1.0,
                  cardFace: backFace,
                )),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  cardSettingsRow,
                  cardFacesRow,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
