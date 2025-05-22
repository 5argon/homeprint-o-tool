import 'package:homeprint_o_tool/core/card_group.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/page/card/group_list_item.dart';
import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/page/picks/include_data.dart';
import 'package:homeprint_o_tool/page/card/import_from_folder_dialog.dart';

import 'package:homeprint_o_tool/core/save_file.dart';

class CardPage extends StatelessWidget {
  final String basePath;
  final ProjectSettings projectSettings;
  final DefinedCards definedCards;
  final LinkedCardFaces linkedCardFaces;
  final Function(DefinedCards definedCards) onDefinedCardsChange;
  final Includes includes;
  final Includes skipIncludes;
  final Function(Includes)? onIncludesChanged;
  final Function(Includes)? onSkipIncludesChanged;

  CardPage({
    super.key,
    required this.basePath,
    required this.projectSettings,
    required this.definedCards,
    required this.linkedCardFaces,
    required this.onDefinedCardsChange,
    required this.includes,
    required this.skipIncludes,
    this.onIncludesChanged,
    this.onSkipIncludesChanged,
  });

  // Calculate total missing files across all card groups
  int _calculateTotalMissingFiles() {
    int totalMissing = 0;
    for (var group in definedCards) {
      final integrityCheckResult =
          group.checkIntegrity(basePath, linkedCardFaces);
      totalMissing += integrityCheckResult.missingFileCount;
    }
    return totalMissing;
  }

  // Natural sort comparison that correctly sorts numeric values anywhere in strings
  int _compareNatural(String a, String b) {
    // Regular expression to match numbers anywhere in a string
    final numRegex = RegExp(r'(\d+)|([^\d]+)');
    final aMatches = numRegex.allMatches(a).toList();
    final bMatches = numRegex.allMatches(b).toList();

    // Compare each chunk (number or non-number) in sequence
    final minLength =
        aMatches.length < bMatches.length ? aMatches.length : bMatches.length;

    for (var i = 0; i < minLength; i++) {
      final aMatch = aMatches[i];
      final bMatch = bMatches[i];

      final aChunk = aMatch.group(0)!;
      final bChunk = bMatch.group(0)!;

      // Check if both chunks are numeric
      final aIsNumeric = aMatch.group(1) != null;
      final bIsNumeric = bMatch.group(1) != null;

      if (aIsNumeric && bIsNumeric) {
        // Compare numerically
        final aNum = int.parse(aChunk);
        final bNum = int.parse(bChunk);

        if (aNum != bNum) {
          return aNum.compareTo(bNum);
        }
      } else if (!aIsNumeric && !bIsNumeric) {
        // Compare strings
        final comparison = aChunk.compareTo(bChunk);
        if (comparison != 0) {
          return comparison;
        }
      } else {
        // If one is numeric and one isn't, sort non-numeric chunks first
        return aIsNumeric ? 1 : -1;
      }
    }

    // If all comparable chunks are equal, the shorter string comes first
    return aMatches.length.compareTo(bMatches.length);
  }

