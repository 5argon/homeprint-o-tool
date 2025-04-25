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
  int cardsDuplex = 0;
  int cardsWithOnlyFront = 0;
  int cardsWithOnlyBack = 0;
  CardFace? selectedLinkedCardFace;
  String missingFaceResolution = "Empty";
  List<DuplexCard> importedCards = [];
  File? fallbackBackFile; // Store the "back" file for the new resolution option
  Map<String, GatheringCard> gatheringCards = {};

  @override
  Widget build(BuildContext context) {
    var browseFolderButton = ElevatedButton(
      onPressed: onBrowse,
      child: const Text("Browse for Folder"),
    );
    var importButton = TextButton(
      onPressed: (selectedFolder == null ||
              (missingFaceResolution == "LinkedCardFace" &&
                  selectedLinkedCardFace == null))
          ? null // Disable the button
          : () {
              // Create DuplexCard objects when the user presses "Import"
              importedCards.clear(); // Clear any previously imported cards
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
                  // Skip cards without a front face
                  continue;
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
                  if (missingFaceResolution == "ReplaceWithBackFile" &&
                      fallbackBackFile != null) {
                    final relativePath = path.relative(
                      fallbackBackFile!.path,
                      from: widget.basePath,
                    );
                    backCard = CardFace.withRelativeFilePath(
                      relativePath,
                      isLinked: false,
                    );
                  } else if (missingFaceResolution == "LinkedCardFace" &&
                      selectedLinkedCardFace != null) {
                    backCard = selectedLinkedCardFace;
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
              }

              // Update state and pass the imported cards to the callback
              setState(() {
                cardsDuplex = cardsWithBothSides;
                this.cardsWithOnlyFront = cardsWithOnlyFront;
                this.cardsWithOnlyBack = cardsWithOnlyBack;
              });

              widget.onImport(importedCards);
              Navigator.of(context).pop();
            },
      child: const Text("Import"),
    );
    var radioEmpty = RadioListTile<String>(
      title: const Text("Empty"),
      value: "Empty",
      groupValue: missingFaceResolution,
      onChanged: (value) {
        setState(() {
          missingFaceResolution = value!;
        });
      },
    );
    var radioLinked = RadioListTile<String>(
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
    );
    var radioBackFile = RadioListTile<String>(
      title: Text(
        fallbackBackFile == null
            ? "Replace with back file (None found)"
            : "Replace with back file",
      ),
      value: "ReplaceWithBackFile",
      groupValue: missingFaceResolution,
      onChanged: fallbackBackFile == null
          ? null // Disable the option if no fallback back file is available
          : (value) {
              setState(() {
                missingFaceResolution = value!;
              });
            },
    );
    return AlertDialog(
      title: Row(
        children: [
          const Text("Import Cards from Folder"),
          const Spacer(),
          HelpButton(
            title: "Card Importing Algorithms",
            paragraphs: [
              "Supported file types are .png and .jpg",
              "The -a, -b, -front, -back, -1, -2 suffixes while the rest of the names are the same, are used to pair up the front and back face of cards to be imported.",
              "If flags such as -2x -3x -4x exists before those front/back face flages, they are used as the quantity of that card. This number should be the same for the front and back face, but if not, it prioritizes quantity number on the front face.",
              "Missing back faces can be automatically assigned using either your choice of Linked Card Face you have defined, using a file named exactly \"back.png/jpg\" found among the imports, or left them blank.",
            ],
          ),
        ],
      ),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            browseFolderButton,
            if (selectedFolder != null) ...[
              const SizedBox(height: 16),
              Text("Selected Folder: $selectedFolder"),
              const SizedBox(height: 8),
              Text("Cards Found: $cardsFound"),
              Text(
                  "(Duplex: $cardsDuplex, Only Front: $cardsWithOnlyFront, Only Back: $cardsWithOnlyBack)"),
              const SizedBox(height: 16),
              const Text("Missing back face resolution:"),
              radioEmpty,
              radioBackFile,
              radioLinked,
              // Drop down always visible but disabled if no linked card faces are defined
              LinkedCardFaceDropdown(
                disabled: !(missingFaceResolution == "LinkedCardFace" &&
                    widget.linkedCardFaces.isNotEmpty),
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
        importButton,
      ],
    );
  }

  void onBrowse() async {
    final folderPath = await FilePicker.platform.getDirectoryPath();
    if (folderPath != null) {
      fallbackBackFile = null; // Reset fallback back file

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
        if (fileName == 'back.png' || fileName == 'back.jpg') {
          fallbackBackFile = file;
          continue;
        }

        // Extract base name and flags
        final baseName = fileName.replaceAll(
            RegExp(r'(-a|-b|-1|-2|-front|-back|-x\d+)$'), '');
        final quantityMatch = RegExp(r'-x(\d+)').firstMatch(fileName);
        final quantity =
            quantityMatch != null ? int.parse(quantityMatch.group(1)!) : 1;

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

      // Update state
      setState(() {
        selectedFolder = folderPath;
        cardsFound = gatheringCards.length;
        cardsDuplex = gatheringCards.values
            .where((card) => card.frontFile != null && card.backFile != null)
            .length;
        cardsWithOnlyFront = gatheringCards.values
            .where((card) => card.frontFile != null && card.backFile == null)
            .length;
        cardsWithOnlyBack = gatheringCards.values
            .where((card) => card.frontFile == null && card.backFile != null)
            .length;
      });
    }
  }
}

class GatheringCard {
  File? frontFile;
  File? backFile;
  int quantity;

  GatheringCard({this.frontFile, this.backFile, this.quantity = 1});
}
