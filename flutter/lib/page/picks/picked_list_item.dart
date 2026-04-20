import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/page/picks/picked_list.dart';
import 'package:homeprint_o_tool/page/picks/picked_one_card.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/core/save_file.dart';
import 'package:homeprint_o_tool/page/layout/layout_data.dart';
import 'package:homeprint_o_tool/page/picks/include_data.dart';

class PickedListItem extends StatefulWidget {
  final int index;
  final IncludeItem includeItem;
  final bool inMergeMode;
  final bool isMergeSource;
  final bool isLastEditableGroup;
  final VoidCallback onRemove;
  final VoidCallback onUnlock;
  final void Function(int cardIndex) onCardRemoved;
  final void Function(int cardIndex, int amount) onCardAmountChanged;
  final void Function(String name) onGroupNameChanged;
  final VoidCallback onClone;
  final VoidCallback onSortAndMerge;
  final VoidCallback onStartMerge;
  final VoidCallback onCancelMerge;
  final VoidCallback onMergeTarget;
  final String basePath;
  final SizePhysical cardSize;
  final LinkedCardFaces linkedCardFaces;
  final ProjectSettings projectSettings;
  final Includes includes;
  final IncludePosition includePosition;

  const PickedListItem({
    super.key,
    required this.index,
    required this.includeItem,
    required this.inMergeMode,
    required this.isMergeSource,
    required this.isLastEditableGroup,
    required this.onRemove,
    required this.onUnlock,
    required this.onCardRemoved,
    required this.onCardAmountChanged,
    required this.onGroupNameChanged,
    required this.onClone,
    required this.onSortAndMerge,
    required this.onStartMerge,
    required this.onCancelMerge,
    required this.onMergeTarget,
    required this.basePath,
    required this.cardSize,
    required this.linkedCardFaces,
    required this.projectSettings,
    required this.includes,
    required this.includePosition,
  });

  @override
  State<PickedListItem> createState() => _PickedListItemState();
}

class _PickedListItemState extends State<PickedListItem> {
  void _showRenameDialog() {
    final controller =
        TextEditingController(text: widget.includeItem.groupName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Picked Group'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Group Name'),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              widget.onGroupNameChanged(value);
            }
            Navigator.of(ctx).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                widget.onGroupNameChanged(controller.text);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.includeItem;
    final theme = Theme.of(context);

    // Page break rendering
    if (item.isPageBreak) {
      return _buildPageBreakItem(theme);
    }

