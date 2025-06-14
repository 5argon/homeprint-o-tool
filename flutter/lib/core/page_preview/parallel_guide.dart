import 'package:flutter/material.dart';

class ParallelGuide extends StatelessWidget {
  const ParallelGuide({
    super.key,
    required this.spaceTaken,
    required this.axis,
    required this.color,
  });

  final Axis axis;
  final double spaceTaken;
  final Color color;

  @override
  Widget build(BuildContext context) {
    int flexMultiplier = 1000000;

    Border border;
    if (axis == Axis.vertical) {
      border = Border(
        left: BorderSide(
          color: color,
        ),
        right: BorderSide(
          color: color,
        ),
      );
    } else {
      border = Border(
        top: BorderSide(
          color: color,
        ),
        bottom: BorderSide(
          color: color,
        ),
      );
    }
    final Widget spacer;
    if (spaceTaken < 1) {
      spacer = Spacer(flex: (((1 - spaceTaken) / 2) * flexMultiplier).round());
    } else {
      spacer = Container();
    }

    var innerChildren = [
      spacer,
      Expanded(
        flex: (spaceTaken * flexMultiplier).round(),
        child: Container(
          decoration: BoxDecoration(border: border),
        ),
      ),
      spacer,
    ];
    if (axis == Axis.vertical) {
      return Row(
        children: innerChildren,
      );
    } else {
      return Column(
        children: innerChildren,
      );
    }
  }
}
