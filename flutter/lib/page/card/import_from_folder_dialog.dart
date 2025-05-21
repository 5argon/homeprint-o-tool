import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/core/card_face.dart';
import 'package:homeprint_o_tool/core/card_group.dart';
import 'package:homeprint_o_tool/core/duplex_card.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:homeprint_o_tool/core/form/help_button.dart';
import 'package:homeprint_o_tool/core/form/linked_card_face_dropdown.dart';
import 'package:homeprint_o_tool/core/save_file.dart';

class ImportFromFolderDialog extends StatefulWidget {
  final String basePath;
  final LinkedCardFaces linkedCardFaces;
  final Function(String folderName, List<DuplexCard> cards) onImport;
  // Optional parameter for creating new groups instead of importing to existing group
  final Function(List<CardGroup> cardGroups)? onCreateGroups;
  // Flag to enable folder-of-folders mode
  final bool allowFolderOfFolders;

  const ImportFromFolderDialog({
    super.key,
    required this.basePath,
    required this.linkedCardFaces,
    required this.onImport,
    this.onCreateGroups,
    this.allowFolderOfFolders = false,
  });

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

  // For folder-of-folders mode
  bool isFolderOfFolders = false;
  List<Directory> subDirectories = [];
  Map<String, Map<String, GatheringCard>> folderGatheringCardsMap = {};

