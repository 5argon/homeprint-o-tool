import 'package:homeprint_o_tool/core/card_group.dart';
import 'package:homeprint_o_tool/core/duplex_card.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/core/save_file.dart';
import 'package:homeprint_o_tool/page/card/group_member_list_item.dart';
import 'package:homeprint_o_tool/page/layout/layout_data.dart';
import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/page/picks/include_data.dart';

import 'package:homeprint_o_tool/page/card/import_from_folder_dialog.dart';

class GroupListItem extends StatelessWidget {
  final bool includeMode;
  final String basePath;
  final CardGroup cardGroup;
  final SizePhysical cardSize;
  final LinkedCardFaces linkedCardFaces;
  final ProjectSettings projectSettings;
  final Function(CardGroup cardGroup) onCardGroupChange;
  final Function() onDelete;
  final Includes includes;
  final Includes skipIncludes;
  final Function(Includes includes)? onIncludesChanged;
  final Function(Includes skipIncludes)? onSkipIncludesChanged;

  GroupListItem({
    super.key,
    required this.includeMode,
    required this.basePath,
    required this.cardGroup,
    required this.cardSize,
    required this.linkedCardFaces,
    required this.projectSettings,
    required this.onCardGroupChange,
    required this.onDelete,
    required this.includes,
    required this.skipIncludes,
    this.onIncludesChanged,
    this.onSkipIncludesChanged,
  });

  // Check if any card in the group is used in the includes
  int _countCardsInPicks() {
    int count = 0;

    // Check if the entire group is directly included
    final isGroupDirectlyIncluded =
        includes.any((includeItem) => includeItem.cardGroup == cardGroup);
    final isGroupDirectlySkipIncluded =
        skipIncludes.any((includeItem) => includeItem.cardGroup == cardGroup);

    if (isGroupDirectlyIncluded || isGroupDirectlySkipIncluded) {
      return cardGroup.cards.length; // All cards are included
    }

    // Count individual cards in includes
    for (var card in cardGroup.cards) {
      bool cardAlreadyCounted = false;

      // Check in includes for individual cards
      for (var includeItem in includes) {
        if (includeItem.cardGroup != null &&
            includeItem.cardGroup != cardGroup) {
          // Check within each card in other groups
          if (includeItem.cardGroup!.cards.any((c) => c == card)) {
            count++;
            cardAlreadyCounted = true;
            break; // Count each card only once
          }
        } else if (includeItem.cardEach == card) {
          // Direct card reference
          count++;
          cardAlreadyCounted = true;
          break; // Count each card only once
        }
      }

      // Check in skipIncludes as well
      if (!cardAlreadyCounted) {
        // Only check skipIncludes if not already counted
        for (var includeItem in skipIncludes) {
          if (includeItem.cardGroup != null &&
              includeItem.cardGroup != cardGroup) {
            if (includeItem.cardGroup!.cards.any((c) => c == card)) {
              count++;
              break;
            }
          } else if (includeItem.cardEach == card) {
            count++;
            break;
          }
        }
      }
    }

    return count;
  }

