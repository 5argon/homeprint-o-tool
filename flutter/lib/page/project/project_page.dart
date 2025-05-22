import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/core/card_face.dart';
import 'package:homeprint_o_tool/core/json.dart'; // For Rotation enum
import 'package:homeprint_o_tool/core/label_and_form.dart';
import 'package:homeprint_o_tool/page/project/card_size_dropdown.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/core/form/width_height.dart';
import 'package:homeprint_o_tool/page/layout/layout_data.dart';
import 'package:homeprint_o_tool/page/card/content_area_editor.dart';

class ProjectPage extends StatelessWidget {
  final ProjectSettings projectSettings;
  final Function(ProjectSettings) onProjectSettingsChanged;
  final String baseDirectory;

  const ProjectPage({
    super.key,
    required this.projectSettings,
    required this.onProjectSettingsChanged,
    required this.baseDirectory,
  });

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

  void _updateRotation(Rotation value) {
    final updatedSettings = ProjectSettings(
      projectSettings.cardSize,
      projectSettings.defaultContentCenterOffset,
      projectSettings.defaultContentExpand,
      value,
    );
    onProjectSettingsChanged(updatedSettings);
  }

  Future<String?> pickExampleGraphic(String basePath) async {
    final typeGroup = XTypeGroup(
      label: 'images',
      extensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
    );
    final file = await openFile(
      acceptedTypeGroups: [typeGroup],
      initialDirectory: basePath,
    );

    if (file != null) {
      // Convert the absolute path to a relative path from the base directory
      String relativePath = p.relative(file.path, from: basePath);
      return relativePath;
    }
    return null;
  }

  String _getRotationDisplayName(Rotation rotation) {
    switch (rotation) {
      case Rotation.none:
        return "None";
      case Rotation.clockwise90:
        return "Clockwise 90°";
      case Rotation.counterClockwise90:
        return "Counter-clockwise 90°";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Display the current content area percentage
    final contentAreaText = Text(
      "${(projectSettings.defaultContentExpand * 100).toStringAsFixed(1)}%",
      style: TextStyle(fontWeight: FontWeight.bold),
    );

    // Use the baseDirectory prop directly instead of ModalRoute
    final basePath = baseDirectory;

    final defaultContentArea = LabelAndForm(
      label: "Default Content Area",
      help:
          "Content Area is a part of card graphics that you want after cutting, expressed in percentage, so it is able to accommodate input graphic of differing sizes in the project at the same time. Outside of Content Area then became bleed for cutting away. At 100%, a rectangle in the shape of Card Size in the above's settings is placed at the center, then enlarged keeping the proportion until one side touches the edge of available card graphic. Each card added to this project starts out with this amount of Content Area, you can input custom percentage per card or reset back to this value. Updating this value later also propagate the change to all cards using the default value.",
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: contentAreaText,
        ),
        SizedBox(width: 16),
        ElevatedButton(
          onPressed: () async {
            // First ask user to pick an example graphic
            final exampleGraphicPath = await pickExampleGraphic(basePath);
            if (exampleGraphicPath != null) {
              // Create a temporary CardFace using the selected graphic
              final tempCardFace =
                  CardFace.withRelativeFilePath(exampleGraphicPath);

              // Show the content area editor with the temporary CardFace
              if (context.mounted) {
                final result = await showDialog<double>(
                  context: context,
                  builder: (context) => ContentAreaEditorDialog(
                    basePath: basePath,
                    cardFace: tempCardFace,
                    cardSize: projectSettings.cardSize,
                    initialContentExpand: projectSettings.defaultContentExpand,
                    projectSettings: projectSettings,
                  ),
                );

                // Update the content expand value if the user returned a value
                if (result != null) {
                  _updateContentExpand(result);
                }
              }
            }
          },
          child: const Text("Setup With Example Graphic"),
        ),
      ],
    );

    final cardSizeForm = LabelAndForm(
        label: "Card Size",
        help:
            "This app can only make an uncut sheet consisting of cards in the same size after cutting, while the input graphic size can be dynamic. (Therefore they can have different amount bleeds that would be cut away.) All other calculations starts from this so it is a very important settings.",
        children: [
          CardSizeDropdown(
              size: projectSettings.cardSize,
              onSizeChanged: (value) {
                _updateCardSize(value.width, value.height, value.unit);
              }),
          const SizedBox(width: 16),
          WidthHeightInput(
            width: projectSettings.cardSize.width,
            height: projectSettings.cardSize.height,
            unit: projectSettings.cardSize.unit,
            onChanged: _updateCardSize,
          ),
        ]);

    final defaultRotation = LabelAndForm(
      label: "Default Rotation",
      help:
          "Default rotation to apply to the input graphics so they match the aspect ratio of Card Size. Each card added to this project starts out with this rotation, you can customize rotation per card or reset back to this value. Updating this value later also propagates the change to all cards using the default value.",
      children: [
        DropdownButton<Rotation>(
          value: projectSettings.defaultRotation,
          items: [
            DropdownMenuItem(
              value: Rotation.none,
              child: Text(_getRotationDisplayName(Rotation.none)),
            ),
            DropdownMenuItem(
              value: Rotation.clockwise90,
              child: Text(_getRotationDisplayName(Rotation.clockwise90)),
            ),
            DropdownMenuItem(
              value: Rotation.counterClockwise90,
              child: Text(_getRotationDisplayName(Rotation.counterClockwise90)),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              _updateRotation(value);
            }
          },
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          cardSizeForm,
          const SizedBox(height: 24),
          defaultContentArea,
          const SizedBox(height: 24),
          defaultRotation,
        ],
      ),
    );
  }
}
