import 'package:flutter/material.dart';

class CountNumberInCircle extends StatelessWidget {
  const CountNumberInCircle({
    super.key,
    required this.value,
    this.plus,
  });

  final int value;
  final bool? plus;

  @override
  Widget build(BuildContext context) {
    final zeroValue = value == 0;
    final Color color;
    final theme = Theme.of(context);
    if (zeroValue) {
      color = theme.colorScheme.surfaceContainerHigh;
    } else if (plus == true) {
      color = theme.colorScheme.secondaryContainer;
    } else {
      color = theme.colorScheme.primaryContainer;
    }
    return Container(
      width: 50,
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        plus == true ? "+${value.toString()}" : value.toString(),
        textAlign: TextAlign.center,
        style: TextStyle(
            color: plus == true
                ? theme.colorScheme.onSecondaryContainer
                : theme.colorScheme.onPrimaryContainer),
      ),
    );
  }
}
