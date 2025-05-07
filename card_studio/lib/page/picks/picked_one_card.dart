import 'package:homeprint_o_tool/core/layout_const.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/core/save_file.dart';
import 'package:homeprint_o_tool/page/card/group_member_list_item_one_side.dart';
import 'package:homeprint_o_tool/page/card/single_card_preview.dart';
import 'package:homeprint_o_tool/page/layout/layout_struct.dart';
import 'package:flutter/material.dart';

import '../../core/card.dart';

class PickedOneCard extends StatelessWidget {
  final String basePath;
  final DuplexCard cardEach;
  final SizePhysical cardSize;
  final LinkedCardFaces linkedCardFaces;
  final ProjectSettings projectSettings;
  final List<Widget>? extraRender;

  PickedOneCard({
    super.key,
    required this.basePath,
    required this.cardEach,
    required this.cardSize,
    required this.linkedCardFaces,
    required this.projectSettings,
    this.extraRender,
  });

  @override
  Widget build(BuildContext context) {
    final cardNameBox = Text(
      cardEach.name ?? "",
    );
    final cardIcon = Icon(
      Icons.credit_card,
      size: 20,
    );
    var firstRow = LayoutBuilder(builder: (context, constraints) {
      final lowWidth = constraints.maxWidth < cardListLowWidth;
      if (lowWidth) {
        return Column(
          children: [
            Row(
              children: [
                cardIcon,
                SizedBox(width: 8),
                Expanded(child: cardNameBox),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ...?extraRender,
              ],
            ),
          ],
        );
      }
      return Row(
        children: [
          cardIcon,
          SizedBox(width: 8),
          Expanded(child: cardNameBox),
          SizedBox(width: 16),
          ...?extraRender,
        ],
      );
    });
    var leftCardFace = GroupMemberListItemOneSide(
      isBack: false,
      forLinkedCardFaceTab: false,
      cardFace: cardEach.getFront(linkedCardFaces),
      linkedCardFaces: linkedCardFaces,
      showEditButton: false,
      basePath: basePath,
      onCardChange: (card) {},
      projectSettings: projectSettings,
    );
    var rightCardFace = GroupMemberListItemOneSide(
      isBack: true,
      forLinkedCardFaceTab: false,
      cardFace: cardEach.getBack(linkedCardFaces),
      linkedCardFaces: linkedCardFaces,
      showEditButton: false,
      basePath: basePath,
      onCardChange: (card) {},
      projectSettings: projectSettings,
    );
    var cardFacesRow = LayoutBuilder(builder: (context, constraints) {
      var lowWidth = constraints.maxWidth < cardListLowWidth;
      if (lowWidth) {
        return Column(
          children: [
            leftCardFace,
            SizedBox(height: 16),
            rightCardFace,
          ],
        );
      }
      return Row(
        children: [
          Expanded(
            child: leftCardFace,
          ),
          SizedBox(width: 16),
          Expanded(
            child: rightCardFace,
          )
        ],
      );
    });
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            SizedBox(
                width: 100,
                height: 100,
                child: SingleCardPreview(
                  basePath: basePath,
                  cardSize: cardSize,
                  bleedFactor: cardEach
                          .getFront(linkedCardFaces)
                          ?.effectiveContentExpand(projectSettings) ??
                      1.0,
                  cardFace: cardEach.getFront(linkedCardFaces),
                )),
            SizedBox(width: 4),
            SizedBox(
                width: 100,
                height: 100,
                child: SingleCardPreview(
                  basePath: basePath,
                  cardSize: cardSize,
                  bleedFactor: cardEach
                          .getBack(linkedCardFaces)
                          ?.effectiveContentExpand(projectSettings) ??
                      1.0,
                  cardFace: cardEach.getBack(linkedCardFaces),
                )),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  firstRow,
                  cardFacesRow,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
