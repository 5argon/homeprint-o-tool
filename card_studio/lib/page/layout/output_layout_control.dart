import 'package:flutter/material.dart';

class OutputLayoutControl extends StatelessWidget {
  const OutputLayoutControl({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Text("Page Size"),
              SizedBox(
                width: 100,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Width",
                    suffixText: "cm",
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Height",
                    suffixText: "cm",
                  ),
                ),
              ),
            ],
          ),
          Divider()
        ],
      ),
    );
  }
}
