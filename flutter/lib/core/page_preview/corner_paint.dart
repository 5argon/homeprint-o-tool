import 'package:flutter/material.dart';

class CornerPainter extends CustomPainter {
  CornerPainter({required this.guideHorizontal, required this.guideVertical, this.color = Colors.red, this.strokeWidth = 1.0, this.cornerLength = 10});

  // Fraction of width taken by the inner area (0..1)
  final double guideHorizontal;
  // Fraction of height taken by the inner area (0..1)
  final double guideVertical;
  final Color color;
  final double strokeWidth;
  final double cornerLength;

  @override
  void paint(Canvas canvas, Size size) {
    final double sh = size.height;
    final double sw = size.width;

    // Compute inner rectangle based on guides (centered band in both directions)
    final double innerW = (guideHorizontal.clamp(0.0, 1.0)) * sw;
    final double innerH = (guideVertical.clamp(0.0, 1.0)) * sh;

    if (innerW <= 0 || innerH <= 0) {
      return; // nothing to draw
    }

    final double left = (sw - innerW) / 2.0;
    final double top = (sh - innerH) / 2.0;
    final double right = left + innerW;
    final double bottom = top + innerH;

    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    // Clamp corner length to reasonable size based on inner dimensions
    final double maxCl = (innerW < innerH ? innerW : innerH) / 4.0;
    final double cl = cornerLength.clamp(0.0, maxCl);

    final Path path = Path()
      // Top Left
      ..moveTo(left, top-cl)
      ..lineTo(left, top + cl)
      ..moveTo(left-cl, top)
      ..lineTo(left + cl, top)
      // Top Right
      ..moveTo(right+cl, top)
      ..lineTo(right - cl, top)
      ..moveTo(right, top-cl)
      ..lineTo(right, top + cl)
      // Bottom Left
      ..moveTo(left-cl, bottom)
      ..lineTo(left + cl, bottom)
      ..moveTo(left, bottom+cl)
      ..lineTo(left, bottom - cl)
      // Bottom Right
      ..moveTo(right+cl, bottom)
      ..lineTo(right - cl, bottom)
      ..moveTo(right, bottom+cl)
      ..lineTo(right, bottom - cl);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CornerPainter oldDelegate) =>
      oldDelegate.guideHorizontal != guideHorizontal ||
      oldDelegate.guideVertical != guideVertical ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.cornerLength != cornerLength;

  @override
  bool shouldRebuildSemantics(CornerPainter oldDelegate) => false;
}
