import 'package:card_studio/core/project_settings.dart';

import '../../core/page_preview/page_preview.dart';
import '../../core/page_preview/page_preview_frame.dart';
import 'layout_struct.dart';
import 'package:flutter/material.dart';
import 'output_layout_control.dart';

class LayoutPage extends StatefulWidget {
  final ProjectSettings projectSettings;
  final LayoutData layoutData;

  const LayoutPage({
    super.key,
    required this.projectSettings,
    required this.layoutData,
  });

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage> {
  bool _previewCuttingLine = false;
  @override
  Widget build(BuildContext context) {
    var lrPreviewPadding = 8.0;
    var layoutPreview = PagePreviewFrame(
      child: PagePreview(
        layoutData: widget.layoutData,
        cards: [],
        layout: true,
        previewCutLine: _previewCuttingLine,
        baseDirectory: null,
        projectSettings: widget.projectSettings,
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
            height: 500,
            child: Row(
              children: [
                Expanded(
                  child: leftSide,
                ),
              ],
            ),
          ),
        ),
        Flexible(child: OutputLayoutControl())
      ],
    );
  }
}