    // Normal group rendering
    return _buildGroupItem(theme, item);
  }

  Widget _buildPageBreakItem(ThemeData theme) {
    final titleRow = Row(
      children: [
        if (!widget.inMergeMode)
          ReorderableDragStartListener(
            index: widget.index,
            child: const Icon(Icons.drag_handle),
          ),
        const SizedBox(width: 8),
        Icon(Icons.insert_page_break_outlined,
            color: theme.colorScheme.tertiary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Page Break',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.tertiary,
            ),
          ),
        ),
        if (!widget.inMergeMode)
          Tooltip(
            message: 'Remove Page Break',
            child: IconButton(
              icon: Icon(Icons.delete, color: theme.colorScheme.error),
              onPressed: widget.onRemove,
            ),
          ),
      ],
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: titleRow,
      ),
    );
  }

  Widget _buildGroupItem(ThemeData theme, IncludeItem item) {
    final isLocked = item.isLocked;

    // In merge mode, show simplified UI
    if (widget.inMergeMode) {
      return _buildMergeModeItem(theme, item);
    }

    // Icons
    final Widget leadingIcon;
    if (isLocked && item.pickedFromCardGroup != null) {
      leadingIcon = Icon(Icons.folder, color: theme.colorScheme.primary);
    } else {
      leadingIcon = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open, color: theme.colorScheme.secondary),
          const SizedBox(width: 2),
          Icon(Icons.edit, size: 14, color: theme.colorScheme.secondary),
        ],
      );
    }

    // Group name
    final nameText = GestureDetector(
      onDoubleTap: _showRenameDialog,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.groupName,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isLocked
                  ? theme.textTheme.bodyMedium?.color
                  : theme.colorScheme.secondary,
            ),
          ),
          if (widget.isLastEditableGroup && !isLocked)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Tooltip(
                message:
                    'Editable Picked Group that is currently the last item in the list is automatically the destination of individual card pickings.',
                child: Icon(
                  Icons.download_done_rounded,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );

    // Page position display with page crossing indicator
    final Widget pageFromToRender = _buildPagePositionDisplay(item, theme);

    // Action buttons
    final actionButtons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Clone Group',
          child: IconButton(
            icon: Icon(Icons.copy, color: theme.colorScheme.primary),
            onPressed: widget.onClone,
          ),
        ),
        Tooltip(
          message: 'Merge into another group',
          child: IconButton(
            icon: Icon(Icons.merge_type, color: theme.colorScheme.primary),
            onPressed: widget.onStartMerge,
          ),
        ),
        if (isLocked)
          Tooltip(
            message: 'Make Picked Group Editable',
            child: IconButton(
              icon: Icon(Icons.lock_open, color: theme.colorScheme.secondary),
              onPressed: widget.onUnlock,
            ),
          ),
        Tooltip(
          message: 'Remove Picked Group',
          child: IconButton(
            icon: Icon(Icons.delete, color: theme.colorScheme.error),
            onPressed: widget.onRemove,
          ),
        ),
      ],
    );

    // Build the title row with drag handle on the left
    final titleRow = Row(
      children: [
        ReorderableDragStartListener(
          index: widget.index,
          child: const Icon(Icons.drag_handle),
        ),
        const SizedBox(width: 8),
        leadingIcon,
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              nameText,
              pageFromToRender,
            ],
          ),
        ),
        actionButtons,
      ],
    );

    // Build expanded children list with per-group sort&merge button
    final List<Widget> expandedChildren = [
      if (!isLocked && item.pickedCards.length > 1)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: widget.onSortAndMerge,
              icon: const Icon(Icons.sort, size: 18),
              label: const Text('Sort and Merge'),
            ),
          ),
        ),
      for (var i = 0; i < item.pickedCards.length; i++)
        _buildPickedCardRow(context, item, i, isLocked, theme),
    ];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ExpansionTile(
        title: titleRow,
        children: expandedChildren,
      ),
    );
  }

  Widget _buildMergeModeItem(ThemeData theme, IncludeItem item) {
    final isSource = widget.isMergeSource;

    final Widget leading;
    if (item.isLocked) {
      leading = Icon(Icons.folder, color: theme.colorScheme.primary);
    } else {
      leading = Icon(Icons.folder_open, color: theme.colorScheme.secondary);
    }

    final nameText = Text(
      item.groupName,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        color: isSource
            ? theme.colorScheme.error
            : theme.textTheme.bodyMedium?.color,
      ),
    );

    final countText = Text(
      '${item.count()} cards',
      style: theme.textTheme.bodySmall,
    );

    final Widget trailing;
    if (isSource) {
      trailing = ElevatedButton.icon(
        onPressed: widget.onCancelMerge,
        icon: const Icon(Icons.close),
        label: const Text('Cancel'),
        style: ElevatedButton.styleFrom(
          foregroundColor: theme.colorScheme.error,
        ),
      );
    } else {
      trailing = ElevatedButton.icon(
        onPressed: widget.onMergeTarget,
        icon: const Icon(Icons.merge_type),
        label: const Text('Merge Here'),
        style: ElevatedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: isSource ? theme.colorScheme.errorContainer : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [nameText, countText],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildPagePositionDisplay(IncludeItem item, ThemeData theme) {
    // Page crossing indicator
    final pageCrossing =
        widget.includePosition.pageTo - widget.includePosition.pageFrom;
    final Widget? pageCrossingWidget;
    if (pageCrossing > 0) {
      pageCrossingWidget = Tooltip(
        message: 'This Picked Group crosses a page $pageCrossing time(s)',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_forward,
                size: 14, color: theme.colorScheme.tertiary),
            const SizedBox(width: 2),
            Text(
              '$pageCrossing',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.tertiary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      pageCrossingWidget = null;
    }

    if (item.pickedCards.length > 1) {
      return Row(
        children: [
          const Text("First Card"),
          const SizedBox(width: 8),
          _PageAndIndexDisplay(
              page: widget.includePosition.pageFrom,
              index: widget.includePosition.indexInPageFrom,
              pageSize: widget.includePosition.pageSize),
          const SizedBox(width: 8),
          const Text("~"),
          const SizedBox(width: 8),
          _PageAndIndexDisplay(
              page: widget.includePosition.pageTo,
              index: widget.includePosition.indexInPageTo,
              pageSize: widget.includePosition.pageSize),
          const SizedBox(width: 8),
          Text("Last Card (${item.count()})"),
          if (pageCrossingWidget != null) ...[
            const SizedBox(width: 8),
            pageCrossingWidget,
          ],
        ],
      );
    } else if (item.pickedCards.length == 1) {
      final picked = item.pickedCards.first;
      if (picked.effectiveAmount > 1) {
        return Row(
          children: [
            _PageAndIndexDisplay(
                page: widget.includePosition.pageFrom,
                index: widget.includePosition.indexInPageFrom,
                pageSize: widget.includePosition.pageSize),
            const SizedBox(width: 8),
            const Text("~"),
            const SizedBox(width: 8),
            _PageAndIndexDisplay(
                page: widget.includePosition.pageTo,
                index: widget.includePosition.indexInPageTo,
                pageSize: widget.includePosition.pageSize),
            const SizedBox(width: 8),
            Text("(×${picked.effectiveAmount})"),
            if (pageCrossingWidget != null) ...[
              const SizedBox(width: 8),
              pageCrossingWidget,
            ],
          ],
        );
      } else {
        return Row(children: [
          _PageAndIndexDisplay(
            page: widget.includePosition.pageFrom,
            index: widget.includePosition.indexInPageFrom,
            pageSize: widget.includePosition.pageSize,
          ),
        ]);
      }
    } else {
      return Text("Empty group",
          style: TextStyle(color: theme.colorScheme.error));
    }
  }

  Widget _buildPickedCardRow(BuildContext context, IncludeItem item,
      int cardIndex, bool isLocked, ThemeData theme) {
    final picked = item.pickedCards[cardIndex];
    final card = picked.duplexCard;

    final cardWidget = Expanded(
      child: Opacity(
        opacity: isLocked ? 0.5 : 1.0,
        child: PickedOneCard(
          basePath: widget.basePath,
          cardEach: card,
          cardSize: widget.cardSize,
          linkedCardFaces: widget.linkedCardFaces,
          projectSettings: widget.projectSettings,
          extraRender: [
            // Quantity display / editor
            if (isLocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '×${picked.effectiveAmount}',
                  style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                ),
              )
            else ...[
              SizedBox(
                width: 40,
                height: 32,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: picked.effectiveAmount > 1
                      ? () => widget.onCardAmountChanged(
                          cardIndex, picked.effectiveAmount - 1)
                      : null,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '×${picked.effectiveAmount}',
                  style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                ),
              ),
              SizedBox(
                width: 40,
                height: 32,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () => widget.onCardAmountChanged(
                      cardIndex, picked.effectiveAmount + 1),
                ),
              ),
              Tooltip(
                message: 'Remove Card',
                child: IconButton(
                  icon: Icon(Icons.delete,
                      size: 18, color: theme.colorScheme.error),
                  onPressed: () => widget.onCardRemoved(cardIndex),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [cardWidget],
      ),
    );
  }
}

class _PageAndIndexDisplay extends StatelessWidget {
  final int page;
  final int index;
  final int pageSize;

  const _PageAndIndexDisplay({
    required this.page,
    required this.index,
    required this.pageSize,
  });

  @override
  Widget build(BuildContext context) {
    final pageText = pageSize > 0
        ? "Page ${page + 1} (${index + 1} / $pageSize)"
        : "Page ${page + 1} (${index + 1})";
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
