import 'package:card_studio/core/card.dart';
import 'package:flutter/material.dart';

import '../../page/layout/layout_helper.dart';
import 'card_painter.dart';

class CardArea extends StatelessWidget {
  const CardArea({
    super.key,
    required this.baseDirectory,
    required this.card,
    required this.layout,
  });

  final String? baseDirectory;
  final CardEachSingle? card;
  final bool layout;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LayoutHelper(color: Colors.orange, visible: layout, flashing: false),
        CustomPaint(painter: CardPainter()),
      ],
    );
  }
}
