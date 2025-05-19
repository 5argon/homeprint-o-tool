import 'package:homeprint_o_tool/page/layout/layout_data.dart';
import 'package:flutter/material.dart';

import 'package:homeprint_o_tool/page/layout/layout_helper.dart';

enum GuideDirection {
  vertical,
  horizontal,
}

/// Can draw 2 vertical or horizontal cut line depending on the size taken on the center.
class CutGuide extends StatelessWidget {
  final GuideDirection direction;

  /// Show background color in addition to the cut line.
  final bool layoutMode;

  /// Background color.
  final Color layoutGuideColor;

  /// Line expands equally from where you are supposed to cut.
  final SizePhysical lineSize;

  /// Size along the direction of this cut guide. (Perpendicular to cut line.)
  final double totalSize;

  /// Size along the direction of this cut guide. (Perpendicular to cut line.)
  final double cardSize;

  const CutGuide({
    super.key,
    required this.direction,
    required this.layoutMode,
    required this.layoutGuideColor,
    required this.lineSize,
    required this.totalSize,
    required this.cardSize,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutHelper(
      color: layoutGuideColor,
      visible: layoutMode,
      flashing: false,
    );
  }
}
