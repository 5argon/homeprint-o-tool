import 'package:flutter/material.dart';

/// Updates and format the number on ENTER and defocus.
class NumberTextFormField extends StatefulWidget {
  final Function(double) onChanged;
  final InputDecoration? decoration;
  final double value;
  final int fixedPoint;
  const NumberTextFormField({
    super.key,
    required this.onChanged,
    required this.value,
    required this.fixedPoint,
    this.decoration,
  });

  @override
  State<NumberTextFormField> createState() => _NumberTextFormFieldState();
}

class _NumberTextFormFieldState extends State<NumberTextFormField> {
  final editingController = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    editingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void updateValue() {
      final tryParsed = double.tryParse(editingController.text);
      if (tryParsed != null) {
        widget.onChanged(tryParsed);
      }
    }

    editingController.value = TextEditingValue(
      text: widget.value.toStringAsFixed(2),
      selection: editingController.selection,
    );
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        updateValue();
      }
    });

    return TextFormField(
      controller: editingController,
      focusNode: focusNode,
      onEditingComplete: () {
        updateValue();
        focusNode.unfocus();
      },
      decoration: widget.decoration,
    );
  }
}
