import 'package:flutter/material.dart';

class LayoutHelper extends StatelessWidget {
  final bool visible;
  final bool flashing;
  final Color color;
  const LayoutHelper(
      {Key? key,
      required this.color,
      required this.visible,
      required this.flashing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(color: visible ? color : null);
  }
}
