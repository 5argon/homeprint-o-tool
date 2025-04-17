import 'package:flutter/material.dart';
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        title: Text("Sample"),
        subtitle: Text("Quantity: ${includeItem.count()}"),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
          onPressed: onRemove,
        ),
      ),
    );
  }
}
