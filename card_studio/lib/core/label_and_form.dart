import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/core/form/help_button.dart';

class LabelAndForm extends StatelessWidget {
  final String label;
  final List<Widget> children;
  final String? help;

  LabelAndForm({required this.label, required this.children, this.help});

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    final text = Text(
      label,
      style: textTheme.headlineSmall,
    );
    final Row labelWithHelp;
    final helpContent = help;
    if (helpContent != null) {
      final helpButton = HelpButton(
        title: label,
        paragraphs: [helpContent],
      );
      labelWithHelp = Row(
        children: [
          text,
          SizedBox(width: 8),
          helpButton,
        ],
      );
    } else {
      labelWithHelp = Row(
        children: [
          text,
        ],
      );
    }
    return Column(
      children: [
        Row(children: [labelWithHelp]),
        Row(
          children: children,
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
