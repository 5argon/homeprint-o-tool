import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/page/include/available_list.dart';
import 'package:homeprint_o_tool/page/include/available_list_item.dart';
import 'package:homeprint_o_tool/page/include/picked_list.dart';
import 'include_data.dart';

class PickedListItem extends StatelessWidget {
  final IncludeItem includeItem;
  final VoidCallback onRemove;

  const PickedListItem({
    Key? key,
    required this.includeItem,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final icon = includeItem.cardGroup != null
        ? Icon(Icons.group)
        : Icon(Icons.credit_card);
    final Widget render;
    final group = includeItem.cardGroup;
    if (group != null) {
      render = group.name != null
          ? Text(group.name!)
          : Text("Group: ${group.cards.length} cards");
    } else {
      final ce = includeItem.cardEach;
      render = AvailableListItem(basePath: basePath, cardGroup: group, cardSize: cardSize, definedInstances: definedInstances, projectSettings: projectSettings, includes: includes, skipIncludes: skipIncludes, onAddGroup: onAddGroup, onAddIndividual: onAddIndividual)
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
