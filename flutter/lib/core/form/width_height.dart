import 'package:flutter/material.dart';
import '../../page/layout/layout_data.dart';

class WidthHeightInput extends StatelessWidget {
  final double width;
  final double height;
  final PhysicalSizeType unit;
  final Function(double width, double height, PhysicalSizeType unit) onChanged;
  final String widthLabel;
  final String heightLabel;

  const WidthHeightInput({
    super.key,
    required this.width,
    required this.height,
    required this.unit,
    required this.onChanged,
    this.widthLabel = "Width",
    this.heightLabel = "Height",
  });

  void _onWidthSubmitted(String value) {
    final newWidth = double.tryParse(value) ?? width;
    onChanged(newWidth, height, unit);
  }

  void _onHeightSubmitted(String value) {
    final newHeight = double.tryParse(value) ?? height;
    onChanged(width, newHeight, unit);
  }

  void _onUnitChanged(PhysicalSizeType? newUnit) {
    if (newUnit != null && newUnit != unit) {
      switch (newUnit) {
        case PhysicalSizeType.centimeter:
          onChanged(width * 2.54, height * 2.54, PhysicalSizeType.centimeter);
          break;
        case PhysicalSizeType.inch:
          onChanged(width / 2.54, height / 2.54, PhysicalSizeType.inch);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final widthController =
        TextEditingController(text: width.toStringAsFixed(2));
    final heightController =
        TextEditingController(text: height.toStringAsFixed(2));

    final widthFocusNode = FocusNode();
    final heightFocusNode = FocusNode();

    widthFocusNode.addListener(() {
      if (!widthFocusNode.hasFocus) {
        _onWidthSubmitted(widthController.text); // Trigger update on defocus
      }
    });

    heightFocusNode.addListener(() {
      if (!heightFocusNode.hasFocus) {
        _onHeightSubmitted(heightController.text); // Trigger update on defocus
      }
    });

    return Row(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 100),
          child: TextFormField(
            controller: widthController,
            focusNode: widthFocusNode,
            decoration: InputDecoration(labelText: widthLabel),
            keyboardType: TextInputType.number,
            onFieldSubmitted:
                _onWidthSubmitted, // Triggered when Enter is pressed
          ),
        ),
        const SizedBox(width: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 100),
          child: TextFormField(
            controller: heightController,
            focusNode: heightFocusNode,
            decoration: InputDecoration(labelText: heightLabel),
            keyboardType: TextInputType.number,
            onFieldSubmitted:
                _onHeightSubmitted, // Triggered when Enter is pressed
          ),
        ),
        const SizedBox(width: 16),
        DropdownButton<PhysicalSizeType>(
          value: unit,
          items: const [
            DropdownMenuItem(
              value: PhysicalSizeType.centimeter,
              child: Text("cm"),
            ),
            DropdownMenuItem(
              value: PhysicalSizeType.inch,
              child: Text("inch"),
            ),
          ],
          onChanged: _onUnitChanged,
        ),
      ],
    );
  }
}
