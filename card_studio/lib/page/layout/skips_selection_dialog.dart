// filepath: /Users/5argon/Desktop/CardStudio/card_studio/lib/page/layout/skips_selection_dialog.dart
import 'package:flutter/material.dart';

/// A dialog that displays a grid of checkboxes representing card positions on a page,
/// allowing users to select which positions should be skipped during printing.
class SkipsSelectionDialog extends StatefulWidget {
  /// Number of rows in the card layout
  final int rows;

  /// Number of columns in the card layout
  final int columns;

  /// List of currently selected skips (0-based indices)
  final List<int> currentSkips;

  /// Callback when the skips selection changes
  final Function(List<int>) onSkipsChanged;

  const SkipsSelectionDialog({
    super.key,
    required this.rows,
    required this.columns,
    required this.currentSkips,
    required this.onSkipsChanged,
  });

  @override
  State<SkipsSelectionDialog> createState() => _SkipsSelectionDialogState();
}

class _SkipsSelectionDialogState extends State<SkipsSelectionDialog> {
  late List<bool> _selectedPositions;
  late int _totalCards;

  @override
  void initState() {
    super.initState();
    _totalCards = widget.rows * widget.columns;

    // Initialize the selected positions based on current skips
    _selectedPositions = List.generate(_totalCards, (index) => false);
    for (final skipIndex in widget.currentSkips) {
      if (skipIndex >= 0 && skipIndex < _totalCards) {
        _selectedPositions[skipIndex] = true;
      }
    }
  }

  // Convert selected positions to skip indices
  List<int> _getSelectedIndices() {
    final List<int> indices = [];
    for (int i = 0; i < _selectedPositions.length; i++) {
      if (_selectedPositions[i]) {
        indices.add(i);
      }
    }
    return indices;
  }

  // Calculate the display index (1-based) from the 0-based index
  int _getDisplayIndex(int index) {
    return index + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Card Positions to Skip',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Picked cards are always laid out left-to-right, top-to-bottom.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Grid of checkboxes
                      for (int row = 0; row < widget.rows; row++) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int col = 0; col < widget.columns; col++) ...[
                              _buildCardCheckbox(row, col),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.onSkipsChanged(_getSelectedIndices());
                      Navigator.of(context).pop();
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Create a checkbox widget for a specific card position
  Widget _buildCardCheckbox(int row, int col) {
    final index = row * widget.columns + col;
    final displayIndex = _getDisplayIndex(index);

    return SizedBox(
      width: 60,
      height: 60,
      child: Card(
        elevation: 2,
        color: _selectedPositions[index]
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surface,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedPositions[index] = !_selectedPositions[index];
            });
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                displayIndex.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _selectedPositions[index]
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Checkbox(
                value: _selectedPositions[index],
                onChanged: (value) {
                  setState(() {
                    _selectedPositions[index] = value ?? false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
