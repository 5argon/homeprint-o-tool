import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/page/include/available_one_card.dart';
import 'package:homeprint_o_tool/page/include/picked_one_card.dart';
import '../../core/project_settings.dart';
import '../../core/save_file.dart';
import '../layout/layout_struct.dart';
import 'include_data.dart';

class PickedListItem extends StatelessWidget {
  final IncludeItem includeItem;
  final VoidCallback onRemove;
  final String basePath;
  final SizePhysical cardSize;
  final DefinedInstances definedInstances;
  final ProjectSettings projectSettings;
  final Includes includes;

  const PickedListItem({
    Key? key,
    required this.includeItem,
    required this.onRemove,
    required this.basePath,
    required this.cardSize,
    required this.definedInstances,
    required this.projectSettings,
    required this.includes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final icon =
        includeItem.cardGroup != null ? Icon(Icons.folder) : Container();
    final Widget render;
    final group = includeItem.cardGroup;
    final ce = includeItem.cardEach;
    if (group != null) {
      render = group.name != null
          ? Text(group.name!)
          : Text("Group: ${group.cards.length} cards");
    } else if (ce != null) {
      render = Expanded(
          child: PickedOneCard(
        basePath: basePath,
        cardEach: ce,
        cardSize: cardSize,
        definedInstances: definedInstances,
        projectSettings: projectSettings,
      ));
    } else {
      render = Text("Unknown");
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        title: Row(
          children: [
            icon,
            const SizedBox(width: 8),
            render,
          ],
        ),
        subtitle: Text("Quantity: ${includeItem.count()}"),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
          onPressed: onRemove,
        ),
      ),
    );
  }
}
