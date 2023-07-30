class CardGroup {
  List<CardEach> cards;
  CardGroup(this.cards);
}

class CardEach {
  CardEachSingle? front;
  CardEachSingle? back;
  int? frontInstance;
  int? backInstance;
  CardEach(this.front, this.back, this.frontInstance, this.backInstance);
}

class CardEachSingle {
  XY center;
  double expand;
  Rotation rotation;

  CardEachSingle(this.center, this.expand, this.rotation);
}

enum Rotation {
  none,
  clockwise90,
  counterClockwise90,
}

class XY {
  double x;
  double y;
  XY(this.x, this.y);
}
