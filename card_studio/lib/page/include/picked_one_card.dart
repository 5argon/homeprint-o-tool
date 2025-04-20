import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/core/save_file.dart';
import 'package:homeprint_o_tool/page/card/group_member_list_item_one_side.dart';
import 'package:homeprint_o_tool/page/card/single_card_preview.dart';
import 'package:homeprint_o_tool/page/include/include_data.dart';
import 'package:homeprint_o_tool/page/layout/layout_struct.dart';
import 'package:flutter/material.dart';

import '../../core/card.dart';

class PickedOneCard extends StatelessWidget {
  final String basePath;
  final CardEach cardEach;
  final SizePhysical cardSize;
  final DefinedInstances definedInstances;
  final ProjectSettings projectSettings;
  final List<Widget>? extraRender;

  PickedOneCard({
    super.key,
    required this.basePath,
    required this.cardEach,
    required this.cardSize,
    required this.definedInstances,
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
                  bleedFactor:
                      cardEach.front?.effectiveContentExpand(projectSettings) ??
                          1.0,
                  instance: cardEach.front?.isInstance ?? false,
                  cardEachSingle: cardEach.front,
                )),
            SizedBox(width: 4),
            SizedBox(
                width: 100,
                height: 100,
                child: SingleCardPreview(
                  basePath: basePath,
                  cardSize: cardSize,
                  bleedFactor:
                      cardEach.back?.effectiveContentExpand(projectSettings) ??
                          1.0,
                  instance: cardEach.back?.isInstance ?? false,
                  cardEachSingle: cardEach.back,
                )),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      cardIcon,
                      SizedBox(width: 8),
                      Expanded(child: cardNameBox),
                      SizedBox(width: 16),
                      ...?extraRender,
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GroupMemberListItemOneSide(
                          isBack: false,
                          showCardSideLabel: true,
                          cardEachSingle: cardEach.front,
                          definedInstances: definedInstances,
                          instance: cardEach.front?.isInstance ?? false,
                          showEditButton: false,
                          basePath: basePath,
                          onCardEachSingleChange: (card) {},
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: GroupMemberListItemOneSide(
                          isBack: true,
                          showCardSideLabel: true,
                          cardEachSingle: cardEach.back,
                          definedInstances: definedInstances,
                          instance: cardEach.back?.isInstance ?? false,
                          showEditButton: false,
                          basePath: basePath,
                          onCardEachSingleChange: (card) {},
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
