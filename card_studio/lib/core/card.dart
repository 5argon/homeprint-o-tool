class CardGroup {
  List<CardEach> cards;
  CardGroup(this.cards);
}

class CardEach {
  CardEachSingle? front;
  CardEachSingle? back;
  CardEach(this.front, this.back);
}

class CardEachSingle {
  /// Use 0,0 for exactly at center.
  XY centerOffset;

  /// Content area's aspect ratio is always the same as project's card size.
  /// Expand 1 meant that the frame is touching the edge of image. Expand until
  /// the first edge touches.
  double expand;
  Rotation rotation;
  PerCardSynthesizedBleed synthesizedBleed;

  /// This card is defined for reuse in the Instance tab if it is not `null`.
  String? instanceName;

  CardEachSingle(this.centerOffset, this.expand, this.rotation,
      this.synthesizedBleed, this.instanceName);
}

enum Rotation {
  none,
  clockwise90,
  counterClockwise90,
}

enum PerCardSynthesizedBleed {
  projectSettings,
  mirror,
  none,
}

class XY {
  double x;
  double y;
  XY(this.x, this.y);
}
