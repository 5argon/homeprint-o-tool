import 'package:flutter/material.dart';

class LoadedProjectDisplay extends StatelessWidget {
  final String? loadedProjectFileName;
  final bool hasChanges;

  const LoadedProjectDisplay({
    super.key,
    required this.loadedProjectFileName,
    required this.hasChanges,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        loadedProjectFileName ?? "(No Loaded Project)",
        style: textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),
    );
  }
}
