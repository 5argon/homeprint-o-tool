import 'dart:math';

import 'package:card_studio/core/project_settings.dart';
import 'package:card_studio/page/include/include_data.dart';
import 'package:card_studio/page/review/pagination.dart';
import 'package:flutter/material.dart';

import '../../core/page_preview/page_preview.dart';
import '../../core/page_preview/page_preview_frame.dart';
import '../layout/layout_struct.dart';

enum PreviewStyle {
  dual,
  front,
  back,
}

class ReviewPage extends StatefulWidget {
  const ReviewPage(
      {super.key,
      required this.projectSettings,
      required this.layoutData,
      required this.includes,
      required this.skipIncludes,
      required this.baseDirectory});

  final ProjectSettings projectSettings;
  final LayoutData layoutData;
  final Includes includes;
  final Includes skipIncludes;
  final String baseDirectory;

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int _page = 1;
  bool _previewCutLine = true;
  PreviewStyle _previewStyle = PreviewStyle.dual;

  @override
  Widget build(BuildContext context) {
    final cards = cardsAtPage(widget.includes, widget.skipIncludes,
        widget.layoutData, widget.projectSettings.cardSize, _page);

    var textTheme = Theme.of(context).textTheme;
    var lrPreviewPadding = 8.0;
    var pagePreviewLeft = PagePreviewFrame(
      child: PagePreview(
        layoutData: widget.layoutData,
        cardSize: widget.projectSettings.cardSize,
        cards: cards.front,
        layout: false,
        previewCutLine: _previewCutLine,
        baseDirectory: widget.baseDirectory,
        hideInnerCutLine: true,
        back: false,
      ),
    );

    var pagePreviewRight = PagePreviewFrame(
      child: PagePreview(
        layoutData: widget.layoutData,
        cardSize: widget.projectSettings.cardSize,
        cards: cards.back,
        layout: false,
        previewCutLine: _previewCutLine,
        baseDirectory: widget.baseDirectory,
        hideInnerCutLine: true,
        back: true,
      ),
    );

    var leftSide = Padding(
      padding: EdgeInsets.all(lrPreviewPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: pagePreviewLeft,
          ),
          SizedBox(height: 4),
          Text(
            "Front",
            style: textTheme.labelSmall,
          )
        ],
      ),
    );

    var rightSide = Padding(
      padding: EdgeInsets.all(lrPreviewPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: pagePreviewRight,
          ),
          SizedBox(height: 4),
          Text(
            "Back",
            style: textTheme.labelSmall,
          )
        ],
      ),
    );

    List<Widget> previewChildren;
    switch (_previewStyle) {
      case PreviewStyle.dual:
        previewChildren = [
          Flexible(child: leftSide),
          Flexible(child: rightSide)
        ];
        break;
      case PreviewStyle.front:
        previewChildren = [
          Flexible(child: leftSide),
        ];
        break;
      case PreviewStyle.back:
        previewChildren = [
          Flexible(child: rightSide),
        ];
        break;
    }

    final cannotPageLeft = _page <= 1;
    final cannotPageRight = _page >= cards.pagination.totalPages;
    var paginationControl = Row(children: [
      IconButton(
          onPressed: cannotPageLeft
              ? null
              : () {
                  setState(() {
                    _page = max(1, _page - 1);
                  });
                },
          icon: Icon(Icons.arrow_left)),
      SizedBox(width: 8),
      Text("Page $_page of ${cards.pagination.totalPages}"),
      SizedBox(width: 8),
      IconButton(
          onPressed: cannotPageRight
              ? null
              : () {
                  setState(() {
                    _page = min(cards.pagination.totalPages, _page + 1);
                  });
                },
          icon: Icon(Icons.arrow_right)),
    ]);

    var dualPreviewRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: previewChildren,
    );
    return Column(
      children: [
        Expanded(child: dualPreviewRow),
        SizedBox(
          height: 50,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                paginationControl,
                SizedBox(width: 16),
                SizedBox(
                  width: 300,
                  child: SegmentedButton(
                    segments: [
                      ButtonSegment(value: 0, label: Text("Dual")),
                      ButtonSegment(value: 1, label: Text("Front")),
                      ButtonSegment(value: 2, label: Text("Back")),
                    ],
                    selected: {_previewStyle.index},
                    onSelectionChanged: (p0) {
                      setState(() {
                        _previewStyle = PreviewStyle.values[p0.first];
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Checkbox(
                    value: _previewCutLine,
                    onChanged: (checked) {
                      setState(() {
                        _previewCutLine = checked ?? false;
                      });
                    }),
                Text("Preview Cut Line")
              ],
            ),
          ),
        ),
        SizedBox(height: 40),
      ],
    );
  }
}
