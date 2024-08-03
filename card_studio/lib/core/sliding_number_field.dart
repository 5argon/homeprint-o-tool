import 'package:flutter/material.dart';

class SlidingNumberField extends StatelessWidget {
  final Function(double) onChanged;
  final double value;
  final int fixedPoint;
  final InputDecoration? decoration;
  const SlidingNumberField({
    Key? key,
    required this.onChanged,
    required this.value,
    required this.fixedPoint,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: decoration,
      initialValue: value.toStringAsFixed(fixedPoint),
      onChanged: (value) {
        final tryParsed = double.tryParse(value);
        if (tryParsed != null) {
          onChanged(tryParsed);
        }
      },
    );
  }
}
