import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class CardPainter extends CustomPainter {
  String imagePath;

  CardPainter({required this.imagePath}) {
    final fileImage = FileImage(File(imagePath));
  }

  @override
  void paint(Canvas canvas, Size size) {
    // paintImage(
    //     canvas: canvas,
    //     rect: Rect.fromCenter(center: Offset.zero, width: 100, height: 100),
    //     image: image);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
