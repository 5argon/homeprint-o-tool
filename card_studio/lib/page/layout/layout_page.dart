import 'package:card_studio/core/project_settings.dart';
import 'package:card_studio/page/layout/page_preview_frame.dart';

import 'layout_struct.dart';
import 'package:flutter/material.dart';
import 'output_layout_control.dart';
import 'page_preview.dart';

class LayoutPage extends StatefulWidget {
  final ProjectSettings _projectSettings;
  final LayoutData _layoutData;

  const LayoutPage({
    super.key,
    required ProjectSettings projectSettings,
    required LayoutData layoutData,
  })  : _projectSettings = projectSettings,
        _layoutData = layoutData;

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
        widget._layoutData,
        widget._projectSettings.cardSize,
        [],
        true,
        _previewCuttingLine,
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
