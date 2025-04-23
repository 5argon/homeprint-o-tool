import 'dart:io';

import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/core/save_file.dart';
import 'package:homeprint_o_tool/page/card/group_member_list_item.dart';
import 'package:homeprint_o_tool/page/card/import_cards.dart';
import 'package:homeprint_o_tool/page/layout/layout_struct.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '../../core/card.dart';

class GroupListItem extends StatelessWidget {
  final bool includeMode;
  final String basePath;
  final CardGroup cardGroup;
  final SizePhysical cardSize;
  final LinkedCardFaces definedInstances;
  final ProjectSettings projectSettings;
  final Function(CardGroup cardGroup) onCardGroupChange;
  final Function() onDelete;

  GroupListItem(
      {super.key,
      required this.includeMode,
      required this.basePath,
      required this.cardGroup,
      required this.cardSize,
      required this.definedInstances,
      required this.projectSettings,
      required this.onCardGroupChange,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final integrityCheckResult =
        cardGroup.checkIntegrity(basePath, definedInstances);
    final removeButton = IconButton(
      onPressed: () {
        onDelete();
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

    final addButton = ElevatedButton(
      onPressed: () {
        final newCardGroup = cardGroup;
        newCardGroup.cards.insert(0, CardEach(null, null, 1, ""));
        onCardGroupChange(newCardGroup);
      },
      child: const Text('Create New Card'),
    );
    final messenger = ScaffoldMessenger.of(context);
    final createGroupButton = ElevatedButton(
      onPressed: () async {
        final filePath = await FilePicker.platform.getDirectoryPath(
          dialogTitle: "Import every files in the selected folder.",
          initialDirectory: basePath,
        );
        if (filePath != null) {
          if (!filePath.startsWith(basePath)) {
            messenger.showSnackBar(SnackBar(
              content: Text(
                  "Cannot import this folder as it is outside of project's base path."),
            ));
            return;
          }
          final directory = Directory(filePath);
          final entities = await directory.list().toList();
          final extensions = [".png", ".jpg", ".jpeg", ".PNG", ".JPG", ".JPEG"];
          final absolutePaths =
              entities.whereType<File>().map((e) => e.path).where((element) {
            for (var ext in extensions) {
              if (element.endsWith(ext)) {
                return true;
              }
            }
            return false;
          }).toList();
          CardEachSingle? firstInstance;
          if (definedInstances.isNotEmpty) {
            firstInstance = definedInstances.first;
          }
          final relativePaths =
              absolutePaths.map((e) => relative(e, from: basePath)).toList();
          final cards = importCards(relativePaths, firstInstance);
          if (cards.isEmpty) {
            messenger.showSnackBar(SnackBar(
              content: Text("Cannot import any card from the folder."),
            ));
            return;
          }
          final newCardGroup = cardGroup;
          for (var card in cards) {
            newCardGroup.cards.add(card);
          }
          onCardGroupChange(newCardGroup);
          messenger.showSnackBar(SnackBar(
            content: Text("Imported ${cards.length} cards from the folder."),
          ));
        }
      },
      child: const Text('Import From Folder'),
    );
    final autoNameCardsButton = ElevatedButton(
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
                        hintText: r'Example: .*\/(.*)\.\w+$',
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
                        final frontFilePathNoExtension = card
                                .front?.relativeFilePath
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
      child: const Text('Auto-Name Cards'),
    );
    final List<GroupMemberListItem> groupMembers = [];
    for (var i = 0; i < cardGroup.cards.length; i++) {
      final card = cardGroup.cards[i];
      groupMembers.add(GroupMemberListItem(
          basePath: basePath,
          cardEach: card,
          cardSize: cardSize,
          definedInstances: definedInstances,
          projectSettings: projectSettings,
          onCardEachChange: (card) {
            final newCardGroup = cardGroup;
            newCardGroup.cards[i] = card;
            onCardGroupChange(newCardGroup);
          },
          onDelete: () {
            final newCardGroup = cardGroup;
            newCardGroup.cards.removeAt(i);
            onCardGroupChange(newCardGroup);
          },
          order: i + 1));
    }

    var itemHeader = Container(
      width: double.infinity,
      height: 24,
      decoration: BoxDecoration(
        color: Theme.of(context).splashColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12), // Adjust the radius as needed
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
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
              "${integrityCheckResult.missingFileCount} missing files",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error, fontSize: 12),
            ),
          ],
        ],
      ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            addButton,
            SizedBox(
              width: 8,
            ),
            createGroupButton,
            SizedBox(
              width: 8,
            ),
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
