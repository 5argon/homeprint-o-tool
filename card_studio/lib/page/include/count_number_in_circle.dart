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
    if (zeroValue) {
      color = Colors.grey;
    } else if (plus == true) {
      color = Theme.of(context).colorScheme.secondary;
    } else {
      color = Theme.of(context).colorScheme.primary;
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
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
