import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../../core/card.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/save_file.dart';

class EditCardFaceDialog extends StatefulWidget {
  final String basePath;
  final DefinedInstances definedInstances;
  final Function(CardEachSingle? card) onCardEachSingleChange;
  final CardEachSingle? initialCard; // New parameter for initial value

  const EditCardFaceDialog({
    super.key,
    required this.basePath,
    required this.definedInstances,
    required this.onCardEachSingleChange,
    this.initialCard, // Optional initial value
  });

  @override
  _EditCardFaceDialogState createState() => _EditCardFaceDialogState();
}

class _EditCardFaceDialogState extends State<EditCardFaceDialog>
    with SingleTickerProviderStateMixin {
  CardEachSingle? selectedInstance;
  late TabController _tabController;
  String? initialFilePath;
  String? tempFilePath; // Temporary file path for the File tab
  late TextEditingController
      filePathController; // Controller for the text field

  @override
  void initState() {
    super.initState();
    // Determine initial tab and values
    if (widget.initialCard != null) {
      if (widget.initialCard!.relativeFilePath.isNotEmpty) {
        _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
        initialFilePath = widget.initialCard!.relativeFilePath;
        tempFilePath = initialFilePath; // Initialize tempFilePath
      } else {
        _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
        selectedInstance = widget.initialCard;
      }
    } else {
      _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    }

    // Initialize the text controller with the initial file path
    filePathController = TextEditingController(text: tempFilePath);
  }

  @override
  void dispose() {
    filePathController
        .dispose(); // Dispose the controller when the widget is destroyed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<CardEachSingle>> dropdownItems =
        widget.definedInstances.asMap().entries.map((entry) {
      final int index = entry.key + 1; // 1-based index
      final CardEachSingle instance = entry.value;
      final String instanceName = instance.name ?? "";
      final String displayInstanceName;
      if (instanceName.isNotEmpty) {
        displayInstanceName = instanceName;
      } else if (instance.relativeFilePath.isNotEmpty) {
        displayInstanceName = p.basename(instance.relativeFilePath);
      } else {
        displayInstanceName = "#$index: Unnamed Linked Card Face";
      }
      return DropdownMenuItem<CardEachSingle>(
        value: instance,
        child: Text(displayInstanceName),
      );
    }).toList();

    var relativeFilePathTab = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min, // Center vertically
        crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
        children: [
          Text(
            tempFilePath ??
                "(No file selected)", // Display the file path or a placeholder
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8), // Add spacing between the text and the button
          ElevatedButton(
            onPressed: () async {
              final path = await pickRelativePath(widget.basePath);
              if (path != null) {
                setState(() {
                  tempFilePath = path; // Update tempFilePath
                });
              }
            },
            child: Text("Browse File"),
          ),
        ],
      ),
    );

    var instancesTab = Center(
      child: widget.definedInstances.isEmpty
          ? Text("You have not defined any linked card face yet.")
          : DropdownButton<CardEachSingle>(
              isExpanded: true,
              value: selectedInstance,
              hint: Text("Select a linked card face"),
              items: dropdownItems,
              onChanged: (CardEachSingle? value) {
                setState(() {
                  selectedInstance = value;
                });
              },
            ),
    );

    return AlertDialog(
      title: Text("Edit Card Face"),
      content: SizedBox(
        width: 400,
        child: DefaultTabController(
          length: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                  children: [
                    // Tab 1: Relative File Path
                    relativeFilePathTab,
                    // Tab 2: Instances
                    instancesTab,
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
              final newCard = CardEachSingle(
                tempFilePath!,
                Alignment.center,
                1,
                Rotation.none,
                PerCardSynthesizedBleed.mirror,
                null,
                true,
                true,
                true,
                false,
              );
              widget.onCardEachSingleChange(newCard);
            } else if (_tabController.index == 1 && selectedInstance != null) {
              widget.onCardEachSingleChange(selectedInstance);
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
