import 'package:homeprint_o_tool/core/card_face.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/core/save_file.dart';
import 'package:flutter/material.dart';
import 'edit_card_face_dialog.dart';

class GroupMemberListItemOneSide extends StatelessWidget {
  final CardFace? cardFace;
  final LinkedCardFaces linkedCardFaces;
  final bool isBack;
  final bool showEditButton;
  final String basePath;
  final ProjectSettings projectSettings;

  /// Returns a new instance always, even assigning a new linked card face,
  /// you get a different instance from those that are originally defined.
  final Function(CardFace? card) onCardChange;
  final bool forLinkedCardFaceTab;

  GroupMemberListItemOneSide({
    super.key,
    this.cardFace,
    required this.linkedCardFaces,
    required this.isBack,
    required this.showEditButton,
    required this.basePath,
    required this.onCardChange,
    required this.forLinkedCardFaceTab,
    required this.projectSettings,
  });

  @override
  Widget build(BuildContext context) {
    Widget linkedIndicator;
    final cardFace = this.cardFace;
    final editButton = IconButton(
      tooltip: "Change this card face",
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return EditCardFaceDialog(
              projectSettings: projectSettings,
              basePath: basePath,
              linkedCardFaces: linkedCardFaces,
              onCardFaceChange: onCardChange,
              initialCard: cardFace,
              forLinkedCardFaceTab: forLinkedCardFaceTab,
            );
          },
        );
      },
      icon: Icon(Icons.edit_square),
    );

    final trashButton = IconButton(
        tooltip: "Remove",
        onPressed: () {
          onCardChange(null); // Assuming an empty card
        },
        icon: Icon(Icons.delete));

    Stack createLinkIconWithNumber(int number) {
      return Stack(
        children: [
          Icon(Icons.link),
          Positioned(
            right: 0,
            bottom: -4,
            child: Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final linkedCardFaceOneAvailable = linkedCardFaces.isNotEmpty;
    final linkedCardFaceTwoAvailable = linkedCardFaces.length > 1;
    final isCurrentlyLinkedCardFaceOne = cardFace != null &&
        linkedCardFaces.isNotEmpty &&
        cardFace == linkedCardFaces[0];
    final isCurrentlyLinkedCardFaceTwo = cardFace != null &&
        linkedCardFaces.length > 1 &&
        cardFace == linkedCardFaces[1];
    final linkedCardFaceOneButton = IconButton(
        tooltip: "Quick assign this card face to the linked card face #1.",
        onPressed: linkedCardFaceOneAvailable
            ? () async {
                final copyOfLinked1 = linkedCardFaces[0].copyIncludingUuid();
                onCardChange(copyOfLinked1);
              }
            : null,
        icon: createLinkIconWithNumber(1));

    final linkedCardFaceTwoButton = IconButton(
        tooltip: "Quick assign this card face to the linked card face #2.",
        onPressed: linkedCardFaceTwoAvailable
            ? () async {
                final copyOfLinked2 = linkedCardFaces[1].copyIncludingUuid();
                onCardChange(copyOfLinked2);
              }
            : null,
        icon: createLinkIconWithNumber(2));
    if (cardFace != null && cardFace.isLinkedCardFace) {
      final index =
          linkedCardFaces.indexWhere((element) => element == cardFace);
      final linkedText = index == -1 ? "Linked" : "Linked #${index + 1}";
      linkedIndicator = Row(
        children: [
          Container(
            color: Theme.of(context).colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
              // Text white on primary
              child: forLinkedCardFaceTab
                  ? null
                  : Text(
                      linkedText,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 4),
        ],
      );
    } else {
      linkedIndicator = Container();
    }
    final Text relativeFilePathText;
    if (cardFace == null) {
      relativeFilePathText = Text(
        "(None)",
        style: TextStyle(fontSize: 12),
      );
    } else if (cardFace.relativeFilePath.isEmpty) {
      relativeFilePathText = Text(
        "(Unassigned)",
        style: TextStyle(fontSize: 12),
      );
    } else {
      final cardFaceName = cardFace.name;
      if (cardFace.isLinkedCardFace &&
          !forLinkedCardFaceTab &&
          cardFaceName != null &&
          cardFaceName.isNotEmpty) {
        relativeFilePathText = Text(
          cardFaceName,
          style: TextStyle(fontSize: 12),
        );
      } else {
        relativeFilePathText = Text(
          cardFace.relativeFilePath,
          style: TextStyle(fontSize: 12),
        );
      }
    }

    final padding = Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: Row(
        children: [
          showEditButton ? editButton : Container(),
          showEditButton && cardFace != null ? trashButton : Container(),
          showEditButton &&
                  isBack &&
                  linkedCardFaceOneAvailable &&
                  !isCurrentlyLinkedCardFaceOne
              ? linkedCardFaceOneButton
              : Container(),
          showEditButton &&
                  isBack &&
                  linkedCardFaceTwoAvailable &&
                  !isCurrentlyLinkedCardFaceTwo
              ? linkedCardFaceTwoButton
              : Container(),
          SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                !forLinkedCardFaceTab
                    ? Text(isBack ? "Back Face" : "Front Face",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline))
                    : Container(),
                Row(
                  children: [
                    linkedIndicator,
                    Expanded(child: relativeFilePathText),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return padding;
  }
}
