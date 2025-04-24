import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

import '../../core/card.dart';
import '../../core/form/help_button.dart';
import '../../core/form/linked_card_face_dropdown.dart';
import '../../core/save_file.dart';

class ImportFromFolderDialog extends StatefulWidget {
  final String basePath;
  final LinkedCardFaces linkedCardFaces;
  final Function(List<DuplexCard> cards) onImport;

  const ImportFromFolderDialog({
    Key? key,
    required this.basePath,
    required this.linkedCardFaces,
    required this.onImport,
  }) : super(key: key);

  @override
  ImportFromFolderDialogState createState() => ImportFromFolderDialogState();
}

class ImportFromFolderDialogState extends State<ImportFromFolderDialog> {
  String? selectedFolder;
  int cardsFound = 0;
  int cardsWithOnlyFront = 0;
  int cardsWithOnlyBack = 0;
  CardFace? selectedLinkedCardFace;
  String missingFaceResolution = "Empty";
  List<DuplexCard> importedCards = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Text("Import Cards from Folder"),
          const Spacer(),
          HelpButton(
            title: "How Backside Detection Works",
            paragraphs: [
              "The system detects card backs by looking for files with the same name as the front but with '-a' or '-b' suffix.",
              "For example, 'card-a.png' is the front, and 'card-b.png' is the back.",
            ],
          ),
        ],
      ),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                final folderPath = await FilePicker.platform.getDirectoryPath();
                if (folderPath != null) {
                  // Logic before setting state.
                  final gatheringCards = <String, GatheringCard>{};
                  File? defaultBackFile;

                  // Scan the folder for files
                  final directory = Directory(folderPath);
                  final files = directory.listSync().whereType<File>().toList();

                  for (final file in files) {
                    final fileName = path.basename(file.path).toLowerCase();
                    final fileExtension = path.extension(fileName);

                    // Allow only .png, .jpg, .jpeg files
                    if (!['.png', '.jpg', '.jpeg'].contains(fileExtension)) {
                      continue;
                    }

                    // Check for default back file
                    if (fileName == 'back.png') {
                      defaultBackFile = file;
                      continue;
                    }

                    // Extract base name and flags
                    final baseName = fileName.replaceAll(
                        RegExp(r'(-a|-b|-1|-2|-front|-back|-x\d+)$'), '');
                    final quantityMatch =
                        RegExp(r'-x(\d+)').firstMatch(fileName);
                    final quantity = quantityMatch != null
                        ? int.parse(quantityMatch.group(1)!)
                        : 1;

                    // Update or create GatheringCard
                    final gatheringCard = gatheringCards.putIfAbsent(
                      baseName,
                      () => GatheringCard(quantity: quantity),
                    );

                    if (fileName.contains(RegExp(r'(-a|-1|-front)'))) {
                      gatheringCard.frontFile = file;
                    } else if (fileName.contains(RegExp(r'(-b|-2|-back)'))) {
                      gatheringCard.backFile = file;
                    } else {
                      gatheringCard.frontFile = file;
                    }
                  }

                  // Create DuplexCard objects
                  int cardsWithBothSides = 0;
                  int cardsWithOnlyFront = 0;
                  int cardsWithOnlyBack = 0;

                  for (final entry in gatheringCards.entries) {
                    final baseName = entry.key;
                    final gatheringCard = entry.value;

                    final frontFile = gatheringCard.frontFile;
                    final backFile = gatheringCard.backFile;
                    final CardFace? frontCard;
                    if (frontFile != null) {
                      final relativePath = path.relative(
                        frontFile.path,
                        from: widget.basePath,
                      );
                      frontCard = CardFace.withRelativeFilePath(
                        relativePath,
                        isLinked: false,
                      );
                    } else {
                      frontCard = null;
                    }

                    final CardFace? backCard;
                    if (backFile != null) {
                      final relativePath = path.relative(
                        backFile.path,
                        from: widget.basePath,
                      );
                      backCard = CardFace.withRelativeFilePath(
                        relativePath,
                        isLinked: false,
                      );
                    } else {
                      if (defaultBackFile != null) {
                        final relativePath = path.relative(
                          defaultBackFile.path,
                          from: widget.basePath,
                        );
                        backCard = CardFace.withRelativeFilePath(
                          relativePath,
                          isLinked: false,
                        );
                      } else if (defaultBackFile != null) {
                        final relativePath = path.relative(
                          defaultBackFile.path,
                          from: widget.basePath,
                        );
                        backCard = CardFace.withRelativeFilePath(
                          relativePath,
                          isLinked: false,
                        );
                      } else {
                        backCard = null;
                      }
                    }

                    final card = DuplexCard(
                      frontCard,
                      backCard,
                      gatheringCard.quantity,
                      baseName,
                    );
                    importedCards.add(card);

                    if (frontCard != null && backCard != null) {
                      cardsWithBothSides++;
                    } else if (frontCard != null) {
                      cardsWithOnlyFront++;
                    } else if (backCard != null) {
                      cardsWithOnlyBack++;
                    }
                  }

                  // Update state
                  setState(() {
                    selectedFolder = folderPath;
                    cardsFound = importedCards.length;
                    cardsWithOnlyFront = cardsWithOnlyFront;
                    cardsWithOnlyBack = cardsWithOnlyBack;
                  });
                }
              },
              child: const Text("Browse for Folder"),
            ),
            if (selectedFolder != null) ...[
              const SizedBox(height: 16),
              Text("Selected Folder: $selectedFolder"),
              const SizedBox(height: 8),
              Text("Cards Found: $cardsFound"),
              Text("Cards with Only Front: $cardsWithOnlyFront"),
              Text("Cards with Only Back: $cardsWithOnlyBack"),
              const SizedBox(height: 16),
              const Text("Missing Face Resolution:"),
              RadioListTile<String>(
                title: const Text("Empty"),
                value: "Empty",
                groupValue: missingFaceResolution,
                onChanged: (value) {
                  setState(() {
                    missingFaceResolution = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: Text(
                  widget.linkedCardFaces.isEmpty
                      ? "Linked Card Face (None defined)"
                      : "Linked Card Face",
                ),
                value: "LinkedCardFace",
                groupValue: missingFaceResolution,
                onChanged: widget.linkedCardFaces.isEmpty
                    ? null // Disable selection if no linked card faces are defined
                    : (value) {
                        setState(() {
                          missingFaceResolution = value!;
                        });
                      },
              ),
              if (missingFaceResolution == "LinkedCardFace" &&
                  widget.linkedCardFaces.isNotEmpty)
                LinkedCardFaceDropdown(
                  linkedCardFaces: widget.linkedCardFaces,
                  selectedValue: selectedLinkedCardFace,
                  onChanged: (value) {
                    setState(() {
                      selectedLinkedCardFace = value;
                    });
                  },
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: (selectedFolder == null ||
                  (missingFaceResolution == "LinkedCardFace" &&
                      selectedLinkedCardFace == null))
              ? null // Disable the button
              : () {
                  // Use the importedCards list here
                  widget.onImport(importedCards);
                  Navigator.of(context).pop();
                },
          child: const Text("Import"),
        ),
      ],
    );
  }
}

class GatheringCard {
  File? frontFile;
  File? backFile;
  int quantity;

  GatheringCard({this.frontFile, this.backFile, this.quantity = 1});
}
