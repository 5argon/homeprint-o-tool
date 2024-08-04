import 'package:flutter/material.dart';

class LabelAndForm extends StatelessWidget {
  final String label;
  final List<Widget> children;
  String? tooltip;

  LabelAndForm({required this.label, required this.children, this.tooltip});

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    final text = Text(
      label,
      style: textTheme.headlineSmall,
    );
    final tooltipWrapped = tooltip == null
        ? text
        : Tooltip(
            message: tooltip,
            child: text,
          );
    return Column(
      children: [
        Row(children: [tooltipWrapped]),
        Row(
          children: children,
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
