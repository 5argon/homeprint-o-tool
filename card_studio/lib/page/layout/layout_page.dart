import 'package:homeprint_o_tool/core/project_settings.dart';

import '../../core/page_preview/page_preview.dart';
import '../../core/page_preview/page_preview_frame.dart';
import 'layout_struct.dart';
import 'package:flutter/material.dart';
import 'layout_page_form.dart';

class LayoutPage extends StatelessWidget {
  final ProjectSettings projectSettings;
  final LayoutData layoutData;
  final Function(LayoutData ld) onLayoutDataChanged;

  const LayoutPage({
    super.key,
    required this.projectSettings,
    required this.layoutData,
    required this.onLayoutDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    var lrPreviewPadding = 8.0;
    var layoutPreview = PagePreviewFrame(
      child: PagePreview(
        layoutData: layoutData,
        cards: [],
        layout: true,
        previewCutLine: true,
        baseDirectory: null,
        projectSettings: projectSettings,
        hideInnerCutLine: true,
        back: false,
      ),
    );

    var leftSide = Padding(
      padding: EdgeInsets.all(lrPreviewPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: layoutPreview,
          ),
        ],
      ),
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
            height: 450,
            child: Row(
              children: [
                Expanded(
                  child: leftSide,
                ),
              ],
            ),
          ),
        ),
        Flexible(
            child: LayoutPageForm(
          projectSettings: projectSettings,
          layoutData: layoutData,
          onLayoutDataChanged: (ld) {
            onLayoutDataChanged(ld);
          },
        ))
      ],
    );
  }
}
