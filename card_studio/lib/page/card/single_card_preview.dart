import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../core/card.dart';

class SingleCardPreview extends StatelessWidget {
  final String basePath;
  final CardEachSingle? cardEachSingle;
  final bool instance;

  SingleCardPreview({
    super.key,
    required this.basePath,
    this.cardEachSingle,
    required this.instance,
  });

  @override
  Widget build(BuildContext context) {
    final cardEachSingle = this.cardEachSingle;
    if (cardEachSingle == null) {
      return Text("None");
    }
    final joinedPath = p.join(basePath, cardEachSingle.relativeFilePath);
    final image = Image.file(File(joinedPath));
    return image;
  }
}
