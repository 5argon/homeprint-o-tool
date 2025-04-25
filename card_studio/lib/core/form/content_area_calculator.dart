import 'package:flutter/material.dart';

class ContentAreaCalculator extends StatelessWidget {
  final double initialContentWidth;
  final double initialContentHeight;
  final ValueChanged<double> onCalculated;

  const ContentAreaCalculator({
    Key? key,
    required this.initialContentWidth,
    required this.initialContentHeight,
    required this.onCalculated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final result = await showDialog<double>(
          context: context,
          builder: (BuildContext context) {
            double graphicWidth = 0.0;
            double graphicHeight = 0.0;
            double contentWidth = initialContentWidth;
            double contentHeight = initialContentHeight;
            double calculatedPercentage = 0.0;

            final contentWidthController =
                TextEditingController(text: contentWidth.toStringAsFixed(2));
            final contentHeightController =
                TextEditingController(text: contentHeight.toStringAsFixed(2));

            void calculatePercentage() {
              if (graphicWidth > 0 &&
                  graphicHeight > 0 &&
                  contentWidth > 0 &&
                  contentHeight > 0) {
                final widthRatio = contentWidth / graphicWidth;
                final heightRatio = contentHeight / graphicHeight;
                calculatedPercentage =
                    (widthRatio > heightRatio ? widthRatio : heightRatio);
              } else {
                calculatedPercentage = 0.0;
              }
            }

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                  title: const Text("Calculate Content Area Percentage"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "You can type in values in any unit (pixels, cm, inch, etc.) as long as they are the same.",
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: "Graphic Width"),
                        onChanged: (value) {
                          graphicWidth = double.tryParse(value) ?? 0.0;
                          setState(() => calculatePercentage());
                        },
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: "Graphic Height"),
                        onChanged: (value) {
                          graphicHeight = double.tryParse(value) ?? 0.0;
                          setState(() => calculatePercentage());
                        },
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: "Content Width"),
                        controller: contentWidthController,
                        onChanged: (value) {
                          contentWidth = double.tryParse(value) ?? 0.0;
                          setState(() => calculatePercentage());
                        },
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: "Content Height"),
                        controller: contentHeightController,
                        onChanged: (value) {
                          contentHeight = double.tryParse(value) ?? 0.0;
                          setState(() => calculatePercentage());
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Content Area: ${(calculatedPercentage * 100).toStringAsFixed(2)} %",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(null), // Cancel
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(calculatedPercentage), // OK
                      child: const Text("Apply"),
                    ),
                  ],
                );
              },
            );
          },
        );

        if (result != null) {
          onCalculated(result); // Pass the calculated value
        }
      },
      child: const Text("Calculate From Example"),
    );
  }
}
