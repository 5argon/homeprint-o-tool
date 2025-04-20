import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/core/card.dart';

import '../../core/project_settings.dart';
import '../../core/save_file.dart';
import 'instance_member_list_item.dart';

class InstancePage extends StatelessWidget {
  final String basePath;
  final ProjectSettings projectSettings;
  final DefinedInstances definedInstances;
  final Function(DefinedInstances definedInstances) onDefinedInstancesChange;

  InstancePage({
    super.key,
    required this.basePath,
    required this.projectSettings,
    required this.definedInstances,
    required this.onDefinedInstancesChange,
  });

  @override
  Widget build(BuildContext context) {
    final createInstanceButton = ElevatedButton(
      onPressed: () {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.removeCurrentSnackBar();
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Created a new instance.'),
          ),
        );

        final newCard = CardEachSingle("", Alignment.center, 1, Rotation.none,
            PerCardSynthesizedBleed.mirror, null, true, true, true, true);
        final newDefinedInstances = definedInstances;
        newDefinedInstances.add(newCard);
        onDefinedInstancesChange(newDefinedInstances);
      },
      child: const Text('Create New Instance'),
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
            child: Row(
              children: [
                createInstanceButton,
              ],
            ),
          ),
          Expanded(child: listView),
        ],
      ),
    );
  }
}
