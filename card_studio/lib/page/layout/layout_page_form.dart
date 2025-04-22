import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/core/label_and_form.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/page/layout/layout_struct.dart';
import 'package:homeprint_o_tool/page/layout/paper_size_dropdown.dart';
import '../../core/form/width_height.dart';
import 'layout_logic.dart';
import 'debug_with_warning.dart';

class LayoutPageForm extends StatelessWidget {
  final LayoutData layoutData;
  final ProjectSettings projectSettings;
  final Function(LayoutData ld) onLayoutDataChanged;

  const LayoutPageForm({
    Key? key,
    required this.layoutData,
    required this.projectSettings,
    required this.onLayoutDataChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

    final paperRowPageSize = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          LabelAndForm(
            label: "Paper Size",
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  paperSizeDropdown,
                  SizedBox(width: 16),
                  paperSizeInput,
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  printerMarginInput,
                ],
              ),
            ],
          ),
          LabelAndForm(
              label: "Cutting Guide Area",
              help:
                  "Blue in the preview. Black cut guide lines along the edges will be drawn within this area.",
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    edgeCutGuideInput,
                  ],
                ),
              ])
        ],
      ),
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

    final cardCount =
        calculateCardCountPerPage(layoutData, projectSettings.cardSize);

    final allBleedVertical = layoutData.paperSize.heightCm -
        (2 * layoutData.marginSize.heightCm) -
        (2 * layoutData.edgeCutGuideSize.heightCm) -
        (cardCount.rows * projectSettings.cardSize.heightCm);
    final allBleedHorizontal = layoutData.paperSize.widthCm -
        (2 * layoutData.marginSize.widthCm) -
        (2 * layoutData.edgeCutGuideSize.widthCm) -
        (cardCount.columns * projectSettings.cardSize.widthCm);
    final bleedPerCardVertical = allBleedVertical / (cardCount.rows);
    final bleedPerCardHorizontal = allBleedHorizontal / (cardCount.columns);
    final bleedPerCardVerticalOneSide = bleedPerCardVertical / 2;
    final bleedPerCardHorizontalOneSide = bleedPerCardHorizontal / 2;
    final edgeDistanceVertical = (layoutData.marginSize.heightCm +
        layoutData.edgeCutGuideSize.heightCm +
        bleedPerCardVerticalOneSide);
    final edgeDistanceHorizontal = (layoutData.marginSize.widthCm +
        layoutData.edgeCutGuideSize.widthCm +
        bleedPerCardHorizontalOneSide);
    final gapBetweenCardsVertical = bleedPerCardVertical;
    final gapBetweenCardsHorizontal = bleedPerCardHorizontal;

    var debugRows = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Cards Per Page: "),
            Text(
                "${cardCount.columns} x ${cardCount.rows} = ${cardCount.columns * cardCount.rows} Cards"),
          ],
        ),
        DebugWithWarning(
          label: "Edge to cut line (horizontal)",
          value: edgeDistanceHorizontal,
        ),
        DebugWithWarning(
          label: "Edge to cut line (vertical)",
          value: edgeDistanceVertical,
        ),
        DebugWithWarning(
          label: "Gap between cards (horizontal)",
          value: gapBetweenCardsHorizontal,
        ),
        DebugWithWarning(
          label: "Gap between cards (vertical)",
          value: gapBetweenCardsVertical,
        ),
      ],
    );
    final debugDisplay =
        LabelAndForm(label: "Layout Result", children: [debugRows]);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column: Existing form content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                paperRowPageSize,
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right column: Checkboxes for removeOneRow and removeOneColumn
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                extraBleedForm,
                debugDisplay,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
