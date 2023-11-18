import 'package:card_studio/core/save_file.dart';
import 'package:flutter/material.dart';

import '../../core/card.dart';

class GroupMemberListItemOneSide extends StatelessWidget {
  final CardEachSingle? cardEachSingle;
  final DefinedInstances definedInstances;
  final bool isBack;
  final bool instance;
  final bool showEditButton;

  GroupMemberListItemOneSide({
    super.key,
    this.cardEachSingle,
    required this.definedInstances,
    required this.isBack,
    required this.instance,
    required this.showEditButton,
  });

  @override
  Widget build(BuildContext context) {
    Widget instanceMark;
    final editButton = IconButton(onPressed: () {}, icon: Icon(Icons.edit));
    final cardEachSingle = this.cardEachSingle;
    if (cardEachSingle != null && cardEachSingle.isInstance) {
      instanceMark = Row(
        children: [
          Container(
            color: Colors.red,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
              child: Text("Instance"),
            ),
          ),
          SizedBox(width: 4),
        ],
      );
    } else {
      instanceMark = Container();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: Row(
        children: [
          showEditButton ? editButton : Container(),
          SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isBack ? "Back" : "Front",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline)),
                Row(
                  children: [
                    instanceMark,
                    Expanded(
                        child: Text(
                            cardEachSingle?.relativeFilePath ?? "(Empty)")),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
