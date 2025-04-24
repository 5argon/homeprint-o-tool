import 'package:flutter/material.dart';
import '../../core/save_file.dart';
import 'available_list_item.dart';
import 'include_data.dart';
import '../../core/project_settings.dart';

class AvailableList extends StatelessWidget {
  final String basePath;
  final ProjectSettings projectSettings;
  final DefinedCards definedCards;
  final LinkedCardFaces linkedCardFaces;
  final Includes includes;
  final Includes skipIncludes;
  final Function(Includes) onIncludesChanged;

  const AvailableList({
    Key? key,
    required this.basePath,
    required this.projectSettings,
    required this.definedCards,
    required this.linkedCardFaces,
    required this.includes,
    required this.skipIncludes,
    required this.onIncludesChanged,
  }) : super(key: key);

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
          newIncludes.add(IncludeItem.cardGroup(cardGroup, quantity));
          onIncludesChanged(newIncludes);
        },
        onAddIndividual: (index, quantity) {
          final newIncludes = includes.toList();
          newIncludes
              .add(IncludeItem.cardEach(cardGroup.cards[index], quantity));
          onIncludesChanged(newIncludes);
        },
      );
      availableListItems.add(gli);
    }

    return ListView(children: availableListItems);
  }
}