  @override
  Widget build(BuildContext context) {
    var browseFolderButton = ElevatedButton.icon(
      onPressed: onBrowse,
      icon: Icon(
          widget.allowFolderOfFolders ? Icons.folder_copy : Icons.folder_open),
      label: Text(widget.allowFolderOfFolders
          ? "Browse for Folder${isFolderOfFolders ? " (Multiple Groups)" : ""}"
          : "Browse for Folder"),
    );

    var importButton = TextButton(
      onPressed: (selectedFolder == null ||
              (cardsWithOnlyFront > 0 &&
                  missingFaceResolution == "LinkedCardFace" &&
                  selectedLinkedCardFace == null))
          ? null // Disable the button
          : () {
              if (widget.onCreateGroups != null && isFolderOfFolders) {
                // Process folder-of-folders mode
                List<CardGroup> newCardGroups = [];

                for (var folderPath in folderGatheringCardsMap.keys) {
                  String folderName = path.basename(folderPath);
                  List<DuplexCard> folderCards = [];

                  for (final entry
                      in folderGatheringCardsMap[folderPath]!.entries) {
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
                      } else if (missingFaceResolution == "MirrorFrontFace") {
                        // Use the same file path as the front face
                        final relativePath = path.relative(
                          frontFile.path,
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
                      gatheringCard.originalName,
                    );
                    folderCards.add(card);
                  }

                  if (folderCards.isNotEmpty) {
                    newCardGroups.add(CardGroup(folderCards, folderName));
                  }
                }

                if (newCardGroups.isNotEmpty) {
                  widget.onCreateGroups!(newCardGroups);
                }
                Navigator.of(context).pop();
                return;
              }

              // Regular import mode for single folder
              final singleFolderName =
                  selectedFolder!.split(Platform.pathSeparator).last;

              importedCards.clear(); // Clear any previously imported cards
              int cardsWithBothSides = 0;
              int cardsWithOnlyFront = 0;
              int cardsWithOnlyBack = 0;

              for (final entry in gatheringCards.entries) {
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
                  } else if (missingFaceResolution == "MirrorFrontFace") {
                    // Use the same file path as the front face
                    final relativePath = path.relative(
                      frontFile.path,
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
                  gatheringCard.originalName,
                );
                importedCards.add(card);
              }

              // Update state and pass the imported cards to the callback
              setState(() {
                cardsDuplex = cardsWithBothSides;
                this.cardsWithOnlyFront = cardsWithOnlyFront;
                this.cardsWithOnlyBack = cardsWithOnlyBack;
              });

              widget.onImport(singleFolderName, importedCards);
              Navigator.of(context).pop();
            },
      child: Text(widget.allowFolderOfFolders && isFolderOfFolders
          ? "Create Groups"
          : "Import"),
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
          Text(widget.allowFolderOfFolders && isFolderOfFolders
              ? "Import Multiple Groups from Folders"
              : "Import Cards from Folder"),
          const Spacer(),
          HelpButton(
            title: "Card Importing Algorithms",
            paragraphs: [
              "Supported file types are .png and .jpg",
              "The -a, -b, -front, -back, -1, -2 suffixes (or with underscores like _a, _b, etc.) while the rest of the names are the same, are used to pair up the front and back face of cards to be imported.",
              "If flags such as -x2, -x3, -x4 (or with underscores like _x2) exist before those front/back face flags, they are used as the quantity of that card. This number should be the same for the front and back face, but if not, it prioritizes quantity number on the front face.",
              "Missing back faces can be automatically assigned using either your choice of Linked Card Face you have defined, using a file named exactly \"back.png/jpg\" found among the imports, or left them blank.",
              if (widget.allowFolderOfFolders)
                "When selecting a folder containing subfolders, each subfolder will become a separate card group named after the folder."
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
              if (isFolderOfFolders) ...[
                Text(
                    "Found ${subDirectories.length} subfolders to import as groups"),
                Text("Total cards found: $cardsFound"),
              ] else ...[
                Text("Cards Found: $cardsFound"),
              ],
              Text(
                  "(Duplex: $cardsDuplex, Only Front: $cardsWithOnlyFront, Only Back: $cardsWithOnlyBack)"),
              const SizedBox(height: 16),
              if (cardsWithOnlyFront > 0) ...[
                const Text("Missing back face resolution:"),
                radioEmpty,
                radioBackFile,
                RadioListTile<String>(
                  title: const Text("Mirror Front Face (Same on Both Sides)"),
                  value: "MirrorFrontFace",
                  groupValue: missingFaceResolution,
                  onChanged: (value) {
                    setState(() {
                      missingFaceResolution = value!;
                    });
                  },
                ),
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
    final folderPath =
        await getDirectoryPath(initialDirectory: widget.basePath);
    if (folderPath != null) {
      fallbackBackFile = null; // Reset fallback back file
      gatheringCards.clear(); // Clear previously gathered cards
      folderGatheringCardsMap.clear(); // Clear previous folder maps

      // Scan the folder for files or subdirectories
      final directory = Directory(folderPath);
      final entities = directory.listSync();

      // First check if this is a folder with subdirectories and we're allowed to process them
      if (widget.allowFolderOfFolders) {
        subDirectories = entities
            .whereType<Directory>()
            .where((dir) => !path
                .basename(dir.path)
                .startsWith('.')) // Skip hidden directories
            .toList();

        if (subDirectories.isNotEmpty) {
          setState(() {
            isFolderOfFolders = true;
            selectedFolder = folderPath;
            cardsFound = 0;
            cardsDuplex = 0;
            cardsWithOnlyFront = 0;
            cardsWithOnlyBack = 0;
          });

          // Process each subdirectory
          for (final subDir in subDirectories) {
            final subDirPath = subDir.path;
            final files = subDir.listSync().whereType<File>().toList();
            final subDirGatheringCards = <String, GatheringCard>{};
            File? subDirBackFile;

            for (final file in files) {
              final fileName = path.basename(file.path).toLowerCase();
              final fileExtension = path.extension(fileName);

              // Allow only .png, .jpg, .jpeg files
              if (!['.png', '.jpg', '.jpeg'].contains(fileExtension)) {
                continue;
              }

              // Check for default back file
              if (fileName == 'back.png' || fileName == 'back.jpg') {
                subDirBackFile = file;
                continue;
              }

              processCardFile(file, subDirGatheringCards);
            }

            // If no fallback back file found globally, use the one from this directory
            if (fallbackBackFile == null && subDirBackFile != null) {
              fallbackBackFile = subDirBackFile;
            }

            folderGatheringCardsMap[subDirPath] = subDirGatheringCards;

            // Update counts for UI
            final dirDuplex = subDirGatheringCards.values
                .where(
                    (card) => card.frontFile != null && card.backFile != null)
                .length;
            final dirFrontOnly = subDirGatheringCards.values
                .where(
                    (card) => card.frontFile != null && card.backFile == null)
                .length;
            final dirBackOnly = subDirGatheringCards.values
                .where(
                    (card) => card.frontFile == null && card.backFile != null)
                .length;

            setState(() {
              cardsFound += subDirGatheringCards.length;
              cardsDuplex += dirDuplex;
              cardsWithOnlyFront += dirFrontOnly;
              cardsWithOnlyBack += dirBackOnly;
            });
          }

          return;
        }
      }

      // If we're here, either it's not a folder of folders or there are no subdirectories
      setState(() {
        isFolderOfFolders = false;
        selectedFolder = folderPath;
      });

      // Scan the folder for files
      final files = entities.whereType<File>().toList();

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

        // Process each card file
        processCardFile(file, gatheringCards);
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

  // Helper method to process a single card file
  void processCardFile(
      File file, Map<String, GatheringCard> targetGatheringCards) {
    // Get the original filename with original case for display
    final originalFileName = path.basename(file.path);
    // Get lowercase version for pattern matching
    final fileNameLower = originalFileName.toLowerCase();
    // Remove file extension first
    String baseNameLower =
        fileNameLower.substring(0, fileNameLower.lastIndexOf('.'));
    // Keep an original case version for the actual card name
    String baseNameOriginal =
        originalFileName.substring(0, originalFileName.lastIndexOf('.'));

    // Remove the face marker suffix (-a, -b, etc.) from both versions
    final faceMarkerPattern =
        RegExp(r'([-_](a|b|1|2|front|back))$', caseSensitive: false);
    if (faceMarkerPattern.hasMatch(baseNameLower)) {
      final match = faceMarkerPattern.firstMatch(baseNameLower)!;
      baseNameLower = baseNameLower.substring(0, match.start);
      // Also trim the original case version at the same position
      baseNameOriginal = baseNameOriginal.substring(0, match.start);
    }

    // Extract quantity if present
    final quantityPattern = RegExp(r'[-_]x(\d+)$', caseSensitive: false);
    final quantityMatch = quantityPattern.firstMatch(baseNameLower);
    final quantity =
        quantityMatch != null ? int.parse(quantityMatch.group(1)!) : 1;

    // Remove quantity suffix from base name if present
    if (quantityMatch != null) {
      baseNameLower = baseNameLower.substring(0, quantityMatch.start);
      // Also trim the original case version at the same position
      baseNameOriginal = baseNameOriginal.substring(0, quantityMatch.start);
    }

    // Update or create GatheringCard - use lowercase for map keys
    final gatheringCard = targetGatheringCards.putIfAbsent(
      baseNameLower,
      () => GatheringCard(quantity: quantity, originalName: baseNameOriginal),
    );

    // Extract the file name without extension to check for face markers
    final fileNameWithoutExtLower =
        fileNameLower.substring(0, fileNameLower.lastIndexOf('.'));

    // Check if the filename ends with any of these patterns
    final frontPattern = RegExp(r'([-_](a|1|front))$', caseSensitive: false);
    final backPattern = RegExp(r'([-_](b|2|back))$', caseSensitive: false);

    if (frontPattern.hasMatch(fileNameWithoutExtLower)) {
      gatheringCard.frontFile = file;
      gatheringCard.quantity = quantity; // Use quantity from front if available
    } else if (backPattern.hasMatch(fileNameWithoutExtLower)) {
      gatheringCard.backFile = file;
    } else {
      // If no face marker is present, default to front
      gatheringCard.frontFile = file;
    }
  }
}

class GatheringCard {
  File? frontFile;
  File? backFile;
  int quantity;
  String originalName;

  GatheringCard(
      {this.frontFile,
      this.backFile,
      this.quantity = 1,
      this.originalName = ""});
}
