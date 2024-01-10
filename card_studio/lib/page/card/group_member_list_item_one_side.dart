import 'package:card_studio/core/save_file.dart';
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
        onPressed: () async {
          final path = await pickRelativePath(basePath);
          if (path == null) return;
          final newCard = CardEachSingle(path, Alignment.center, 0.9358,
              Rotation.none, PerCardSynthesizedBleed.mirror, null, false);
          onCardEachSingleChange(newCard);
        },
        icon: Icon(Icons.edit));
    final sp1 = IconButton(
        onPressed: () async {
          onCardEachSingleChange(definedInstances[0]);
        },
        icon: Icon(Icons.ac_unit));
    final sp2 = IconButton(
        onPressed: () async {
          onCardEachSingleChange(definedInstances[1]);
        },
        icon: Icon(Icons.ac_unit));
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
          showEditButton && isBack ? sp1 : Container(),
          showEditButton && isBack ? sp2 : Container(),
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
    dialogTitle: "Choose an image file.",
    allowedExtensions: ['png', 'jpg'],
  );
  if (pickResult == null) return null;
  final filePath = pickResult.files.single.path;
  final isUnderBasePath = p.isWithin(basePath, filePath ?? "");
  if (!isUnderBasePath) return null;
  final relativePath = p.relative(filePath ?? "", from: basePath);
  return relativePath;
}
