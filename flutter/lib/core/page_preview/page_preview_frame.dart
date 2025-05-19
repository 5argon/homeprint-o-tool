import 'package:flutter/material.dart';

class PagePreviewFrame extends StatelessWidget {
  final Widget? child;
  PagePreviewFrame({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: child,
    );
  }
}
