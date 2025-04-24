import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/core/card.dart';
import 'package:homeprint_o_tool/core/form/help_button.dart';

import '../../core/project_settings.dart';
import '../../core/save_file.dart';
import 'linked_card_face_list_item.dart';

class LinkedCardFacePage extends StatelessWidget {
  final String basePath;
  final ProjectSettings projectSettings;
  final LinkedCardFaces linkCardFaces;
  final Function(LinkedCardFaces linkedCardFaces) onLinkedCardFacesChange;

  LinkedCardFacePage({
    super.key,
    required this.basePath,
    required this.projectSettings,
    required this.linkCardFaces,
    required this.onLinkedCardFacesChange,
  });

  @override
  Widget build(BuildContext context) {
    final createLinkedCardFaceButton = ElevatedButton(
      onPressed: () {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.removeCurrentSnackBar();
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Created a new linked card face.'),
          ),
        );

        final newCard = CardFace.empty();
        final newLinkedCardFaces = linkCardFaces;
        newLinkedCardFaces.add(newCard);
        onLinkedCardFacesChange(newLinkedCardFaces);
      },
      child: const Text('Create Linked Card Face'),
    );
    final topRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        createLinkedCardFaceButton,
        HelpButton(title: "Linked Card Face", paragraphs: [
          "Normally a card in Cards page consists of 2 faces : The front and back face. Linked card face is a standalone card faces, neither front nor back face, and cannot be printed on its own. Any card's face can link to these linked card faces instead of having its own independent face. Doing so it is possible to update many card faces in the project at once by altering the linked card face.",
          "This feature is mainly used for card backs that are the same throughout the project. You can correct content area or edit a single source image for the change to propagate to all cards that are linked.",
          "If you have linked a face here to something already, deleting it will cause the link to be broken and rendered an error instead."
        ]),
      ],
    );

    List<LinkedCardFaceListItem> listItem = [];
    for (var i = 0; i < linkCardFaces.length; i++) {
      final linkedCardFace = linkCardFaces[i];
      final item = LinkedCardFaceListItem(
        key: Key(linkedCardFace.uuid),
        basePath: basePath,
        projectSettings: projectSettings,
        linkedCardFaces: linkCardFaces,
        order: i + 1,
        linkedCardFace: linkedCardFace,
        cardSize: projectSettings.cardSize,
        onLinkedCardFaceChange: (card) {
          final newLikedCardFaces = linkCardFaces;
          newLikedCardFaces[i] = card;
          onLinkedCardFacesChange(newLikedCardFaces);
        },
        onDelete: () {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          scaffoldMessenger.removeCurrentSnackBar();
          String message = 'Deleted linked card face : ${linkedCardFace.name}';
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(message),
            ),
          );
          final newLinkedCardFaces = linkCardFaces;
          newLinkedCardFaces.removeAt(i);
          onLinkedCardFacesChange(newLinkedCardFaces);
        },
      );
      listItem.add(item);
    }

    final listView = ReorderableListView(
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final removedLinkedCardFace = listItem.removeAt(oldIndex);
        listItem.insert(newIndex, removedLinkedCardFace);

        final newLinkedCardFaces = List.of(linkCardFaces);
        final movedLinkedCardFace = newLinkedCardFaces.removeAt(oldIndex);
        newLinkedCardFaces.insert(newIndex, movedLinkedCardFace);
        onLinkedCardFacesChange(newLinkedCardFaces);
      },
      children: listItem,
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: topRow,
          ),
          Expanded(child: listView),
        ],
      ),
    );
  }
}