  @override
  Widget build(BuildContext context) {
    final totalMissingFiles = _calculateTotalMissingFiles();

    final sortAllButton = Tooltip(
      message:
          "Sort all groups and also cards inside based on name alphabetically.",
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('All groups and cards has been sorted alphabetically.'),
            ),
          );
          final newDefinedCards = definedCards;
          newDefinedCards.sort((a, b) {
            final aName = a.name;
            final bName = b.name;
            if (aName == null && bName == null) {
              return 0;
            } else if (aName == null) {
              return -1;
            } else if (bName == null) {
              return 1;
            } else {
              return _compareNatural(aName, bName);
            }
          });
          for (var df in newDefinedCards) {
            df.cards.sort((a, b) {
              final aName = a.name;
              final bName = b.name;
              if (aName == null && bName == null) {
                return 0;
              } else if (aName == null) {
                return -1;
              } else if (bName == null) {
                return 1;
              } else {
                return _compareNatural(aName, bName);
              }
            });
          }
          onDefinedCardsChange(newDefinedCards);
        },
        icon: const Icon(Icons.sort_by_alpha),
        label: const Text('Sort All'),
      ),
    );

    List<GroupListItem> groups = [];
    for (var i = 0; i < definedCards.length; i++) {
      final cardGroup = definedCards[i];
      final gli = GroupListItem(
        key: Key(cardGroup.id),
        includeMode: true,
        basePath: basePath,
        cardGroup: cardGroup,
        cardSize: projectSettings.cardSize,
        linkedCardFaces: linkedCardFaces,
        projectSettings: projectSettings,
        includes: includes,
        skipIncludes: skipIncludes,
        onIncludesChanged: onIncludesChanged,
        onSkipIncludesChanged: onSkipIncludesChanged,
        onCardGroupChange: (cardGroup) {
          final newDefinedCards = definedCards;
          newDefinedCards[i] = cardGroup;
          onDefinedCardsChange(newDefinedCards);
        },
        onDelete: () {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          scaffoldMessenger.removeCurrentSnackBar();
          String message;
          if (cardGroup.name == null) {
            message = 'Deleted a group.';
          } else {
            message = 'Deleted group : ${cardGroup.name}';
          }
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(message),
            ),
          );
          final newDefinedCards = definedCards;
          newDefinedCards.removeAt(i);
          onDefinedCardsChange(newDefinedCards);
        },
      );
      groups.add(gli);
    }

    final listViewScrollController = ScrollController();
    final listView = ListView.builder(
      controller: listViewScrollController,
      itemCount: groups.length,
      itemBuilder: (context, index) {
        return groups[index];
      },
    );

    final createGroupButton = ElevatedButton.icon(
      onPressed: () {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.removeCurrentSnackBar();
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Created a new group.'),
          ),
        );

        final newCardGroup = CardGroup([], "New Group");
        final newDefinedCards = definedCards;
        // Add as the first item then scroll to top.
        newDefinedCards.insert(0, newCardGroup);
        onDefinedCardsChange(newDefinedCards);
        listViewScrollController.animateTo(
          listViewScrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      icon: const Icon(Icons.create_new_folder),
      label: const Text('Create Group'),
    );

    // Warning widget for missing files
    final missingFilesWarning = totalMissingFiles > 0
        ? Tooltip(
            message: "Some cards have missing image files",
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
                SizedBox(width: 4),
                Text(
                  "$totalMissingFiles missing file${totalMissingFiles == 1 ? '' : 's'}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        : SizedBox.shrink(); // No warning if there are no missing files

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                createGroupButton,
                _buildImportFromFolderButton(context, listViewScrollController),
                sortAllButton,
                missingFilesWarning,
              ],
            ),
          ),
          Expanded(child: listView),
        ],
      ),
    );
  }

  Widget _buildImportFromFolderButton(
      BuildContext context, ScrollController scrollController) {
    return Tooltip(
      message:
          "Create a new group for each imported folder. Create multiple groups if selected a folder of folders.",
      child: ElevatedButton.icon(
        onPressed: () {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          scaffoldMessenger.removeCurrentSnackBar();

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return ImportFromFolderDialog(
                basePath: basePath,
                linkedCardFaces: linkedCardFaces,
                allowFolderOfFolders: true,
                onImport: (folderName, importedCards) {
                  // Create a new card group with the name of the folder
                  if (importedCards.isNotEmpty) {
                    final newCardGroup = CardGroup(importedCards, folderName);
                    final newDefinedCards = definedCards;
                    newDefinedCards.insert(0, newCardGroup);
                    onDefinedCardsChange(newDefinedCards);

                    // Scroll to top to see the new group
                    scrollController.animateTo(
                      scrollController.position.minScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );

                    scaffoldMessenger.showSnackBar(SnackBar(
                      content: Text(
                          "Created group '$folderName' with ${importedCards.length} cards."),
                    ));
                  }
                },
                onCreateGroups: (cardGroups) {
                  if (cardGroups.isNotEmpty) {
                    final newDefinedCards = definedCards;
                    // Insert at the beginning to make them visible immediately
                    newDefinedCards.insertAll(0, cardGroups);
                    onDefinedCardsChange(newDefinedCards);

                    // Scroll to top to see the new groups
                    scrollController.animateTo(
                      scrollController.position.minScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );

                    scaffoldMessenger.showSnackBar(SnackBar(
                      content: Text(
                          "Created ${cardGroups.length} groups with ${cardGroups.fold<int>(0, (sum, group) => sum + group.cards.length)} cards total."),
                    ));
                  }
                },
              );
            },
          );
        },
        icon: const Icon(Icons.folder_copy),
        label: const Text('Import Folder(s)'),
      ),
    );
  }
}
