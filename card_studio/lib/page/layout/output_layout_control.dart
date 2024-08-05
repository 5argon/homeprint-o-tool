import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/core/label_and_form.dart';
import 'package:homeprint_o_tool/core/number_text_form_field.dart';
import 'package:homeprint_o_tool/core/sliding_number_field.dart';
import 'package:homeprint_o_tool/page/layout/layout_struct.dart';
import 'package:homeprint_o_tool/page/layout/paper_size_dropdown.dart';

class OutputLayoutControl extends StatefulWidget {
  final LayoutData layoutData;
  final Function(LayoutData ld) onLayoutDataChanged;
  final PhysicalSizeType physicalSizeType;
  const OutputLayoutControl({
    super.key,
    required this.layoutData,
    required this.onLayoutDataChanged,
    required this.physicalSizeType,
  });

  @override
  State<OutputLayoutControl> createState() => _OutputLayoutControlState();
}

class _OutputLayoutControlState extends State<OutputLayoutControl> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paperSizeDropdown = PaperSizeDropdown(
      size: widget.layoutData.paperSize,
      onSizeChanged: (size) {
        widget.layoutData.paperSize = size;
        widget.onLayoutDataChanged(widget.layoutData);
      },
    );

    final sizeSuffix =
        widget.physicalSizeType == PhysicalSizeType.inch ? "inch" : "cm";
    var widthForm = NumberTextFormField(
        fixedPoint: 2,
        value: widget.layoutData.paperSize.width(widget.physicalSizeType),
        decoration: InputDecoration(
          labelText: "Width",
          suffixText: sizeSuffix,
        ),
        onChanged: (value) {
          widget.layoutData.paperSize = SizePhysical(
            value,
            widget.layoutData.paperSize.height(widget.physicalSizeType),
            widget.physicalSizeType,
          );
          widget.onLayoutDataChanged(widget.layoutData);
        });
    var heightForm = NumberTextFormField(
        fixedPoint: 2,
        value: widget.layoutData.paperSize.height(widget.physicalSizeType),
        decoration: InputDecoration(
          labelText: "Height",
          suffixText: sizeSuffix,
        ),
        onChanged: (value) {
          widget.layoutData.paperSize = SizePhysical(
            widget.layoutData.paperSize.width(widget.physicalSizeType),
            value,
            widget.physicalSizeType,
          );
          widget.onLayoutDataChanged(widget.layoutData);
        });
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
                  SizedBox(
                    width: 120,
                    child: widthForm,
                  ),
                  SizedBox(width: 16),
                  SizedBox(
                    width: 120,
                    child: heightForm,
                  ),
                ],
              ),
            ],
          ),
          LabelAndForm(
              label: "Printer Margin",
              tooltip:
                  "Reserve edge area on the paper where printing head cannot reach. This area is completely white, even the cutting guide will be placed next to this margin.",
              children: [
                SizedBox(
                  width: 150,
                  child: SlidingNumberField(
                      decoration: InputDecoration(
                        labelText: "Top, Bottom Edge",
                        suffixText: "cm",
                      ),
                      onChanged: (changeTo) {
                        widget.layoutData.edgeCutGuideSize = SizePhysical(
                          widget.layoutData.edgeCutGuideSize.widthCm,
                          changeTo,
                          PhysicalSizeType.centimeter,
                        );
                        widget.onLayoutDataChanged(widget.layoutData);
                      },
                      value: widget.layoutData.edgeCutGuideSize.heightCm,
                      fixedPoint: 2),
                ),
                SizedBox(width: 16),
                SizedBox(
                  width: 150,
                  child: SlidingNumberField(
                      decoration: InputDecoration(
                        labelText: "Left, Right Edge",
                        suffixText: "cm",
                      ),
                      onChanged: (changeTo) {
                        widget.layoutData.edgeCutGuideSize = SizePhysical(
                          changeTo,
                          widget.layoutData.edgeCutGuideSize.heightCm,
                          PhysicalSizeType.centimeter,
                        );
                        widget.onLayoutDataChanged(widget.layoutData);
                      },
                      value: widget.layoutData.edgeCutGuideSize.widthCm,
                      fixedPoint: 2),
                ),
              ]),
          Row(
            children: [
              Tooltip(
                message:
                    "Reserve padding area next to Printer Margin where cutting lines are placed. The larger the longer the lines.",
                child: Text("Cutting Guide Padding"),
              )
            ],
          ),
          Row(
            children: [
              Tooltip(
                  message:
                      "Normally available area left are divided to maximize amount of cards that could be fitted, which could result in uncomfortable amount of bleed to make a cut. This settings adds additional bleed area to the initial calculation, so you get more space for bleeds but lesser amount of cards per page.",
                  child: Text("Per-Card Padding")),
            ],
          ),
        ],
      ),
    );
    return paperRowPageSize;
  }
}
