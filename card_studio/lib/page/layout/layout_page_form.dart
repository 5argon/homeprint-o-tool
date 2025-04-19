import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/core/label_and_form.dart';
import 'package:homeprint_o_tool/page/layout/layout_struct.dart';
import 'package:homeprint_o_tool/page/layout/paper_size_dropdown.dart';
import '../../core/form/width_height.dart';

class LayoutPageForm extends StatefulWidget {
  final LayoutData layoutData;
  final Function(LayoutData ld) onLayoutDataChanged;

  const LayoutPageForm({
    Key? key,
    required this.layoutData,
    required this.onLayoutDataChanged,
  }) : super(key: key);

  @override
  _LayoutPageFormState createState() => _LayoutPageFormState();
}

class _LayoutPageFormState extends State<LayoutPageForm> {
  @override
  Widget build(BuildContext context) {
    final paperSizeDropdown = PaperSizeDropdown(
      size: widget.layoutData.paperSize,
      onSizeChanged: (size) {
        widget.layoutData.paperSize = size;
        widget.onLayoutDataChanged(widget.layoutData);
      },
    );

    final paperSize = widget.layoutData.paperSize;
    final paperSizeInput = WidthHeightInput(
      width: paperSize.widthInUnit(paperSize.unit),
      height: paperSize.heightInUnit(paperSize.unit),
      unit: paperSize.unit,
      widthLabel: "Width",
      heightLabel: "Height",
      onChanged: (width, height, unit) {
        widget.layoutData.paperSize = SizePhysical(width, height, unit);
        widget.onLayoutDataChanged(widget.layoutData);
      },
    );

    final marginSize = widget.layoutData.marginSize;
    final printerMarginInput = WidthHeightInput(
      width: marginSize.widthInUnit(marginSize.unit),
      height: marginSize.heightInUnit(marginSize.unit),
      unit: marginSize.unit,
      widthLabel: "Left, Right",
      heightLabel: "Top, Bottom",
      onChanged: (width, height, unit) {
        widget.layoutData.marginSize = SizePhysical(width, height, unit);
        widget.onLayoutDataChanged(widget.layoutData);
      },
    );

    final edgeCutGuideSize = widget.layoutData.edgeCutGuideSize;
    final edgeCutGuideInput = WidthHeightInput(
      width: edgeCutGuideSize.widthInUnit(edgeCutGuideSize.unit),
      height: edgeCutGuideSize.heightInUnit(edgeCutGuideSize.unit),
      unit: edgeCutGuideSize.unit,
      widthLabel: "Left, Right",
      heightLabel: "Top, Bottom",
      onChanged: (width, height, unit) {
        widget.layoutData.edgeCutGuideSize = SizePhysical(width, height, unit);
        widget.onLayoutDataChanged(widget.layoutData);
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
            tooltip:
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
              tooltip:
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
                LabelAndForm(
                  label: "Extra Bleeds",
                  tooltip:
                      "By default app tries to fit as many cards as possible, and the leftover space are then distributed for bleeds. This might result in very small bleed area if cards are fitted tightly. By removing a row or a column from that optimal calculation, you gain more room to cut the card in that axis.",
                  children: [
                    SizedBox(
                      width: 200,
                      child: CheckboxListTile(
                        title: const Text('Remove One Row'),
                        value: widget.layoutData.removeOneRow,
                        onChanged: (bool? value) {
                          setState(() {
                            widget.layoutData.removeOneRow = value ?? false;
                            widget.onLayoutDataChanged(widget.layoutData);
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: CheckboxListTile(
                        title: const Text('Remove One Column'),
                        value: widget.layoutData.removeOneColumn,
                        onChanged: (bool? value) {
                          setState(() {
                            widget.layoutData.removeOneColumn = value ?? false;
                            widget.onLayoutDataChanged(widget.layoutData);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
