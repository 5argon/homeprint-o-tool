import 'package:card_studio/core/project_settings.dart';
import 'package:card_studio/core/save_file.dart';

import 'layout_struct.dart';
import 'render.dart';
import 'package:flutter/material.dart';
import 'output_layout_control.dart';
import 'page_preview.dart';

var sampleLayoutData = LayoutData(
  SizePhysical(21, 29.7, PhysicalSizeType.centimeter),
  300,
  SizePhysical(0.5, 0.5, PhysicalSizeType.centimeter),
  SizePhysical(1, 1, PhysicalSizeType.centimeter),
  SizePhysical(0.5, 0.5, PhysicalSizeType.centimeter),
  ValuePhysical(0.3, PhysicalSizeType.centimeter),
  LayoutStyle.duplex,
);

var sampleProjectSettings = ProjectSettings(
    "",
    SizePhysical(6.3, 8.15, PhysicalSizeType.centimeter),
    SynthesizedBleed.mirror);

class LayoutPage extends StatelessWidget {
  const LayoutPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var lrPreviewPadding = 8.0;
    var pagePreviewLeft = PagePreview(
      sampleLayoutData,
      SizePhysical(6.3, 8.15, PhysicalSizeType.centimeter),
      [],
    );
    var pagePreviewRight = PagePreview(
      sampleLayoutData,
      SizePhysical(6.3, 8.15, PhysicalSizeType.centimeter),
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
                        ElevatedButton(
                            onPressed: () async {
                              renderRender(context, sampleProjectSettings,
                                  sampleLayoutData, []);
                            },
                            child: Text("Print")),
                        ElevatedButton(
                            onPressed: () async {
                              SaveFile.hack().saveToFile(
                                  "/Users/5argon/Desktop/TabooPrintProject",
                                  "test");
                            },
                            child: Text("Hack")),
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
        Flexible(child: OutputLayoutControl())
      ],
    );
  }
}
