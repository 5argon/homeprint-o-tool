import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/core/label_and_form.dart';
import 'package:homeprint_o_tool/page/layout/layout_struct.dart';
import 'package:homeprint_o_tool/page/layout/paper_size_dropdown.dart';
import '../../core/form/width_height.dart';

class OutputLayoutControl extends StatelessWidget {
  final LayoutData layoutData;
  final Function(LayoutData ld) onLayoutDataChanged;
  const OutputLayoutControl({
    super.key,
    required this.layoutData,
    required this.onLayoutDataChanged,
  });

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

    final edgeCutGuideSize = layoutData.edgeCutGuideSize;
    final printerMarginInput = WidthHeightInput(
      width: edgeCutGuideSize.widthInUnit(edgeCutGuideSize.unit),
      height: edgeCutGuideSize.heightInUnit(edgeCutGuideSize.unit),
      unit: edgeCutGuideSize.unit,
      widthLabel: "Left, Right Edge",
      heightLabel: "Top, Bottom Edge",
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
            label: "Printer Margin",
            tooltip:
                "Reserve edge area on the paper where printing head cannot reach. This area is completely white, even the cutting guide will be placed next to this margin.",
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  printerMarginInput,
                ],
              ),
            ],
          ),
        ],
      ),
    );
    return paperRowPageSize;
  }
}
