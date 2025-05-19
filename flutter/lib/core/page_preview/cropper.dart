import 'package:flutter/material.dart';

class Cropper extends StatelessWidget {
  const Cropper({
    super.key,
    required this.cropRect,
    required this.renderChild,
  });

  final EdgeInsets cropRect;
  final Widget renderChild;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Align(
        alignment: Alignment.bottomRight,
        heightFactor: 1 - cropRect.top,
        widthFactor: 1 - cropRect.left,
        child: ClipRect(
            child: Align(
                alignment: Alignment.topLeft,
                heightFactor: 1 - cropRect.bottom,
                widthFactor: 1 - cropRect.right,
                child: renderChild)),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return ClipRect(
  //     child: Align(
  //       alignment: Alignment.bottomRight,
  //       heightFactor: 1 - cropRect.top,
  //       widthFactor: 1 - cropRect.left,
  //       child: ClipRect(
  //           child: Align(
  //               alignment: Alignment.topLeft,
  //               heightFactor: 1 - cropRect.bottom,
  //               widthFactor: 1 - cropRect.right,
  //               child: renderChild)),
  //     ),
  //   );
  // }
}
