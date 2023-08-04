import 'package:card_studio/core/project_settings.dart';

import 'layout_struct.dart';
import 'package:flutter/material.dart';
import 'output_layout_control.dart';
import 'page_preview.dart';

class LayoutPage extends StatelessWidget {
  final ProjectSettings projectSettings;
  final LayoutData layoutData;

  const LayoutPage({
    super.key,
    required this.projectSettings,
    required this.layoutData,
  });

  @override
  Widget build(BuildContext context) {
    var lrPreviewPadding = 8.0;
    var layoutPreview = PagePreview(
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
