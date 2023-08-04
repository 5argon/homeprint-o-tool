import 'package:card_studio/core/project_settings.dart';
import 'package:card_studio/core/save_file.dart';

import 'package:flutter/material.dart';

import '../layout/layout_struct.dart';
import '../layout/page_preview.dart';
import '../layout/render.dart';

class ReviewPage extends StatelessWidget {
  final ProjectSettings projectSettings;
  final LayoutData layoutData;

  const ReviewPage({
    super.key,
    required this.projectSettings,
    required this.layoutData,
  });

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var lrPreviewPadding = 8.0;
    var pagePreviewLeft = PagePreview(
      layoutData,
      projectSettings.cardSize,
      [],
    );

    var pagePreviewRight = PagePreview(
      layoutData,
      projectSettings.cardSize,
      [],
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
            "Front",
            style: textTheme.labelSmall,
          )
        ],
      ),
    );

    var dualPreviewRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: leftSide,
        ),
        Flexible(
          child: rightSide,
        ),
      ],
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
                        SegmentedButton(
                          segments: [
                            ButtonSegment(value: 0, label: Text("Dual")),
                            ButtonSegment(value: 1, label: Text("Front")),
                            ButtonSegment(value: 2, label: Text("Back")),
                          ],
                          selected: {0},
                          onSelectionChanged: (p0) {
                            print("do something");
                          },
                        ),
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
