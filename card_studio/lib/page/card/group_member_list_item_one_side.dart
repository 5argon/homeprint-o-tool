import 'package:homeprint_o_tool/core/save_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:path/path.dart' as p;
import '../../core/card.dart';
import 'edit_card_face_dialog.dart';

class GroupMemberListItemOneSide extends StatelessWidget {
  final CardEachSingle? cardEachSingle;
  final LinkedCardFaces definedInstances;
  final bool isBack;
  final bool instance;
  final bool showEditButton;
  final String basePath;
  final Function(CardEachSingle? card) onCardEachSingleChange;
  final bool instanceSetupMode;

  GroupMemberListItemOneSide({
    super.key,
    this.cardEachSingle,
    required this.definedInstances,
    required this.isBack,
    required this.instance,
    required this.showEditButton,
    required this.basePath,
    required this.onCardEachSingleChange,
    required this.instanceSetupMode,
  });

  @override
  Widget build(BuildContext context) {
    Widget instanceMark;
    final cardEachSingle = this.cardEachSingle;
    final editButton = IconButton(
      tooltip: "Change this card face",
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return EditCardFaceDialog(
              basePath: basePath,
              definedInstances: definedInstances,
              onCardEachSingleChange: onCardEachSingleChange,
              initialCard: cardEachSingle,
            );
          },
        );
      },
      icon: Icon(Icons.edit_square),
    );

    final trashButton = IconButton(
        tooltip: "Remove",
        onPressed: () {
          onCardEachSingleChange(null); // Assuming an empty card
        },
        icon: Icon(Icons.delete));

    Stack createInstanceIconWithNumber(int number) {
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

    final instanceOneAvailable = definedInstances.isNotEmpty;
    final instanceTwoAvailable = definedInstances.length > 1;
    final isCurrentlyInstanceOne = cardEachSingle != null &&
        definedInstances.isNotEmpty &&
        cardEachSingle == definedInstances[0];
    final isCurrentlyInstanceTwo = cardEachSingle != null &&
        definedInstances.length > 1 &&
        cardEachSingle == definedInstances[1];
    final instanceOneButton = IconButton(
        tooltip: "Quick assign this card face to the linked card face #1.",
        onPressed: instanceOneAvailable
            ? () async {
                onCardEachSingleChange(definedInstances[0]);
              }
            : null,
        icon: createInstanceIconWithNumber(1));

    final instanceTwoButton = IconButton(
        tooltip: "Quick assign this card face to the linked card face #2.",
        onPressed: instanceTwoAvailable
            ? () async {
                onCardEachSingleChange(definedInstances[1]);
              }
            : null,
        icon: createInstanceIconWithNumber(2));
    if (cardEachSingle != null && cardEachSingle.isInstance) {
      // Find index of this instance in definedInstances.
      final index =
          definedInstances.indexWhere((element) => element == cardEachSingle);
      final instanceText = index == -1 ? "Linked" : "Linked #${index + 1}";
      instanceMark = Row(
        children: [
          Container(
            color: Theme.of(context).colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
              // Text white on primary
              child: Text(
                instanceText,
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
      instanceMark = Container();
    }
    final Text relativeFilePathText;
    if (cardEachSingle == null) {
      relativeFilePathText = Text(
        "(None)",
        style: TextStyle(fontSize: 12),
      );
    } else if (cardEachSingle.relativeFilePath.isEmpty) {
      relativeFilePathText = Text(
        "(Unassigned)",
        style: TextStyle(fontSize: 12),
      );
    } else {
      relativeFilePathText = Text(
        cardEachSingle.relativeFilePath,
        style: TextStyle(fontSize: 12),
      );
    }

    final padding = Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: Row(
        children: [
          showEditButton ? editButton : Container(),
          showEditButton && cardEachSingle != null ? trashButton : Container(),
          showEditButton &&
                  isBack &&
                  instanceOneAvailable &&
                  !isCurrentlyInstanceOne
              ? instanceOneButton
              : Container(),
          showEditButton &&
                  isBack &&
                  instanceTwoAvailable &&
                  !isCurrentlyInstanceTwo
              ? instanceTwoButton
              : Container(),
          SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                !instanceSetupMode
                    ? Text(isBack ? "Back Face" : "Front Face",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline))
                    : Container(),
                Row(
                  children: [
                    instanceMark,
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

// Open dialog to pick JPG or PNG file, path returned is relative to baseDirectory
Future<String?> pickRelativePath(String basePath) async {
  final pickResult = await FilePicker.platform.pickFiles(
    dialogTitle: "Choose an image file to link its relative path to this card.",
    allowedExtensions: ['png', 'jpg'],
  );
  if (pickResult == null) return null;
  final filePath = pickResult.files.single.path;
  final isUnderBasePath = p.isWithin(basePath, filePath ?? "");
  if (!isUnderBasePath) return null;
  final relativePath = p.relative(filePath ?? "", from: basePath);
  return relativePath;
}
