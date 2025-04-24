import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/page/include/picked_list.dart';
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
  final LinkedCardFaces linkedCardFaces;
  final ProjectSettings projectSettings;
  final Includes includes;
  final IncludePosition includePosition;

  const PickedListItem({
    Key? key,
    required this.includeItem,
    required this.onRemove,
    required this.basePath,
    required this.cardSize,
    required this.linkedCardFaces,
    required this.projectSettings,
    required this.includes,
    required this.includePosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final icon =
        includeItem.cardGroup != null ? Icon(Icons.folder) : Container();
    final Widget render;
    final group = includeItem.cardGroup;
    final ce = includeItem.cardEach;

    final Widget pageFromToRender;
    if (group != null) {
      render = group.name != null
          ? Text(group.name!)
          : Text("Group: ${group.cards.length} cards");
      pageFromToRender = Row(
        children: [
          Text("First Card"),
          const SizedBox(width: 8),
          _PageAndIndexDisplay(
              page: includePosition.pageFrom,
              index: includePosition.indexInPageFrom,
              pageSize: includePosition.pageSize),
          const SizedBox(width: 8),
          Text("~"),
          const SizedBox(width: 8),
          _PageAndIndexDisplay(
              page: includePosition.pageTo,
              index: includePosition.indexInPageTo,
              pageSize: includePosition.pageSize),
          const SizedBox(width: 8),
          Text("Last Card (${includeItem.linearize().length})"),
        ],
      );
    } else if (ce != null) {
      render = Expanded(
          child: PickedOneCard(
        basePath: basePath,
        cardEach: ce,
        cardSize: cardSize,
        linkedCardFaces: linkedCardFaces,
        projectSettings: projectSettings,
      ));
      pageFromToRender = Row(children: [
        _PageAndIndexDisplay(
          page: includePosition.pageFrom,
          index: includePosition.indexInPageFrom,
          pageSize: includePosition.pageSize,
        ),
      ]);
    } else {
      render = Text("Unknown");
      pageFromToRender = Container();
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
        subtitle: pageFromToRender,
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
          onPressed: onRemove,
        ),
      ),
    );
  }
}

class _PageAndIndexDisplay extends StatelessWidget {
  final int page;
  final int index;
  final int pageSize;

  const _PageAndIndexDisplay({
    Key? key,
    required this.page,
    required this.index,
    required this.pageSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageText = pageSize > 0
        ? "Page ${page + 1} (${index + 1} / $pageSize)"
        : "Page ${page + 1} (${index + 1})";
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        pageText,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
          fontSize: 12,
        ),
      ),
    );
  }
}
