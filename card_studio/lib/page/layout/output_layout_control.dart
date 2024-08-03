import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/page/layout/layout_struct.dart';

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
  final widthController = TextEditingController();
  final widthFocusNode = FocusNode();

  @override
  void dispose() {
    widthController.dispose();
    widthFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<SizePhysical>> paperSizeDropdownItems = [
      DropdownMenuItem(
        value: SizePhysical(11.7, 16.5, PhysicalSizeType.inch),
        child: Text("A3 (Vertical)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(16.5, 11.7, PhysicalSizeType.inch),
        child: Text("A3 (Horizontal)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(8.3, 11.7, PhysicalSizeType.inch),
        child: Text("A4 (Vertical)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(11.7, 8.3, PhysicalSizeType.inch),
        child: Text("A4 (Horizontal)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(5.8, 8.3, PhysicalSizeType.inch),
        child: Text("A5 (Vertical)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(8.3, 5.8, PhysicalSizeType.inch),
        child: Text("A5 (Horizontal)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(13, 19, PhysicalSizeType.inch),
        child: Text("Super-B (Vertical)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(19, 13, PhysicalSizeType.inch),
        child: Text("Super-B (Horizontal)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(8.5, 11, PhysicalSizeType.inch),
        child: Text("Letter (Vertical)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(11, 8.5, PhysicalSizeType.inch),
        child: Text("Letter (Horizontal)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(8.5, 14, PhysicalSizeType.inch),
        child: Text("Legal (Vertical)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(14, 8.5, PhysicalSizeType.inch),
        child: Text("Legal (Horizontal)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(11, 17, PhysicalSizeType.inch),
        child: Text("Tabloid/Ledger (Vertical)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(17, 11, PhysicalSizeType.inch),
        child: Text("Tabloid/Ledger (Horizontal)"),
      ),
    ];
    final paperSizeDropdown = DropdownButton(
      items: paperSizeDropdownItems,
      onChanged: (value) {
        if (value == null) return;
        widget.layoutData.paperSize = value;
        widget.onLayoutDataChanged(widget.layoutData);
      },
    );

    void updateValue() {
      final tryParsed = double.tryParse(widthController.text);
      if (tryParsed != null) {
        final newLayout = widget.layoutData;
        newLayout.paperSize = SizePhysical(
          tryParsed,
          widget.layoutData.paperSize.height(widget.physicalSizeType),
          widget.physicalSizeType,
        );
        widget.onLayoutDataChanged(newLayout);
      }
    }

    widthController.value = TextEditingValue(
      text: widget.layoutData.paperSize.widthInch.toStringAsFixed(2),
      selection: widthController.selection,
    );
    widthFocusNode.addListener(() {
      updateValue();
    });

    final sizeSuffix =
        widget.physicalSizeType == PhysicalSizeType.inch ? "inch" : "cm";
    var widthForm = TextFormField(
      controller: widthController,
      focusNode: widthFocusNode,
      onEditingComplete: updateValue,
      decoration: InputDecoration(
        labelText: "Width",
        suffixText: sizeSuffix,
      ),
    );
    var heightForm = TextFormField(
      initialValue: widget.layoutData.paperSize.heightInch.toStringAsFixed(2),
      decoration: InputDecoration(
        labelText: "Height",
        suffixText: sizeSuffix,
      ),
      onChanged: (value) {
        final tryParsed = double.tryParse(value);
        if (tryParsed != null) {
          widget.layoutData.paperSize = SizePhysical(
            widget.layoutData.paperSize.width(widget.physicalSizeType),
            tryParsed,
            widget.physicalSizeType,
          );
          widget.onLayoutDataChanged(widget.layoutData);
        }
      },
    );
    final paperRowPageSize = Column(
      children: [
        Row(
          children: [
            Text("Page Size"),
          ],
        ),
        Row(
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
    );
    return paperRowPageSize;
  }
}
