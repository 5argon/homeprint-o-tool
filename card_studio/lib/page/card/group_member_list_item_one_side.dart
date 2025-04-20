import 'package:homeprint_o_tool/core/save_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:path/path.dart' as p;
import '../../core/card.dart';

class GroupMemberListItemOneSide extends StatelessWidget {
  final CardEachSingle? cardEachSingle;
  final DefinedInstances definedInstances;
  final bool isBack;
  final bool instance;
  final bool showEditButton;
  final String basePath;
  final Function(CardEachSingle card) onCardEachSingleChange;

  GroupMemberListItemOneSide({
    super.key,
    this.cardEachSingle,
    required this.definedInstances,
    required this.isBack,
    required this.instance,
    required this.showEditButton,
    required this.basePath,
    required this.onCardEachSingleChange,
  });

  @override
  Widget build(BuildContext context) {
    Widget instanceMark;
    final cardEachSingle = this.cardEachSingle;
    final editButton = IconButton(
        tooltip: "Select a new image file",
        onPressed: () async {
          final path = await pickRelativePath(basePath);
          if (path == null) return;
          final newCard = CardEachSingle(
              path,
              Alignment.center,
              1,
              Rotation.none,
              PerCardSynthesizedBleed.mirror,
              null,
              true,
              true,
              true,
              false);
          onCardEachSingleChange(newCard);
        },
        icon: Icon(Icons.edit_square));

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
    final instanceOneButton = IconButton(
        tooltip: "Quick assign Instance #1 to this card.",
        onPressed: instanceOneAvailable
            ? () async {
                onCardEachSingleChange(definedInstances[0]);
              }
            : null,
        icon: createInstanceIconWithNumber(1));

    final instanceTwoButton = IconButton(
        tooltip: "Quick assign Instance #2 to this card.",
        onPressed: instanceTwoAvailable
            ? () async {
                onCardEachSingleChange(definedInstances[1]);
              }
            : null,
        icon: createInstanceIconWithNumber(2));
    if (cardEachSingle != null && cardEachSingle.isInstance) {
      instanceMark = Row(
        children: [
          Container(
            color: Colors.red,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
              child: Text("Instance"),
            ),
          ),
          SizedBox(width: 4),
        ],
      );
    } else {
      instanceMark = Container();
    }
    final padding = Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: Row(
        children: [
          showEditButton ? editButton : Container(),
          showEditButton && isBack && instanceOneAvailable
              ? instanceOneButton
              : Container(),
          showEditButton && isBack && instanceTwoAvailable
              ? instanceTwoButton
              : Container(),
          SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isBack ? "Back" : "Front",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline)),
                Row(
                  children: [
                    instanceMark,
                    Expanded(
                        child: Text(
                            cardEachSingle?.relativeFilePath ?? "(Empty)")),
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
