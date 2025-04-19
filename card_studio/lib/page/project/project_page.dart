import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/core/label_and_form.dart';
import 'package:homeprint_o_tool/page/project/card_size_dropdown.dart';
import '../../core/project_settings.dart';
import '../../core/form/width_height.dart';
import '../layout/layout_struct.dart';
import '../../core/form/percentage_slider.dart';
import '../../core/form/content_area_calculator.dart';

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
    var percentageSlider = PercentageSlider(
      value: projectSettings.defaultContentExpand,
      onChanged: _updateContentExpand,
    );

    final defaultContentArea = LabelAndForm(
      label: "Default Content Area",
      help:
          "Content Area is a part of card graphics that you want after cutting, expressed in percentage, so it is able to accommodate input graphic of differing sizes in the project at the same time. Outside of Content Area then became bleed for cutting away. At 100%, a rectangle in the shape of Card Size in the above's settings is placed at the center, then enlarged keeping the proportion until one side touches the edge of available card graphic. Each card added to this project starts out with this amount of Content Area, you can input custom percentage per card or reset back to this value. Updating this value later also propagate the change to all cards using the default value.",
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: percentageSlider,
        ),
      ],
    );

    final contentAreaCalculator = ContentAreaCalculator(
      initialContentWidth: projectSettings.cardSize.width,
      initialContentHeight: projectSettings.cardSize.height,
      onCalculated: (calculatedValue) {
        _updateContentExpand(calculatedValue);
      },
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

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          cardSizeForm,
          const SizedBox(height: 24),
          defaultContentArea,
          contentAreaCalculator,
        ],
      ),
    );
  }
}
