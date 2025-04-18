import 'package:flutter/material.dart';
import '../../core/project_settings.dart';
import '../../core/form/width_height.dart';
import '../layout/layout_struct.dart';

class ProjectPage extends StatelessWidget {
  final ProjectSettings projectSettings;
  final Function(ProjectSettings) onProjectSettingsChanged;

  const ProjectPage({
    Key? key,
    required this.projectSettings,
    required this.onProjectSettingsChanged,
  }) : super(key: key);

  void _updateCardSize(double width, double height, PhysicalSizeType unit) {
    final updatedSettings = ProjectSettings(
      SizePhysical(width, height, unit),
      projectSettings.defaultContentCenterOffset,
      projectSettings.defaultContentExpand,
      projectSettings.defaultRotation,
    );
    onProjectSettingsChanged(updatedSettings);
  }

  void _updateContentExpand(double value) {
    final updatedSettings = ProjectSettings(
      projectSettings.cardSize,
      projectSettings.defaultContentCenterOffset,
      value,
      projectSettings.defaultRotation,
    );
    onProjectSettingsChanged(updatedSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Card Size",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          WidthHeightInput(
            width: projectSettings.cardSize.width,
            height: projectSettings.cardSize.height,
            unit: projectSettings.cardSize.unit,
            onChanged: _updateCardSize,
          ),
          const SizedBox(height: 24),
          const Text(
            "Default Content Area",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Slider(
              value: projectSettings.defaultContentExpand,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              label: projectSettings.defaultContentExpand.toStringAsFixed(2),
              onChanged: _updateContentExpand,
            ),
          ),
        ],
      ),
    );
  }
}
