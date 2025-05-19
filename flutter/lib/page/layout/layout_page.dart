import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/page/layout/layout_debug_display.dart';

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

    var leftSideTop = Padding(
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

    var rightSideTop = Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutDebugDisplay(
            layoutData: layoutData, projectSettings: projectSettings),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWideScreen = constraints.maxWidth > 700;

        return SingleChildScrollView(
          child: Column(
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    height: isWideScreen ? 400 : null,
                    child: isWideScreen
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              leftSideTop,
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [rightSideTop],
                              )
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 300,
                                child: leftSideTop,
                              ),
                              SizedBox(height: 10),
                              rightSideTop,
                            ],
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: LayoutPageForm(
                  projectSettings: projectSettings,
                  layoutData: layoutData,
                  onLayoutDataChanged: (ld) {
                    onLayoutDataChanged(ld);
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
