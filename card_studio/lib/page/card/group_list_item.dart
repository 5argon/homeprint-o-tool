import 'dart:io';

import 'package:card_studio/core/project_settings.dart';
import 'package:card_studio/core/save_file.dart';
import 'package:card_studio/page/card/group_member_list_item.dart';
import 'package:card_studio/page/card/import_cards.dart';
import 'package:card_studio/page/layout/layout_struct.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/card.dart';

class GroupListItem extends StatelessWidget {
  final bool includeMode;
  final String basePath;
  final CardGroup cardGroup;
  final SizePhysical cardSize;
  final DefinedInstances definedInstances;
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
    final totalQuantity = Text(
        "Cards: ${cardGroup.count()} (Unique: ${cardGroup.uniqueCount()})");
    final addButton = ElevatedButton(
      onPressed: () {
        final newCardGroup = cardGroup;
        newCardGroup.cards.add(CardEach(null, null, 1, ""));
        onCardGroupChange(newCardGroup);
      },
      child: const Text('Create New Card'),
    );
    final messenger = ScaffoldMessenger.of(context);
    final addFolderButton = ElevatedButton(
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
          final extensions = [".png", ".jpg", ".jpeg"];
          final paths =
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
          final cards = importCards(paths, firstInstance);
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

    final head = Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(child: groupName),
          totalQuantity,
          removeButton,
        ],
      ),
    );

    final inside = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ...groupMembers,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            addButton,
            SizedBox(
              width: 8,
            ),
            addFolderButton,
          ],
        ),
      ]),
    );

    final expansion = ExpansionTile(title: head, children: [inside]);
    return expansion;
  }
}
