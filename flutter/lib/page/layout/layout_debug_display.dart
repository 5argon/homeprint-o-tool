import 'package:flutter/material.dart';
import '../../core/project_settings.dart';
import 'debug_with_warning.dart';
import '../../core/label_and_form.dart';
import 'layout_logic.dart';
import 'layout_data.dart';

class LayoutDebugDisplay extends StatelessWidget {
  final LayoutData layoutData;
  final ProjectSettings projectSettings;

  const LayoutDebugDisplay({
    super.key,
    required this.layoutData,
    required this.projectSettings,
  });

  @override
  Widget build(BuildContext context) {
    final cardCount =
        calculateCardCountPerPage(layoutData, projectSettings.cardSize);

    final allBleedVertical = layoutData.paperSize.heightCm -
        (2 * layoutData.marginSize.heightCm) -
        (2 * layoutData.edgeCutGuideSize.heightCm) -
        (cardCount.rows * projectSettings.cardSize.heightCm);
    final allBleedHorizontal = layoutData.paperSize.widthCm -
        (2 * layoutData.marginSize.widthCm) -
        (2 * layoutData.edgeCutGuideSize.widthCm) -
        (cardCount.columns * projectSettings.cardSize.widthCm);
    final bleedPerCardVertical = allBleedVertical / (cardCount.rows);
    final bleedPerCardHorizontal = allBleedHorizontal / (cardCount.columns);
    final bleedPerCardVerticalOneSide = bleedPerCardVertical / 2;
    final bleedPerCardHorizontalOneSide = bleedPerCardHorizontal / 2;
    final edgeDistanceVertical = (layoutData.marginSize.heightCm +
        layoutData.edgeCutGuideSize.heightCm +
        bleedPerCardVerticalOneSide);
    final edgeDistanceHorizontal = (layoutData.marginSize.widthCm +
        layoutData.edgeCutGuideSize.widthCm +
        bleedPerCardHorizontalOneSide);
    final gapBetweenCardsVertical = bleedPerCardVertical;
    final gapBetweenCardsHorizontal = bleedPerCardHorizontal;

    var debugRows = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Cards Per Page: "),
            Text(
                "${cardCount.columns} x ${cardCount.rows} = ${cardCount.columns * cardCount.rows} Cards"),
          ],
        ),
        DebugWithWarning(
          label: "Edge to cut line (horizontal)",
          value: edgeDistanceHorizontal,
        ),
        DebugWithWarning(
          label: "Edge to cut line (vertical)",
          value: edgeDistanceVertical,
        ),
        DebugWithWarning(
          label: "Gap between cards (horizontal)",
          value: gapBetweenCardsHorizontal,
        ),
        DebugWithWarning(
          label: "Gap between cards (vertical)",
          value: gapBetweenCardsVertical,
        ),
      ],
    );

    return LabelAndForm(label: "Layout Result", children: [debugRows]);
  }
}
