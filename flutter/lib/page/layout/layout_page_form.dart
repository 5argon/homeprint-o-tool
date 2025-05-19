import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/core/label_and_form.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/page/layout/layout_struct.dart';
import 'package:homeprint_o_tool/page/layout/paper_size_dropdown.dart';
import 'package:homeprint_o_tool/page/layout/layout_logic.dart';
import 'package:homeprint_o_tool/page/layout/skips_selection_dialog.dart';
import '../../core/form/width_height.dart';

class LayoutPageForm extends StatelessWidget {
  final LayoutData layoutData;
  final ProjectSettings projectSettings;
  final Function(LayoutData ld) onLayoutDataChanged;

  const LayoutPageForm({
    super.key,
    required this.layoutData,
    required this.projectSettings,
    required this.onLayoutDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Get rows and columns per page for the current layout
    final cardCountPerPage =
        calculateCardCountPerPage(layoutData, projectSettings.cardSize);

    final paperSizeDropdown = PaperSizeDropdown(
      size: layoutData.paperSize,
      onSizeChanged: (size) {
        layoutData.paperSize = size;
        onLayoutDataChanged(layoutData);
      },
    );

    final paperSize = layoutData.paperSize;
    final paperSizeInput = WidthHeightInput(
      width: paperSize.widthInUnit(paperSize.unit),
      height: paperSize.heightInUnit(paperSize.unit),
      unit: paperSize.unit,
      widthLabel: "Width",
      heightLabel: "Height",
      onChanged: (width, height, unit) {
        layoutData.paperSize = SizePhysical(width, height, unit);
        onLayoutDataChanged(layoutData);
      },
    );

    final marginSize = layoutData.marginSize;
    final printerMarginInput = WidthHeightInput(
      width: marginSize.widthInUnit(marginSize.unit),
      height: marginSize.heightInUnit(marginSize.unit),
      unit: marginSize.unit,
      widthLabel: "Left, Right",
      heightLabel: "Top, Bottom",
      onChanged: (width, height, unit) {
        layoutData.marginSize = SizePhysical(width, height, unit);
        onLayoutDataChanged(layoutData);
      },
    );

    final edgeCutGuideSize = layoutData.edgeCutGuideSize;
    final edgeCutGuideInput = WidthHeightInput(
      width: edgeCutGuideSize.widthInUnit(edgeCutGuideSize.unit),
      height: edgeCutGuideSize.heightInUnit(edgeCutGuideSize.unit),
      unit: edgeCutGuideSize.unit,
      widthLabel: "Left, Right",
      heightLabel: "Top, Bottom",
      onChanged: (width, height, unit) {
        layoutData.edgeCutGuideSize = SizePhysical(width, height, unit);
        onLayoutDataChanged(layoutData);
      },
    );

    // Create the skips form - shows existing skips and provides button to edit
    final hasSkips = layoutData.skips.isNotEmpty;

    final skipsForm = LabelAndForm(
      label: "Skips",
      help:
          "Specify card positions on the page that should be skipped during printing. "
          "Useful for working around faulty printers that consistently make mistakes at "
          "the same positions. Picked cards are always laid out left-to-right, top-to-bottom. "
          "If you have picked some cards already, be aware that this settings may increase amount "
          "of pages needed and change position of cards in the pages.",
      children: [
        Row(
          children: [
            if (hasSkips)
              ElevatedButton(
                  onPressed: () {
                    layoutData.skips = [];
                    onLayoutDataChanged(layoutData);
                  },
                  child: const Text("Clear Active Skips")),
            if (hasSkips) const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                // Open the skips selection dialog
                showDialog(
                  context: context,
                  builder: (context) => SkipsSelectionDialog(
                    rows: cardCountPerPage.rows,
                    columns: cardCountPerPage.columns,
                    currentSkips: layoutData.skips,
                    onSkipsChanged: (newSkips) {
                      layoutData.skips = newSkips;
                      onLayoutDataChanged(layoutData);
                    },
                  ),
                );
              },
              child: const Text("Select"),
            ),
          ],
        ),
      ],
    );

    final firstForm = Column(
      children: [
        LabelAndForm(
          label: "Paper Size",
          children: [
            Column(
              children: [
                Row(
                  children: [
                    paperSizeDropdown,
                  ],
                ),
                Row(children: [
                  paperSizeInput,
                ]),
              ],
            ),
          ],
        ),
        LabelAndForm(
          label: "Printer Margin Area",
          help:
              "Grey in the preview. Reserve edge area on the paper where printing head cannot reach. This area is completely white, even the cutting guide will be placed next to this margin.",
          children: [
            Row(
              children: [
                printerMarginInput,
              ],
            ),
          ],
        ),
      ],
    );

    final extraBleedForm = LabelAndForm(
      label: "Extra Bleeds",
      help:
          "Each rectangle formed by purple lines in the preview is divided into 9-slice by the red cut lines. Surrounding non-center slices are bleeds of each card to be cut away. By default app tries to fit as many cards as possible, and the leftover space are then distributed for bleeds. This might result in very small bleed area if cards are fitted tightly. Removing a row or a column from that optimal calculation is a simple way to get more room for bleeds to cut the card in that axis.",
      children: [
        SizedBox(
          width: 200,
          child: CheckboxListTile(
            title: const Text('Remove One Row'),
            value: layoutData.removeOneRow,
            onChanged: (bool? value) {
              layoutData.removeOneRow = value ?? false;
              onLayoutDataChanged(layoutData);
            },
          ),
        ),
        SizedBox(
          width: 200,
          child: CheckboxListTile(
            title: const Text('Remove One Column'),
            value: layoutData.removeOneColumn,
            onChanged: (bool? value) {
              layoutData.removeOneColumn = value ?? false;
              onLayoutDataChanged(layoutData);
            },
          ),
        ),
      ],
    );

    var cuttingGuideForm = LabelAndForm(
        label: "Cutting Guide Area",
        help:
            "Blue in the preview. Black cut guide lines along the edges will be drawn within this area.",
        children: [
          Row(
            children: [
              edgeCutGuideInput,
            ],
          ),
        ]);
    var secondForm = Column(
      children: [cuttingGuideForm, extraBleedForm, skipsForm],
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Define the breakpoint for switching layout
          final bool isWideScreen = constraints.maxWidth > 750;
          return isWideScreen
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    firstForm,
                    const SizedBox(width: 50),
                    secondForm,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    firstForm,
                    const SizedBox(height: 24),
                    secondForm,
                  ],
                );
        },
      ),
    );
  }
}
