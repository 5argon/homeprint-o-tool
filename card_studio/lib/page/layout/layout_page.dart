import 'package:flutter/material.dart';
import 'output_layout_control.dart';
import 'page_preview.dart';

class LayoutPage extends StatelessWidget {
  const LayoutPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var lrPreviewPadding = 8.0;
    var leftSide = Padding(
      padding: EdgeInsets.all(lrPreviewPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: PagePreview(Size(21, 29.7), Size(6.3, 8.8), Size(0.3, 0.3),
                Size(0.7, 0.7), 0.5, 0.02, []),
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
          child: leftSide,
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
                          onSelectionChanged: (p0) {},
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Flexible(child: OutputLayoutControl())
      ],
    );
  }
}
