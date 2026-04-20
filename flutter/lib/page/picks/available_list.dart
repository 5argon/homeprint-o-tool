import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/core/save_file.dart';
import 'package:homeprint_o_tool/page/picks/available_list_item.dart';
import 'package:homeprint_o_tool/page/picks/include_data.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';

class AvailableList extends StatelessWidget {
  final String basePath;
  final ProjectSettings projectSettings;
  final DefinedCards definedCards;
  final LinkedCardFaces linkedCardFaces;
  final Includes includes;
  final Includes skipIncludes;
  final Function(Includes) onIncludesChanged;
  final void Function(String message) onShowToast;
  final VoidCallback onPickEachGroupOnce;

  const AvailableList({
    super.key,
    required this.basePath,
    required this.projectSettings,
    required this.definedCards,
    required this.linkedCardFaces,
    required this.includes,
    required this.skipIncludes,
    required this.onIncludesChanged,
    required this.onShowToast,
    required this.onPickEachGroupOnce,
  });

  @override
  Widget build(BuildContext context) {
    List<AvailableListItem> availableListItems = [];
    for (var i = 0; i < definedCards.length; i++) {
      final cardGroup = definedCards[i];
      final gli = AvailableListItem(
        basePath: basePath,
        cardGroup: cardGroup,
        cardSize: projectSettings.cardSize,
        linkedCardFaces: linkedCardFaces,
        projectSettings: projectSettings,
        includes: includes,
        skipIncludes: skipIncludes,
        onAddGroup: (quantity) {
          final newIncludes = includes.toList();
          for (var q = 0; q < quantity; q++) {
            newIncludes.add(IncludeItem.fromCardGroup(cardGroup));
          }
          onIncludesChanged(newIncludes);
          final groupDisplayName =
              cardGroup.name ?? '${cardGroup.cards.length} cards';
          onShowToast('Picked $groupDisplayName as a group');
        },
        onAddIndividual: (index, quantity) {
          final card = cardGroup.cards[index];
          final newIncludes = includes.toList();
          String toastMessage;

          // Find last IncludeItem — add to it if unlocked, else create new.
          if (newIncludes.isNotEmpty && !newIncludes.last.isLocked) {
            final target = newIncludes.last;
            for (var q = 0; q < quantity; q++) {
              target.addCard(card);
            }
            toastMessage =
                'Added ${card.name ?? "card"} to editable picked group "${target.groupName}"';
          } else {
            final newItem = IncludeItem.withIndividual(card);
            if (quantity > 1) {
              for (var q = 1; q < quantity; q++) {
                newItem.addCard(card);
              }
            }
            newIncludes.add(newItem);
            toastMessage =
                'Created a new Editable Picked Group and added ${card.name ?? "card"} to that group';
          }
          onIncludesChanged(newIncludes);
          onShowToast(toastMessage);
        },
      );
      availableListItems.add(gli);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: onPickEachGroupOnce,
                icon: const Icon(Icons.playlist_add),
                label: const Text('Pick Each Group Once'),
              ),
            ],
          ),
        ),
        Expanded(child: ListView(children: availableListItems)),
      ],
    );
  }
}
