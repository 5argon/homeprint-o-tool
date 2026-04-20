import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/core/save_file.dart';
import 'package:homeprint_o_tool/page/layout/layout_logic.dart';
import 'package:homeprint_o_tool/page/layout/layout_data.dart';
import 'package:homeprint_o_tool/page/review/pagination.dart';
import 'package:homeprint_o_tool/page/picks/picked_list_item.dart';
import 'package:homeprint_o_tool/page/picks/include_data.dart';

class IncludePosition {
  final int pageFrom;
  final int pageTo;
  final int indexInPageFrom;
  final int indexInPageTo;
  final int pageSize;

  IncludePosition({
    required this.pageFrom,
    required this.pageTo,
    required this.indexInPageFrom,
    required this.indexInPageTo,
    required this.pageSize,
  });
}

class PickedList extends StatefulWidget {
  final Includes includes;
  final Function(Includes) onIncludesChanged;
  final String basePath;
  final SizePhysical cardSize;
  final LinkedCardFaces linkedCardFaces;
  final ProjectSettings projectSettings;
  final LayoutData layoutData;
  final VoidCallback onClearPicked;
  final void Function(String) onShowToast;

  const PickedList({
    super.key,
    required this.includes,
    required this.onIncludesChanged,
    required this.basePath,
    required this.cardSize,
    required this.linkedCardFaces,
    required this.projectSettings,
    required this.layoutData,
    required this.onClearPicked,
    required this.onShowToast,
  });

  @override
  State<PickedList> createState() => _PickedListState();
}

class _PickedListState extends State<PickedList> {
  /// Index of the group being merged (source). null = not in merge mode.
  int? _mergeSourceIndex;

  final FocusNode _focusNode = FocusNode();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _exitMergeMode() {
    if (_mergeSourceIndex != null) {
      setState(() {
        _mergeSourceIndex = null;
      });
    }
  }

  void _enterMergeMode(int sourceIndex) {
    setState(() {
      _mergeSourceIndex = sourceIndex;
    });
    _focusNode.requestFocus();
  }

