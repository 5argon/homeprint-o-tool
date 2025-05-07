import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/core/card.dart';
import 'package:homeprint_o_tool/core/form/help_button.dart';

import '../../core/project_settings.dart';
import '../../core/save_file.dart';
import 'linked_card_face_list_item.dart';

class LinkedCardFacePage extends StatelessWidget {
  final String basePath;
  final ProjectSettings projectSettings;
  final LinkedCardFaces linkedCardFaces;
  final DefinedCards definedCards;
  final Function(LinkedCardFaces linkedCardFaces) onLinkedCardFacesChange;
  final Function(DefinedCards definedCards) onDefinedCardsChange;

  LinkedCardFacePage(
      {super.key,
      required this.basePath,
      required this.projectSettings,
      required this.linkedCardFaces,
      required this.definedCards,
      required this.onLinkedCardFacesChange,
      required this.onDefinedCardsChange});

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

        final newCard = CardFace.emptyLinked();
        final newLinkedCardFaces = linkedCardFaces;
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
          "A counter shows how many card faces are currently using each linked card face.",
          "When deleting a linked card face that is being used by cards, a warning dialog will appear with options to either migrate those card faces to another linked card face or remove all references to it.",
          "Linked Card Face index 1 and 2 both receive a special quick assign button in the Cards tab. All other linked card faces have to be browsed from the dropdown inside the modal that edit each card's face.",
        ]),
      ],
    );

    List<LinkedCardFaceListItem> listItem = [];
    for (var i = 0; i < linkedCardFaces.length; i++) {
      final linkedCardFace = linkedCardFaces[i];
      final item = LinkedCardFaceListItem(
        key: Key(linkedCardFace.uuid),
        basePath: basePath,
        projectSettings: projectSettings,
        linkedCardFaces: linkedCardFaces,
        order: i + 1,
        linkedCardFace: linkedCardFace,
        cardSize: projectSettings.cardSize,
        definedCards: definedCards,
        onLinkedCardFaceChange: (newLinkedCardFace) {
          // This is a new instance with same UUID, which breaks cards that were referencing
          // the previous instance. But there is a getter that relinks to this
          // new one by exhaustive search comparing UUID.
          linkedCardFaces[i] = newLinkedCardFace;
          onLinkedCardFacesChange(linkedCardFaces);
        },
        onDelete: () {
          // The delete handling is now managed inside LinkedCardFaceListItem
          // which shows warning dialog and handles migration if needed
          final newLinkedCardFaces = linkedCardFaces;
          newLinkedCardFaces.removeAt(i);
          onLinkedCardFacesChange(newLinkedCardFaces);
          // Also notify that definedCards might have been modified if references were blanked or migrated
          onDefinedCardsChange(definedCards);
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

        final newLinkedCardFaces = List.of(linkedCardFaces);
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
