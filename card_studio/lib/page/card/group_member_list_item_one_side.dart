import 'package:card_studio/core/save_file.dart';
import 'package:flutter/material.dart';

import '../../core/card.dart';

class GroupMemberListItemOneSide extends StatelessWidget {
  final CardEachSingle? cardEachSingle;
  final DefinedInstances definedInstances;
  final bool isBack;

  GroupMemberListItemOneSide(
      {super.key,
      this.cardEachSingle,
      required this.definedInstances,
      required this.isBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(isBack ? "Back" : "Front"),
        Text(cardEachSingle?.relativeFilePath ?? "No file")
      ],
    );
  }
}
