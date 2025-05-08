import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/page/card/group_list_item.dart';
import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/page/picks/include_data.dart';

import '../../core/card.dart';
import '../../core/save_file.dart';

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

  @override
  Widget build(BuildContext context) {
    final totalMissingFiles = _calculateTotalMissingFiles();

    final sortAllButton = Tooltip(
      message:
          "Sort all groups and also cards inside based on name alphabetically.",
      child: ElevatedButton(
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
              return aName.compareTo(bName);
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
                return aName.compareTo(bName);
              }
            });
          }
          onDefinedCardsChange(newDefinedCards);
        },
        child: const Text('Sort All'),
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

    final createGroupButton = ElevatedButton(
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
      child: const Text('Create Group'),
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
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 16,
                  children: [
                    createGroupButton,
                    sortAllButton,
                    missingFilesWarning,
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: listView),
        ],
      ),
    );
  }
}
