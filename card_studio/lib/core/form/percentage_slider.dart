import 'package:flutter/material.dart';

class PercentageSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const PercentageSlider({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  PercentageSliderState createState() => PercentageSliderState();
}

class PercentageSliderState extends State<PercentageSlider> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: (widget.value * 100).toStringAsFixed(2),
    );
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _commitValue(); // Commit value when focus is lost
      }
    });
  }

  @override
  void didUpdateWidget(covariant PercentageSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != double.tryParse(_controller.text)) {
      _controller.text = (widget.value * 100).toStringAsFixed(2);
    }
  }

  void _commitValue() {
    final newValue = double.tryParse(_controller.text);
    if (newValue != null) {
      final clampedValue = newValue.clamp(0.0, 100.0);
      widget.onChanged(clampedValue / 100.0); // Convert back to 0.0 ~ 1.0 range
      _controller.text = clampedValue.toStringAsFixed(2);
    } else {
      _controller.text = (widget.value * 100).toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: widget.value,
            min: 0.0,
            max: 1.0,
            divisions: 1000,
            label: "${(widget.value * 100).toStringAsFixed(2)} %",
            onChanged: (newValue) {
              widget.onChanged(newValue);
              // _controller.text = (newValue * 100).toStringAsFixed(2);
            },
          ),
        ),
        SizedBox(
          width: 90,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              suffixText: "%",
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            onSubmitted: (_) => _commitValue(),
          ),
        ),
      ],
    );
  }
}
