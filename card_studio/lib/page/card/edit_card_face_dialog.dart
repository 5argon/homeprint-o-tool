import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../../core/card.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/form/linked_card_face_dropdown.dart';

import '../../core/save_file.dart';

class EditCardFaceDialog extends StatefulWidget {
  final String basePath;
  final LinkedCardFaces linkedCardFaces;
  final Function(CardFace? card) onCardEachSingleChange;
  final CardFace? initialCard;
  final bool forLinkedCardFaceTab;

  const EditCardFaceDialog({
    super.key,
    required this.basePath,
    required this.linkedCardFaces,
    required this.onCardEachSingleChange,
    required this.forLinkedCardFaceTab,
    this.initialCard, // Optional initial value
  });

  @override
  EditCardFaceDialogState createState() => EditCardFaceDialogState();
}

class EditCardFaceDialogState extends State<EditCardFaceDialog>
    with SingleTickerProviderStateMixin {
  CardFace? selectedCardFace;
  late TabController _tabController;
  String? initialFilePath;
  String? tempFilePath; // Temporary file path for the File tab
  late TextEditingController
      filePathController; // Controller for the text field

  @override
  void initState() {
    super.initState();
    // Determine initial tab and values
    if (widget.forLinkedCardFaceTab) {
      _tabController = TabController(length: 1, vsync: this, initialIndex: 0);
    } else if (widget.initialCard != null) {
      if (widget.initialCard!.isLinkedCardFace) {
        // Start with Linked Card Face tab selected
        _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
        selectedCardFace = widget.initialCard;
        tempFilePath = null; // Ensure File tab shows "No file selected"
      } else if (widget.initialCard!.relativeFilePath.isNotEmpty) {
        _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
        initialFilePath = widget.initialCard!.relativeFilePath;
        tempFilePath = initialFilePath;
      } else {
        _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
      }
    } else {
      _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    }

    // Initialize the text controller with the initial file path
    filePathController = TextEditingController(text: tempFilePath);
  }

  @override
  void dispose() {
    filePathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var relativeFilePathTab = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Relative File Path",
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          Text(
            tempFilePath ?? "(No file selected)",
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              final path = await pickRelativePath(widget.basePath);
              if (path != null) {
                setState(() {
                  tempFilePath = path;
                });
              }
            },
            child: Text("Browse File"),
          ),
        ],
      ),
    );

    var linkedCardFaceTab = Center(
      child: widget.linkedCardFaces.isEmpty
          ? Text("You have not defined any linked card face yet.")
          : LinkedCardFaceDropdown(
              linkedCardFaces: widget.linkedCardFaces,
              selectedValue: selectedCardFace,
              onChanged: (value) {
                setState(() {
                  selectedCardFace = value;
                  tempFilePath =
                      null; // Clear the file path when selecting a linked card face
                });
              },
            ),
    );

    return AlertDialog(
      title: widget.forLinkedCardFaceTab
          ? Text("Edit Linked Card Face")
          : Text("Edit Card Face"),
      content: SizedBox(
        width: 400,
        child: DefaultTabController(
          length: widget.forLinkedCardFaceTab ? 1 : 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!widget.forLinkedCardFaceTab)
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: "File"),
                    Tab(text: "Linked Card Face"),
                  ],
                ),
              SizedBox(
                height: 200, // Adjust height as needed
                child: TabBarView(
                  controller: _tabController,
                  children: widget.forLinkedCardFaceTab
                      ? [relativeFilePathTab]
                      : [
                          relativeFilePathTab,
                          linkedCardFaceTab,
                        ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            if (_tabController.index == 0 && tempFilePath != null) {
              // Commit changes only when OK is pressed
              final newCard = CardFace(
                tempFilePath!,
                Alignment.center,
                1,
                Rotation.none,
                null,
                true,
                true,
                true,
                false,
              );
              widget.onCardEachSingleChange(newCard);
            } else if (_tabController.index == 1 && selectedCardFace != null) {
              widget.onCardEachSingleChange(selectedCardFace);
            }
            Navigator.of(context).pop();
          },
          child: Text("OK"),
        ),
      ],
    );
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
