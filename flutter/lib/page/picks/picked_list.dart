import 'package:flutter/material.dart';
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

class PickedList extends StatelessWidget {
  final Includes includes;
  final Function(Includes) onIncludesChanged;
  final String basePath;
  final SizePhysical cardSize;
  final LinkedCardFaces linkedCardFaces;
  final ProjectSettings projectSettings;
  final LayoutData layoutData;

  const PickedList({
    super.key,
    required this.includes,
    required this.onIncludesChanged,
    required this.basePath,
    required this.cardSize,
    required this.linkedCardFaces,
    required this.projectSettings,
    required this.layoutData,
  });

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

    final cardCountRowCol = calculateCardCountPerPage(layoutData, cardSize);
    final pagination = calculatePagination(includes, layoutData, cardSize,
        cardCountRowCol.rows, cardCountRowCol.columns);

    final List<IncludePosition> includePositions = [];
    final int pageSize = pagination.perPage;
    int runningCard = 0;
    for (var i = 0; i < includes.length; i++) {
      final int cardAmount = includes[i].linearize().length;
      final int pageFrom = runningCard ~/ pageSize;
      final int indexInPageFrom = runningCard % pageSize;
      runningCard += (cardAmount - 1);
      final int pageTo = runningCard ~/ pageSize;
      final int indexInPageTo = runningCard % pageSize;
      includePositions.add(IncludePosition(
          pageFrom: pageFrom,
          pageTo: pageTo,
          indexInPageFrom: indexInPageFrom,
          indexInPageTo: indexInPageTo,
          pageSize: pageSize));
      runningCard += 1;
    }

    return ListView.builder(
      itemCount: includes.length,
      itemBuilder: (context, index) {
        final item = includes[index];
        final includePosition = includePositions[index];
        return PickedListItem(
          includeItem: item,
          onRemove: () {
            final updatedIncludes = includes.toList();
            updatedIncludes.removeAt(index);
            onIncludesChanged(updatedIncludes);
          },
          basePath: basePath,
          cardSize: cardSize,
          linkedCardFaces: linkedCardFaces,
          projectSettings: projectSettings,
          includes: includes,
          includePosition: includePosition,
        );
      },
    );
  }
}
