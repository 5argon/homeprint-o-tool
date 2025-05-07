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
  final Function(CardFace cardFace) onLinkedCardFaceChange;
  final Function() onDelete;
  final DefinedCards definedCards;

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
    required this.definedCards,
  });

  @override
  State<LinkedCardFaceListItem> createState() => _LinkedCardFaceListItemState();
}

class _LinkedCardFaceListItemState extends State<LinkedCardFaceListItem> {
  late TextEditingController _cardNameController;
  final FocusNode _focusNode = FocusNode();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _cardNameController =
        TextEditingController(text: widget.linkedCardFace.name ?? "");

    // Only update the card when focus is lost, not on every character
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        _isEditing = false;
        final nameChangedCard = widget.linkedCardFace.copyIncludingUuid();
        nameChangedCard.name = _cardNameController.text;
        widget.onLinkedCardFaceChange(nameChangedCard);
      }
    });
  }

  @override
  void didUpdateWidget(covariant LinkedCardFaceListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update the controller text if we're not currently editing
    // and if the name actually changed from an external source
    if (!_isEditing &&
        oldWidget.linkedCardFace.name != widget.linkedCardFace.name) {
      _cardNameController.text = widget.linkedCardFace.name ?? "";
    }
  }

  @override
  void dispose() {
    _cardNameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Count how many cards are using this linked card face
  int countCardsUsingThisLinkedFace() {
    int count = 0;
    for (var cardGroup in widget.definedCards) {
      for (var card in cardGroup.cards) {
        // Check both front and back faces
        if (card.getFront(widget.linkedCardFaces)?.uuid ==
            widget.linkedCardFace.uuid) {
          count++;
        }
        if (card.getBack(widget.linkedCardFaces)?.uuid ==
            widget.linkedCardFace.uuid) {
          count++;
        }
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final usageCount = countCardsUsingThisLinkedFace();

    final numberLabel = SizedBox(
      width: 50,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
        child: Text("#${widget.order}"),
      ),
    );
    final cardNameBox = TextFormField(
      controller: _cardNameController,
      focusNode: _focusNode,
      decoration: const InputDecoration(
        labelText: "Name",
      ),
      onChanged: (value) {
        _isEditing = true;
      },
    );
    final removeButton = IconButton(
      onPressed: () {
        if (usageCount > 0) {
          _showDeleteWarningDialog(context, usageCount);
        } else {
          _deleteLinkedCardFace();
        }
      },
      icon: Icon(Icons.delete),
    );
    final cardIcon = Icon(
      Icons.credit_card,
      size: 32,
    );

    // Create usage badge
    final usageBadge = Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "Used: $usageCount",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSecondary,
        ),
      ),
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
                      SizedBox(width: 8),
                      usageBadge,
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
                          basePath: widget.basePath,
                          showEditButton: true,
                          onCardChange: (newCardFace) {
                            // Linked card face is already one face, deleting the face
                            // is changed to just blank the relative path.
                            if (newCardFace == null) {
                              final previousCardFace = widget.linkedCardFace;
                              widget.onLinkedCardFaceChange(previousCardFace
                                  .copyChangingRelativeFilePath(""));
                              return;
                            }
                            widget.onLinkedCardFaceChange(newCardFace);
                          },
                          projectSettings: widget.projectSettings,
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

  /// Show a warning dialog when deleting a linked card face that is in use
  void _showDeleteWarningDialog(BuildContext context, int usageCount) {
    String? selectedOption;
    CardFace? migrationTarget;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text("Warning: This linked card face is in use"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "This linked card face is currently used by $usageCount card face${usageCount > 1 ? 's' : ''}.",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text("Choose what should happen to those cards:"),
                RadioListTile<String>(
                  title: Text("Migrate to another linked card face"),
                  value: "migrate",
                  groupValue: selectedOption,
                  onChanged: (value) {
                    setState(() {
                      selectedOption = value;
                    });
                  },
                ),
                if (selectedOption == "migrate")
                  Padding(
                    padding: const EdgeInsets.only(left: 32.0),
                    child: DropdownButton<CardFace>(
                      hint: Text("Select target linked card face"),
                      value: migrationTarget,
                      items: widget.linkedCardFaces
                          .where(
                              (face) => face.uuid != widget.linkedCardFace.uuid)
                          .map((face) {
                        final String displayName = face.name?.isNotEmpty == true
                            ? face.name!
                            : face.relativeFilePath.isNotEmpty
                                ? face.relativeFilePath
                                : "Unnamed Linked Card Face";
                        return DropdownMenuItem<CardFace>(
                          value: face,
                          child: Text(displayName),
                        );
                      }).toList(),
                      onChanged: (CardFace? value) {
                        setState(() {
                          migrationTarget = value;
                        });
                      },
                    ),
                  ),
                RadioListTile<String>(
                  title: Text("Remove all references (blank those card faces)"),
                  value: "blank",
                  groupValue: selectedOption,
                  onChanged: (value) {
                    setState(() {
                      selectedOption = value;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: (selectedOption != null &&
                        (selectedOption != "migrate" ||
                            migrationTarget != null))
                    ? () {
                        _processDeleteWithOption(
                            selectedOption!, migrationTarget);
                        Navigator.of(context).pop();
                      }
                    : null,
                child: Text("Delete"),
              ),
            ],
          );
        });
      },
    );
  }

  /// Process the deletion based on the selected option
  void _processDeleteWithOption(String option, CardFace? migrationTarget) {
    final String uuid = widget.linkedCardFace.uuid;
    String message;

    if (option == "migrate" && migrationTarget != null) {
      // Migrate all references to the target linked card face
      _migrateReferences(uuid, migrationTarget);
      message =
          "Linked card face deleted. References migrated to ${migrationTarget.name ?? 'selected card face'}.";
    } else {
      // Blank all references
      _blankReferences(uuid);
      message = "Linked card face deleted. All references have been removed.";
    }

    // Delete the linked card face
    widget.onDelete();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  /// Delete the linked card face without showing a warning
  void _deleteLinkedCardFace() {
    widget.onDelete();
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Linked card face deleted."),
      ),
    );
  }

  /// Migrate all references of the deleted linked card face to the target
  void _migrateReferences(String sourceUuid, CardFace targetFace) {
    for (var cardGroup in widget.definedCards) {
      for (var card in cardGroup.cards) {
        // Check and update front face
        final frontFace = card.getFront(widget.linkedCardFaces);
        if (frontFace?.uuid == sourceUuid) {
          card.front = targetFace.copyIncludingUuid();
        }

        // Check and update back face
        final backFace = card.getBack(widget.linkedCardFaces);
        if (backFace?.uuid == sourceUuid) {
          card.back = targetFace.copyIncludingUuid();
        }
      }
    }
  }

  /// Remove all references to the deleted linked card face
  void _blankReferences(String uuid) {
    for (var cardGroup in widget.definedCards) {
      for (var card in cardGroup.cards) {
        // Check and blank front face
        final frontFace = card.getFront(widget.linkedCardFaces);
        if (frontFace?.uuid == uuid) {
          card.front = null;
        }

        // Check and blank back face
        final backFace = card.getBack(widget.linkedCardFaces);
        if (backFace?.uuid == uuid) {
          card.back = null;
        }
      }
    }
  }
}
