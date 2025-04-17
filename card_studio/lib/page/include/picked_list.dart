import 'package:flutter/material.dart';
import 'picked_list_item.dart';
import 'include_data.dart';

class PickedList extends StatelessWidget {
  final Includes includes;
  final Function(Includes) onIncludesChanged;

  const PickedList({
    Key? key,
    required this.includes,
    required this.onIncludesChanged,
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
        );
      },
    );
  }
}
