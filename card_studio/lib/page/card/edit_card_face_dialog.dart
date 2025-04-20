import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../../core/card.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/save_file.dart';

class EditCardFaceDialog extends StatelessWidget {
  final String basePath;
  final DefinedInstances definedInstances;
  final Function(CardEachSingle? card) onCardEachSingleChange;

  const EditCardFaceDialog({
    super.key,
    required this.basePath,
    required this.definedInstances,
    required this.onCardEachSingleChange,
  });

  @override
  Widget build(BuildContext context) {
    CardEachSingle? selectedInstance;

    final List<DropdownMenuItem<CardEachSingle>> dropdownItems = [];
    for (var i = 0; i < definedInstances.length; i++) {
      final instance = definedInstances[i];
      final String instanceName = instance.name ?? "";
      final String displayInstanceName;
      if (instanceName.isNotEmpty) {
        displayInstanceName = instanceName;
      } else if (instance.relativeFilePath.isNotEmpty) {
        displayInstanceName = p.basename(instance.relativeFilePath);
      } else {
        displayInstanceName = "#${i + 1} Unnamed Instance";
      }
      final newDropdownMenuItem = DropdownMenuItem<CardEachSingle>(
        value: instance,
        child: Text(displayInstanceName),
      );
      dropdownItems.add(newDropdownMenuItem);
    }

    final noInstanceDisplay = Text("You have not defined any instance yet.");

    var relativeFilePathTab = Column(
      children: [
        ElevatedButton(
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
              false,
            );
            onCardEachSingleChange(newCard);
            Navigator.of(context).pop();
          },
          child: Text("Select File"),
        ),
      ],
    );

    var instancesTab = definedInstances.isEmpty
        ? noInstanceDisplay
        : DropdownButton<CardEachSingle>(
            isExpanded: true,
            value: selectedInstance,
            hint: Text("Select an Instance"),
            items: dropdownItems,
            onChanged: (CardEachSingle? value) {
              selectedInstance = value;
            },
          );

    return AlertDialog(
      title: Text("Edit Card Face"),
      content: SizedBox(
        width: 400,
        child: DefaultTabController(
          length: 2, // Two tabs: "Relative File Path" and "Instances"
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TabBar(
                tabs: [
                  Tab(text: "File"),
                  Tab(text: "Instances"),
                ],
              ),
              SizedBox(
                height: 200, // Adjust height as needed
                child: TabBarView(
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
            if (selectedInstance != null) {
              onCardEachSingleChange(selectedInstance);
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
