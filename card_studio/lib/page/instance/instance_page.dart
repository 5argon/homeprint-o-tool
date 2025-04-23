import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/core/card.dart';
import 'package:homeprint_o_tool/core/form/help_button.dart';

import '../../core/project_settings.dart';
import '../../core/save_file.dart';
import 'instance_member_list_item.dart';

class InstancePage extends StatelessWidget {
  final String basePath;
  final ProjectSettings projectSettings;
  final LinkedCardFaces definedInstances;
  final Function(LinkedCardFaces definedInstances) onDefinedInstancesChange;

  InstancePage({
    super.key,
    required this.basePath,
    required this.projectSettings,
    required this.definedInstances,
    required this.onDefinedInstancesChange,
  });

  @override
  Widget build(BuildContext context) {
    final createLinkedCardFaceButton = ElevatedButton(
      onPressed: () {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.removeCurrentSnackBar();
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Created a new linked card face.'),
          ),
        );

        final newCard = CardEachSingle.empty();
        final newDefinedInstances = definedInstances;
        newDefinedInstances.add(newCard);
        onDefinedInstancesChange(newDefinedInstances);
      },
      child: const Text('Create Linked Card Face'),
    );
    final topRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        createLinkedCardFaceButton,
        HelpButton(title: "Linked Card Face", paragraphs: [
          "Normally a card in Cards page consists of 2 faces : The front and back face. Linked card face is a standalone card faces, neither front nor back face, and cannot be printed on its own. Any card's face can link to these linked card faces instead of having its own independent face. Doing so it is possible to update many card faces in the project at once by altering the linked card face.",
          "This feature is mainly used for card backs that are the same throughout the project. You can correct content area or edit a single source image for the change to propagate to all cards that are linked.",
          "If you have linked a face here to something already, deleting it will cause the link to be broken and rendered an error instead."
        ]),
      ],
    );

    List<InstanceMemberListItem> instanceItems = [];
    for (var i = 0; i < definedInstances.length; i++) {
      final instance = definedInstances[i];
      final item = InstanceMemberListItem(
        key: Key(instance.uuid),
        basePath: basePath,
        projectSettings: projectSettings,
        definedInstances: definedInstances,
        order: i + 1,
        instanceCardEachSingle: instance,
        cardSize: projectSettings.cardSize,
        onInstanceCardChange: (card) {
          final newDefinedInstances = definedInstances;
          newDefinedInstances[i] = card;
          onDefinedInstancesChange(newDefinedInstances);
        },
        onDelete: () {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          scaffoldMessenger.removeCurrentSnackBar();
          String message = 'Deleted instance: ${instance.name}';
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(message),
            ),
          );
          final newDefinedInstances = definedInstances;
          newDefinedInstances.removeAt(i);
          onDefinedInstancesChange(newDefinedInstances);
        },
      );
      instanceItems.add(item);
    }

    final listView = ReorderableListView(
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final instance = instanceItems.removeAt(oldIndex);
        instanceItems.insert(newIndex, instance);

        final newDefinedInstances = List.of(definedInstances);
        final movedInstance = newDefinedInstances.removeAt(oldIndex);
        newDefinedInstances.insert(newIndex, movedInstance);
        onDefinedInstancesChange(newDefinedInstances);
      },
      children: instanceItems,
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: topRow,
          ),
          Expanded(child: listView),
        ],
      ),
    );
  }
}
