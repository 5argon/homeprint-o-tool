import 'package:card_studio/core/project_settings.dart';
import 'package:card_studio/page/include/include_data.dart';
import 'package:card_studio/page/review/pagination.dart';
import 'package:flutter/material.dart';

import '../layout/layout_struct.dart';
import '../layout/page_preview.dart';

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
      required this.includes});

  final ProjectSettings projectSettings;
  final LayoutData layoutData;
  final Includes includes;

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int _page = 1;
  bool _previewCutLine = false;
  PreviewStyle _previewStyle = PreviewStyle.dual;

  @override
  Widget build(BuildContext context) {
    final cards = cardsAtPage(widget.includes, widget.layoutData,
        widget.projectSettings.cardSize, _page);

    var textTheme = Theme.of(context).textTheme;
    var lrPreviewPadding = 8.0;
    var pagePreviewLeft = PagePreview(
      widget.layoutData,
      widget.projectSettings.cardSize,
      cards.front,
      false,
      _previewCutLine,
    );

    var pagePreviewRight = PagePreview(
      widget.layoutData,
      widget.projectSettings.cardSize,
      cards.back,
      false,
      _previewCutLine,
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

    var dualPreviewRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: previewChildren,
    );

    return Column(
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          child: SizedBox(
            height: 500,
            child: Column(
              children: [
                Expanded(
                  child: dualPreviewRow,
                ),
                SizedBox(
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                )
              ],
            ),
          ),
        ),
        Flexible(child: Text("Review Control"))
      ],
    );
  }
}