  // Show warning dialog if any card in the group is in the picks list
  Future<bool> _handleDeleteWithCheck(BuildContext context) async {
    final pickedCardsCount = _countCardsInPicks();

    if (pickedCardsCount > 0 &&
        onIncludesChanged != null &&
        onSkipIncludesChanged != null) {
      // Show warning dialog
      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Warning'),
          content: Text(
              'This group contains $pickedCardsCount ${pickedCardsCount == 1 ? 'card' : 'cards'} that ${pickedCardsCount == 1 ? 'is' : 'are'} currently in your Picks list. Deleting the group will clear your Picks list. Do you want to proceed?'),
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
        onIncludesChanged!([]);
        onSkipIncludesChanged!([]);

        // Show a message about clearing the picks list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Group deleted and Picks list cleared'),
          ),
        );
        return true;
      }
      return false;
    }
    return true; // No cards in picks, proceed with deletion
  }

  @override
  Widget build(BuildContext context) {
    final integrityCheckResult =
        cardGroup.checkIntegrity(basePath, linkedCardFaces);

    final removeButton = IconButton(
      onPressed: () async {
        final shouldProceed = await _handleDeleteWithCheck(context);
        if (shouldProceed) {
          onDelete();
        }
      },
      icon: Icon(Icons.delete),
    );
    final groupName = TextFormField(
      initialValue: cardGroup.name ?? "",
      decoration: InputDecoration(
        labelText: "Group Name",
      ),
      onChanged: (value) {
        final newCardGroup = cardGroup;
        newCardGroup.name = value;
        onCardGroupChange(newCardGroup);
      },
    );
    final normalCount = cardGroup.count();
    final uniqueCount = cardGroup.uniqueCount();

    final groupIcon = Icon(
      Icons.folder,
      size: 32,
    );

    final totalQuantity = normalCount == uniqueCount
        ? Row(
            children: [
              Icon(Icons.style, size: 16), // Card icon
              SizedBox(width: 4), // Spacing between icon and text
              Text("$uniqueCount"),
            ],
          )
        : Row(
            children: [
              Icon(Icons.style, size: 16), // Card icon
              SizedBox(width: 4), // Spacing between icon and text
              Text("$uniqueCount ($normalCount)"),
            ],
          );

    final addButton = ElevatedButton.icon(
      onPressed: () {
        final newCardGroup = cardGroup;
        newCardGroup.cards.insert(0, DuplexCard(null, null, 1, ""));
        onCardGroupChange(newCardGroup);
      },
      icon: const Icon(Icons.add_card),
      label: const Text('Create New Card'),
    );
    final messenger = ScaffoldMessenger.of(context);
    final importFromFolderButton = ElevatedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ImportFromFolderDialog(
              basePath: basePath,
              linkedCardFaces: linkedCardFaces,
              onImport: (folderName, importedCards) {
                final newCardGroup = cardGroup;
                newCardGroup.cards.addAll(importedCards);
                onCardGroupChange(newCardGroup);
                messenger.showSnackBar(SnackBar(
                  content: Text("Imported ${importedCards.length} cards."),
                ));
              },
              importMode: ImportMode.folder,
            );
          },
        );
      },
      icon: const Icon(Icons.folder_open),
      label: const Text('Import From Folder'),
    );

    final importFromFilesButton = ElevatedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ImportFromFolderDialog(
              basePath: basePath,
              linkedCardFaces: linkedCardFaces,
              onImport: (folderName, importedCards) {
                final newCardGroup = cardGroup;
                newCardGroup.cards.addAll(importedCards);
                onCardGroupChange(newCardGroup);
                messenger.showSnackBar(SnackBar(
                  content: Text("Imported ${importedCards.length} cards."),
                ));
              },
              importMode: ImportMode.files,
            );
          },
        );
      },
      icon: const Icon(Icons.upload_file),
      label: const Text('Import From Files'),
    );
    final autoNameCardsButton = ElevatedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            final regexController = TextEditingController();
            return AlertDialog(
              title: const Text('Auto-Name Cards'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                        'Enter a Regex with single group (parentheses) to use that group\'s match result as a card name. Input to the Regex is the front side\'s file path without the extension.'),
                    TextField(
                      controller: regexController,
                      decoration: const InputDecoration(
                        labelText: 'Regex',
                        hintText: r'Example: Same_Prefix_(.*)_Same_Suffix',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final regexPattern = regexController.text;
                    if (regexPattern.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid Regex.'),
                        ),
                      );
                      return;
                    }

                    try {
                      final regex = RegExp(regexPattern);
                      final newCardGroup = cardGroup;
                      for (var i = 0; i < cardGroup.cards.length; i++) {
                        final card = cardGroup.cards[i];
                        final frontFace = card.getFront(linkedCardFaces);
                        final frontFilePathNoExtension = frontFace
                                ?.relativeFilePath
                                .replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '') ??
                            '';
                        final match =
                            regex.firstMatch(frontFilePathNoExtension);
                        if (match != null) {
                          final newCard = card.copy();
                          newCard.name = match.groupCount > 0
                              ? match.group(1) ?? ''
                              : match.group(0) ?? '';
                          newCardGroup.cards[i] = newCard;
                        }
                      }
                      onCardGroupChange(newCardGroup);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Card names updated successfully.'),
                        ),
                      );
                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invalid Regex pattern.'),
                        ),
                      );
                    }
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
      icon: const Icon(Icons.auto_fix_high),
      label: const Text('Auto-Name Cards'),
    );
    final List<GroupMemberListItem> groupMembers = [];
    for (var i = 0; i < cardGroup.cards.length; i++) {
      final card = cardGroup.cards[i];
      groupMembers.add(GroupMemberListItem(
          basePath: basePath,
          card: card,
          cardSize: cardSize,
          linkedCardFaces: linkedCardFaces,
          projectSettings: projectSettings,
          onCardChange: (card) {
            final newCardGroup = cardGroup;
            newCardGroup.cards[i] = card;
            onCardGroupChange(newCardGroup);
          },
          onDelete: () {
            final newCardGroup = cardGroup;
            newCardGroup.cards.removeAt(i);
            onCardGroupChange(newCardGroup);
          },
          order: i + 1,
          includes: includes,
          skipIncludes: skipIncludes,
          onIncludesChanged: onIncludesChanged,
          onSkipIncludesChanged: onSkipIncludesChanged));
    }

    var itemHeader = Row(
      children: [
        if (integrityCheckResult.missingFileCount > 0) ...[
          SizedBox(width: 4),
          Icon(
            Icons.warning,
            color: Theme.of(context).colorScheme.error,
            size: 15,
          ),
          SizedBox(width: 4),
          Text(
            "${integrityCheckResult.missingFileCount} missing file${integrityCheckResult.missingFileCount == 1 ? '' : 's'}",
            style: TextStyle(
                color: Theme.of(context).colorScheme.error, fontSize: 12),
          ),
        ],
      ],
    );

    final head = Column(
      children: [
        itemHeader,
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              groupIcon,
              SizedBox(width: 8),
              Expanded(child: groupName),
              totalQuantity,
              removeButton,
            ],
          ),
        ),
      ],
    );

    final inside = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            addButton,
            importFromFolderButton,
            importFromFilesButton,
            autoNameCardsButton,
          ],
        ),
        ...groupMembers,
      ]),
    );

    final expansion = ExpansionTile(title: head, children: [inside]);
    return expansion;
  }
}
