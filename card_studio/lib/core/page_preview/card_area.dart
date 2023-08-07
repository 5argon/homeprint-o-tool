import 'dart:io';

import 'package:card_studio/core/card.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../page/layout/layout_helper.dart';

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
    List<Widget> stackChildren = [
      LayoutHelper(color: Colors.orange, visible: layout, flashing: false),
    ];

    final card = this.card;
    final baseDirectory = this.baseDirectory;
    if (card != null && baseDirectory != null) {
      stackChildren.add(
        Image.file(File(p.join(baseDirectory, card.relativeFilePath))),
      );
    }
    return Stack(
      children: stackChildren,
    );
  }
}
