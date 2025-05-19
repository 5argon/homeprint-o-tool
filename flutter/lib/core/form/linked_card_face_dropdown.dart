import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/core/card_face.dart';
import 'package:path/path.dart' as p;

import 'package:homeprint_o_tool/core/save_file.dart';

class LinkedCardFaceDropdown extends StatelessWidget {
  final LinkedCardFaces linkedCardFaces;
  final CardFace? selectedValue;
  final Function(CardFace?) onChanged;
  final bool? disabled;

  const LinkedCardFaceDropdown({
    super.key,
    required this.linkedCardFaces,
    required this.selectedValue,
    required this.onChanged,
    this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    final dropdownItems = linkedCardFaces.asMap().entries.map((entry) {
      final int index = entry.key + 1; // Start from 1 for display
      final CardFace linkedCardFace = entry.value;
      final String linkedCardFaceName = linkedCardFace.name ?? "";
      final String displayLinkedCardFaceName;
      if (linkedCardFaceName.isNotEmpty) {
        displayLinkedCardFaceName = linkedCardFaceName;
      } else if (linkedCardFace.relativeFilePath.isNotEmpty) {
        displayLinkedCardFaceName = p.basename(linkedCardFace.relativeFilePath);
      } else {
        displayLinkedCardFaceName = "#$index: Unnamed Linked Card Face";
      }
      return DropdownMenuItem<CardFace>(
        value: linkedCardFace,
        child: Text(displayLinkedCardFaceName),
      );
    }).toList();

    return DropdownButton<CardFace>(
      isExpanded: true,
      value: selectedValue,
      hint: const Text("Select Linked Card Face"),
      items: dropdownItems,
      onChanged: disabled == true
          ? null
          : (CardFace? newValue) {
              onChanged(newValue);
            },
    );
  }
}
