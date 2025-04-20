import 'package:flutter/material.dart';
import '../../core/card.dart';
import '../../core/project_settings.dart';
import '../../core/save_file.dart';
import '../layout/layout_struct.dart';
import 'picked_list_item.dart';
import 'include_data.dart';

class PickedList extends StatelessWidget {
  final Includes includes;
  final Function(Includes) onIncludesChanged;
  final String basePath;
  final SizePhysical cardSize;
  final DefinedInstances definedInstances;
  final ProjectSettings projectSettings;

  const PickedList({
    Key? key,
    required this.includes,
    required this.onIncludesChanged,
    required this.basePath,
    required this.cardSize,
    required this.definedInstances,
    required this.projectSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (includes.isEmpty) {
      return Center(
        child: Text(
          "No items picked yet.",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: includes.length,
      itemBuilder: (context, index) {
        final item = includes[index];
        return PickedListItem(
          includeItem: item,
          onRemove: () {
            final updatedIncludes = includes.toList();
            updatedIncludes.removeAt(index);
            onIncludesChanged(updatedIncludes);
          },
          basePath: basePath,
          cardSize: cardSize,
          definedInstances: definedInstances,
          projectSettings: projectSettings,
          includes: includes,
        );
      },
    );
  }
}
