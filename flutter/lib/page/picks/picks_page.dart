import 'package:homeprint_o_tool/core/form/help_button.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/page/picks/include_data.dart';
import 'package:homeprint_o_tool/page/picks/picked_list.dart';
import 'package:homeprint_o_tool/page/layout/layout_logic.dart';
import 'package:homeprint_o_tool/page/layout/layout_data.dart';
import 'package:homeprint_o_tool/page/review/pagination.dart';
import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/page/picks/available_list.dart';

import 'package:homeprint_o_tool/core/save_file.dart';

class PicksPage extends StatefulWidget {
  final String basePath;
  final ProjectSettings projectSettings;
  final LayoutData layoutData;
  final DefinedCards definedCards;
  final LinkedCardFaces linkedCardFaces;
  final Includes includes;
  final Includes skipIncludes;
  final Function(Includes) onIncludesChanged;
  final Function(Includes) onSkipIncludesChanged;
  PicksPage(
      {super.key,
      required this.basePath,
      required this.projectSettings,
      required this.layoutData,
      required this.definedCards,
      required this.linkedCardFaces,
      required this.includes,
      required this.skipIncludes,
      required this.onIncludesChanged,
      required this.onSkipIncludesChanged});

  @override
  State<PicksPage> createState() => _PicksPageState();
}

class _PicksPageState extends State<PicksPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    _previousCount = widget.includes.fold(0, (p, e) => p + e.count());
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.95), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(covariant PicksPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newCount = widget.includes.fold(0, (p, e) => p + e.count());
    if (newCount != _previousCount && newCount > _previousCount) {
      _bounceController.forward(from: 0);
    }
    _previousCount = newCount;
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final includes = widget.includes;
    final cardCountPerPage = calculateCardCountPerPage(
        widget.layoutData, widget.projectSettings.cardSize);
    final pagination = calculatePagination(
        includes,
        widget.layoutData,
        widget.projectSettings.cardSize,
        cardCountPerPage.rows,
        cardCountPerPage.columns);
    final allCount = countIncludes(includes);

    if (pagination.perPage == 0) {
      return const Text("No cards available");
    }

    final modulo = allCount % pagination.perPage;
    final int lastPageCount;
    if (modulo == 0) {
      if (allCount == 0) {
        lastPageCount = 0;
      } else {
        lastPageCount = pagination.perPage;
      }
    } else {
      lastPageCount = modulo;
    }
    final remaining = pagination.perPage - lastPageCount;

    final lastPageText = [
      TextSpan(
        text: "Last Page : $lastPageCount / ${pagination.perPage} Cards",
      ),
    ];

    final pageHelp = HelpButton(title: "Picks Page", paragraphs: [
      "The Available tab shows all card groups that the project has defined. You can \"pick\" either a group which picks each card inside equal to their quantity, or a single copy of any individual card inside the group.",
      "Each pick appends to the list in \"Picked\" tab sequentially, and cards flow from one page to the next in that order, so the order that you click these picking buttons matters in the final layout.",
    ]);

    if (remaining > 0) {
      lastPageText.add(
        TextSpan(
          text: " ($remaining Card${remaining == 1 ? '' : 's'} Left)",
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }

    final lastPageDebugger = RichText(
      text: TextSpan(
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyMedium?.color),
        children: lastPageText,
      ),
    );

    final allCountText = Row(
      children: [
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              "Total ${pagination.totalPages} Page${pagination.totalPages > 1 ? 's' : ''}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: lastPageDebugger,
          ),
        ),
      ],
    );
    final cardCount = includes.fold(0, (p, e) => p + e.count());
    final groupCount = includes.where((e) => !e.isPageBreak).length;

    final availableList = AvailableList(
      basePath: widget.basePath,
      projectSettings: widget.projectSettings,
      definedCards: widget.definedCards,
      linkedCardFaces: widget.linkedCardFaces,
      includes: includes,
      skipIncludes: widget.skipIncludes,
      onIncludesChanged: widget.onIncludesChanged,
      onShowToast: _showToast,
      onPickEachGroupOnce: () {
        final appended = includes.toList();
        appended.addAll(
            widget.definedCards.map((e) => IncludeItem.fromCardGroup(e)));
        widget.onIncludesChanged(appended);
      },
    );

    final pickedList = PickedList(
      includes: includes,
      onIncludesChanged: widget.onIncludesChanged,
      basePath: widget.basePath,
      cardSize: widget.projectSettings.cardSize,
      linkedCardFaces: widget.linkedCardFaces,
      projectSettings: widget.projectSettings,
      layoutData: widget.layoutData,
      onClearPicked: () {
        widget.onIncludesChanged([]);
        widget.onSkipIncludesChanged([]);
      },
      onShowToast: _showToast,
    );

    final tabController = Expanded(
        child: DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: "Available Groups"),
              Tab(
                child: AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _bounceAnimation.value,
                      child: child,
                    );
                  },
                  child: Text(
                      "Picked Groups ($groupCount Groups, $cardCount Cards)"),
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                availableList,
                pickedList,
              ],
            ),
          ),
        ],
      ),
    ));

    var topButtonRow = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(spacing: 16, children: [
          allCountText,
          pageHelp,
        ]),
      ],
    );
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: topButtonRow,
          ),
          tabController,
        ],
      ),
    );
  }
}