  void _mergeInto(int targetIndex) {
    final sourceIndex = _mergeSourceIndex;
    if (sourceIndex == null) return;
    final updated = widget.includes.toList();
    final target = updated[targetIndex];
    final source = updated[sourceIndex];
    target.pickedCards.addAll(source.pickedCards);
    target.pickedFromCardGroup = null;
    updated.removeAt(sourceIndex);
    widget.onIncludesChanged(updated);
    setState(() {
      _mergeSourceIndex = null;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  List<IncludePosition> _computePositions(CardsPagination pagination) {
    final List<IncludePosition> includePositions = [];
    final int pageSize = pagination.perPage;
    if (pageSize <= 0) {
      for (var i = 0; i < widget.includes.length; i++) {
        includePositions.add(IncludePosition(
            pageFrom: 0,
            pageTo: 0,
            indexInPageFrom: 0,
            indexInPageTo: 0,
            pageSize: 0));
      }
      return includePositions;
    }

    int currentPage = 0;
    int usedOnCurrentPage = 0;

    for (var i = 0; i < widget.includes.length; i++) {
      // If previous item filled a page exactly, next item starts at new page.
      if (usedOnCurrentPage >= pageSize) {
        currentPage += usedOnCurrentPage ~/ pageSize;
        usedOnCurrentPage = usedOnCurrentPage % pageSize;
      }

      final item = widget.includes[i];
      if (item.isPageBreak) {
        // Page break: advance to next page
        if (usedOnCurrentPage > 0) {
          currentPage++;
          usedOnCurrentPage = 0;
        }
        includePositions.add(IncludePosition(
            pageFrom: currentPage,
            pageTo: currentPage,
            indexInPageFrom: 0,
            indexInPageTo: 0,
            pageSize: pageSize));
        continue;
      }

      final int cardAmount = item.count();
      if (cardAmount == 0) {
        includePositions.add(IncludePosition(
            pageFrom: currentPage,
            pageTo: currentPage,
            indexInPageFrom: usedOnCurrentPage,
            indexInPageTo: usedOnCurrentPage,
            pageSize: pageSize));
        continue;
      }

      final int pageFrom = currentPage;
      final int indexInPageFrom = usedOnCurrentPage;

      // Walk through cards
      var remaining = cardAmount;
      while (remaining > 0) {
        final spaceLeft = pageSize - usedOnCurrentPage;
        if (remaining <= spaceLeft) {
          usedOnCurrentPage += remaining;
          remaining = 0;
        } else {
          remaining -= spaceLeft;
          currentPage++;
          usedOnCurrentPage = 0;
        }
      }

      final int pageTo = currentPage;
      final int indexInPageTo = usedOnCurrentPage - 1;

      includePositions.add(IncludePosition(
          pageFrom: pageFrom,
          pageTo: pageTo,
          indexInPageFrom: indexInPageFrom,
          indexInPageTo: indexInPageTo < 0 ? 0 : indexInPageTo,
          pageSize: pageSize));
    }
    return includePositions;
  }

  void _onReorder(int oldIndex, int newIndex) {
    final updated = widget.includes.toList();
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    widget.onIncludesChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final includes = widget.includes;
    final inMergeMode = _mergeSourceIndex != null;

    final Widget toolbar;
    if (inMergeMode) {
      toolbar = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          children: [
            Icon(Icons.merge_type,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Select the target group to merge into',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _exitMergeMode,
              icon: const Icon(Icons.close),
              label: const Text('Cancel Merge'),
            ),
          ],
        ),
      );
    } else {
      final newGroupButton = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ElevatedButton.icon(
          onPressed: () {
            final updated = includes.toList();
            updated.add(IncludeItem.freelyPicked());
            widget.onIncludesChanged(updated);
            _scrollToBottom();
          },
          icon: const Icon(Icons.create_new_folder_outlined),
          label: const Text('New Editable Picked Group'),
        ),
      );
      final pageBreakButton = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ElevatedButton.icon(
          onPressed: () {
            final updated = includes.toList();
            updated.add(IncludeItem.newPageBreak());
            widget.onIncludesChanged(updated);
            widget.onShowToast('Added Page Break to the end of the list');
            _scrollToBottom();
          },
          icon: const Icon(Icons.insert_page_break_outlined),
          label: const Text('New Page Break'),
        ),
      );
      final clearButton = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ElevatedButton.icon(
          onPressed: includes.isEmpty ? null : widget.onClearPicked,
          icon: const Icon(Icons.clear),
          label: const Text('Clear All'),
        ),
      );
      toolbar = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          newGroupButton,
          pageBreakButton,
          clearButton,
        ]),
      );
    }

    if (includes.isEmpty) {
      return Column(
        children: [
          toolbar,
          const Expanded(
            child: Center(
              child: Text(
                "No items picked yet.",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      );
    }

    final cardCountRowCol =
        calculateCardCountPerPage(widget.layoutData, widget.cardSize);
    final pagination = calculatePagination(includes, widget.layoutData,
        widget.cardSize, cardCountRowCol.rows, cardCountRowCol.columns);
    final includePositions = _computePositions(pagination);

    // Find the last editable group index
    int? lastEditableGroupIndex;
    for (int i = includes.length - 1; i >= 0; i--) {
      if (!includes[i].isPageBreak && !includes[i].isLocked) {
        lastEditableGroupIndex = i;
        break;
      }
    }

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          _exitMergeMode();
        }
      },
      child: Column(
        children: [
          toolbar,
          Expanded(
            child: ReorderableListView.builder(
              scrollController: _scrollController,
              buildDefaultDragHandles: false,
              itemCount: includes.length,
              onReorder: inMergeMode ? (a, b) {} : _onReorder,
              itemBuilder: (context, index) {
                final item = includes[index];
                final includePosition = includePositions[index];
                final isLastEditableGroup = lastEditableGroupIndex == index;
                return PickedListItem(
                  key: ValueKey(item),
                  index: index,
                  includeItem: item,
                  inMergeMode: inMergeMode,
                  isMergeSource: _mergeSourceIndex == index,
                  isLastEditableGroup: isLastEditableGroup,
                  onRemove: () {
                    final updatedIncludes = includes.toList();
                    updatedIncludes.removeAt(index);
                    widget.onIncludesChanged(updatedIncludes);
                  },
                  onUnlock: () {
                    final updatedIncludes = includes.toList();
                    updatedIncludes[index].unlock();
                    widget.onIncludesChanged(updatedIncludes);
                  },
                  onCardRemoved: (cardIndex) {
                    final updatedIncludes = includes.toList();
                    updatedIncludes[index].removeCardAt(cardIndex);
                    if (updatedIncludes[index].pickedCards.isEmpty) {
                      updatedIncludes.removeAt(index);
                    }
                    widget.onIncludesChanged(updatedIncludes);
                  },
                  onCardAmountChanged: (cardIndex, amount) {
                    final updatedIncludes = includes.toList();
                    updatedIncludes[index].setCardAmount(cardIndex, amount);
                    widget.onIncludesChanged(updatedIncludes);
                  },
                  onGroupNameChanged: (name) {
                    final updatedIncludes = includes.toList();
                    updatedIncludes[index].groupName = name;
                    widget.onIncludesChanged(updatedIncludes);
                  },
                  onClone: () {
                    final updatedIncludes = includes.toList();
                    updatedIncludes.insert(index + 1, item.clone());
                    widget.onIncludesChanged(updatedIncludes);
                  },
                  onSortAndMerge: () {
                    final updatedIncludes = includes.toList();
                    updatedIncludes[index].sortAndMerge();
                    widget.onIncludesChanged(updatedIncludes);
                  },
                  onStartMerge: () => _enterMergeMode(index),
                  onCancelMerge: _exitMergeMode,
                  onMergeTarget: () => _mergeInto(index),
                  basePath: widget.basePath,
                  cardSize: widget.cardSize,
                  linkedCardFaces: widget.linkedCardFaces,
                  projectSettings: widget.projectSettings,
                  includes: includes,
                  includePosition: includePosition,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
