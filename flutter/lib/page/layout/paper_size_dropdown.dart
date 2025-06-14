import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/page/layout/layout_data.dart';

/// Current size will try to select the right dropdown to show.
/// Or show "custom" if nothing matches.
class PaperSizeDropdown extends StatelessWidget {
  final SizePhysical size;
  final Function(SizePhysical) onSizeChanged;
  const PaperSizeDropdown({
    super.key,
    required this.size,
    required this.onSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<SizePhysical>> paperSizeDropdownItems = [
      DropdownMenuItem(
        value: SizePhysical(42, 29.7, PhysicalSizeType.centimeter),
        child: Text("A3 (Vertical)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(29.7, 42, PhysicalSizeType.centimeter),
        child: Text("A3 (Horizontal)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(21, 29.7, PhysicalSizeType.centimeter),
        child: Text("A4 (Vertical)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(29.7, 21, PhysicalSizeType.centimeter),
        child: Text("A4 (Horizontal)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(21, 14.8, PhysicalSizeType.centimeter),
        child: Text("A5 (Vertical)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(14.8, 21, PhysicalSizeType.centimeter),
        child: Text("A5 (Horizontal)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(13, 19, PhysicalSizeType.inch),
        child: Text("Super-B (Vertical)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(19, 13, PhysicalSizeType.inch),
        child: Text("Super-B (Horizontal)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(8.5, 11, PhysicalSizeType.inch),
        child: Text("Letter (Vertical)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(11, 8.5, PhysicalSizeType.inch),
        child: Text("Letter (Horizontal)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(8.5, 14, PhysicalSizeType.inch),
        child: Text("Legal (Vertical)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(14, 8.5, PhysicalSizeType.inch),
        child: Text("Legal (Horizontal)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(11, 17, PhysicalSizeType.inch),
        child: Text("Tabloid/Ledger (Vertical)"),
      ),
      DropdownMenuItem(
        value: SizePhysical(17, 11, PhysicalSizeType.inch),
        child: Text("Tabloid/Ledger (Horizontal)"),
      ),
    ];
    final findMatchingSize = paperSizeDropdownItems.firstWhere(
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
      items: paperSizeDropdownItems,
      hint: Text("Custom"),
      onChanged: (value) {
        if (value == null) return;
        onSizeChanged(value);
      },
    );
  }
}
