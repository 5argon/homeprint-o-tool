class LayoutData {
  SizePhysical paperSize;
  SizePhysical marginSize;
  SizePhysical edgeCutGuideSize;
  ValuePhysical whitePadding;
  ValuePhysical cutGuideLineWidth;

  LayoutData(
    this.paperSize,
    this.marginSize,
    this.edgeCutGuideSize,
    this.whitePadding,
    this.cutGuideLineWidth,
  );
}

class SizePhysical {
  double width;
  double height;

  SizePhysical(this.width, this.height);
  // Size.fromPhysical(double cmWidth, double cmHeight, double ppi)
  //     : width = (cmWidth * ppi / 2.54).round(),
  //       height = (cmHeight * ppi / 2.54).round();
}

class ValuePhysical {
  double value;
  ValuePhysical(this.value);
}

class CardGame {}
