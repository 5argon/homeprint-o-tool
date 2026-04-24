import 'dart:io';

import 'package:homeprint_o_tool/core/json.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/page/layout/layout_data.dart';
import 'package:homeprint_o_tool/page/layout/layout_logic.dart';

/// Generates an SVG string containing rounded-rectangle cut paths for every
/// card slot on the page.
///
/// All internal coordinates use points (1/72 inch). Some tooling treats
/// unitless SVG geometry as points; using points avoids accidental ppi/72
/// double-scaling while still preserving correct physical dimensions.
///
/// [rotation] must match the post-rotation applied when exporting the PNG.
/// The entire cut grid is transformed accordingly so lines align with the
/// rotated raster.
///
/// [cornerRadiusMm] is the corner radius in millimetres; it is clamped to at
/// most half the shortest card dimension.
String generateCutSvg(
  LayoutData layoutData,
  ProjectSettings projectSettings,
  double cornerRadiusMm,
  int pixelPerInch,
  Rotation rotation,
) {
  final cardSize = projectSettings.cardSize;
  final effectiveCutGuide =
      calculateEffectiveCutGuideSize(layoutData, cardSize);
  final cardCount = calculateCardCountPerPage(layoutData, cardSize);

  // Conversion factor: mm → pt (1 pt = 1/72 inch).
  const ptPerMm = 72.0 / 25.4;

  // Pre-rotation paper dimensions in pt.
  final paperWpt = layoutData.paperSize.widthInch * 72.0;
  final paperHpt = layoutData.paperSize.heightInch * 72.0;
  final paperWmm = layoutData.paperSize.widthCm * 10;
  final paperHmm = layoutData.paperSize.heightCm * 10;

  // After 90° rotation (either direction) the paper is H_pt wide, W_pt tall.
  final bool isRotated = rotation != Rotation.none;
  final double svgWpt = isRotated ? paperHpt : paperWpt;
  final double svgHpt = isRotated ? paperWpt : paperHpt;
  final double svgWmm = isRotated ? paperHmm : paperWmm;
  final double svgHmm = isRotated ? paperWmm : paperHmm;

  if (cardCount.rows <= 0 || cardCount.columns <= 0) {
    return '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<svg xmlns="http://www.w3.org/2000/svg" '
        'width="${svgWmm}mm" height="${svgHmm}mm" '
        'viewBox="0 0 ${_fmt(svgWpt)} ${_fmt(svgHpt)}"/>\n';
  }

  // All layout values in points.
  final marginXpt = layoutData.marginSize.widthCm * 10 * ptPerMm;
  final marginYpt = layoutData.marginSize.heightCm * 10 * ptPerMm;
  final guideXpt = effectiveCutGuide.widthCm * 10 * ptPerMm;
  final guideYpt = effectiveCutGuide.heightCm * 10 * ptPerMm;

  final gridWpt = paperWpt - (marginXpt + guideXpt) * 2;
  final gridHpt = paperHpt - (marginYpt + guideYpt) * 2;

  final slotWpt = gridWpt / cardCount.columns;
  final slotHpt = gridHpt / cardCount.rows;

  final cardWpt = cardSize.widthCm * 10 * ptPerMm;
  final cardHpt = cardSize.heightCm * 10 * ptPerMm;

  final bleedXpt = (slotWpt - cardWpt) / 2;
  final bleedYpt = (slotHpt - cardHpt) / 2;

  // Radius converted to pt and clamped.
  final rPt = (cornerRadiusMm * ptPerMm)
      .clamp(0.0, cardWpt / 2)
      .clamp(0.0, cardHpt / 2);

  // SVG group transform that rotates pre-rotation coordinates into post-rotation
  // space — mirrors exactly what renderOneSide does on the canvas:
  //
  //   CW90  : canvas.translate(H, 0) + canvas.rotate(pi/2)
  //           → point (x,y) → (H−y, x)
  //           SVG equivalent: translate(H,0) rotate(90)
  //
  //   CCW90 : canvas.translate(0, W) + canvas.rotate(-pi/2)
  //           → point (x,y) → (y, W−x)
  //           SVG equivalent: translate(0,W) rotate(-90)
  final String groupTransform;
  switch (rotation) {
    case Rotation.clockwise90:
      groupTransform = ' transform="translate(${_fmt(paperHpt)},0) rotate(90)"';
      break;
    case Rotation.counterClockwise90:
      groupTransform =
          ' transform="translate(0,${_fmt(paperWpt)}) rotate(-90)"';
      break;
    case Rotation.none:
      groupTransform = '';
      break;
  }

  final buf = StringBuffer();
  buf.writeln('<?xml version="1.0" encoding="UTF-8"?>');
  buf.writeln(
    '<svg xmlns="http://www.w3.org/2000/svg" '
    'width="${svgWmm}mm" height="${svgHmm}mm" '
    'viewBox="0 0 ${_fmt(svgWpt)} ${_fmt(svgHpt)}">',
  );
  // Keep stroke close to one output pixel at the chosen PPI.
  final strokeWidthPt = 72.0 / pixelPerInch;
  buf.writeln('  <g id="cut-lines" fill="none" stroke="black"'
      ' stroke-width="${_fmt(strokeWidthPt)}"$groupTransform>');

  for (var row = 0; row < cardCount.rows; row++) {
    for (var col = 0; col < cardCount.columns; col++) {
      final x = marginXpt + guideXpt + col * slotWpt + bleedXpt;
      final y = marginYpt + guideYpt + row * slotHpt + bleedYpt;
      buf.writeln(
        '    <rect'
        ' x="${_fmt(x)}" y="${_fmt(y)}"'
        ' width="${_fmt(cardWpt)}" height="${_fmt(cardHpt)}"'
        ' rx="${_fmt(rPt)}" ry="${_fmt(rPt)}"/>',
      );
    }
  }

  buf.writeln('  </g>');
  buf.writeln('</svg>');
  return buf.toString();
}

/// Writes [svgContent] to [filePath], creating the file if necessary.
Future<void> saveCutSvg(String svgContent, String filePath) async {
  final file = File(filePath);
  await file.writeAsString(svgContent);
}

/// Formats a double to at most 4 decimal places, stripping trailing zeros.
String _fmt(double v) {
  final s = v.toStringAsFixed(4);
  final trimmed = s.replaceAll(RegExp(r'\.?0+$'), '');
  return trimmed.isEmpty ? '0' : trimmed;
}
