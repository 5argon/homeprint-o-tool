import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/page/layout/layout_struct.dart';

/// Current size will try to select the right dropdown to show.
/// Or show "custom" if nothing matches.
class CardSizeDropdown extends StatelessWidget {
  final SizePhysical size;
  final Function(SizePhysical) onSizeChanged;
  const CardSizeDropdown({
    super.key,
    required this.size,
    required this.onSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<SizePhysical>> cardSizeDropdownItems = [
      DropdownMenuItem(
        value: SizePhysical(6.3, 8.8, PhysicalSizeType.centimeter),
        child: Text("Standard (Vertical)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(8.8, 6.3, PhysicalSizeType.centimeter),
        child: Text("Standard (Horizontal)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(6.15, 8.8, PhysicalSizeType.centimeter),
        child: Text("AHLCG (Vertical)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(8.8, 6.15, PhysicalSizeType.centimeter),
        child: Text("AHLCG (Horizontal)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(4.1, 6.3, PhysicalSizeType.centimeter),
        child: Text("Mini Card (Vertical)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(6.3, 4.1, PhysicalSizeType.centimeter),
        child: Text("Mini Card (Horizontal)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(6.7, 9.3, PhysicalSizeType.centimeter),
        child: Text("Outer Sleeve Fit (Vertical)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(9.3, 6.7, PhysicalSizeType.centimeter),
        child: Text("Outer Sleeve Fit (Horizontal)"),
      ),
    ];
    final findMatchingSize = cardSizeDropdownItems.firstWhere(
      (element) => element.value == size,
      orElse: () {
        return DropdownMenuItem(
          value: null,
          child: Text("Custom"),
        );
      },
    );
    return DropdownButton(
      value: findMatchingSize.value,
      items: cardSizeDropdownItems,
      hint: Text("Custom"),
      onChanged: (value) {
        if (value == null) return;
        onSizeChanged(value);
      },
    );
  }
}
