import 'package:flutter/material.dart';

class CountNumberInCircle extends StatelessWidget {
  const CountNumberInCircle({
    super.key,
    required this.value,
  });

  final int value;

  @override
  Widget build(BuildContext context) {
    final zeroValue = value == 0;
    return Container(
      width: 35,
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(50),
      ),
      child: zeroValue
          ? null
          : Text(
              value.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
    );
  }
}
