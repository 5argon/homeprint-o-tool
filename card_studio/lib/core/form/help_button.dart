import 'package:flutter/material.dart';

class HelpButton extends StatelessWidget {
  final String title;
  final List<String> paragraphs;

  const HelpButton({
    Key? key,
    required this.title,
    required this.paragraphs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.help_outline),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < paragraphs.length; i++) ...[
                      Text(paragraphs[i]),
                      if (i < paragraphs.length - 1) SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
