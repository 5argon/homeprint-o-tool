import 'package:flutter/material.dart';

class DebugWithWarning extends StatelessWidget {
  final String label;
  final double value;

  const DebugWithWarning({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const lowThresholdCm = 1.0;
    const veryLowThresholdCm = 0.5;

    Widget? warningIcon;
    if (value < veryLowThresholdCm) {
      warningIcon = Tooltip(
        message: "Might be very difficult to cut.",
        child: Icon(Icons.warning, color: Theme.of(context).colorScheme.error),
      );
    } else if (value < lowThresholdCm) {
      warningIcon = Tooltip(
        message: "Might be difficult to cut.",
        child:
            Icon(Icons.warning, color: Theme.of(context).colorScheme.primary),
      );
    }

    return Container(
      height: 30, // Set a fixed minimum height for the row
      alignment: Alignment.center, // Align contents vertically
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Ensure vertical alignment
        children: [
          Text("$label: "),
          Text("${value.toStringAsFixed(2)} cm"),
          if (warningIcon != null) ...[SizedBox(width: 4), warningIcon],
        ],
      ),
    );
  }
}
