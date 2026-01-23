import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/core/export_storage.dart';
import 'package:homeprint_o_tool/core/json.dart';
import 'package:homeprint_o_tool/core/page_preview/cut_guide_style.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/page/layout/layout_data.dart';

class ExportSettings {
  final String prefix;
  final String template;
  final String frontSuffix;
  final String backSuffix;
  final Rotation frontRotation;
  final Rotation backRotation;
  final bool frontSideOnly;
  final int pixelPerInch;
  final CutGuideStyle cutGuideStyle;

  ExportSettings({
    required this.prefix,
    required this.template,
    required this.frontSuffix,
    required this.backSuffix,
    required this.frontRotation,
    required this.backRotation,
    required this.frontSideOnly,
    required this.pixelPerInch,
    required this.cutGuideStyle,
  });
}

Future<ExportSettings?> openPreExportDialog(BuildContext context,
    LayoutData layoutData, ProjectSettings projectSettings) async {
  // Load saved settings or use defaults
  final savedSettings = await ExportStorage.loadExportSettings() ??
      ExportStorage.getDefaultExportSettings();

  String tempPrefix = savedSettings.prefix;
  String tempTemplate = savedSettings.template;
  String tempFrontSuffix = savedSettings.frontSuffix;
  String tempBackSuffix = savedSettings.backSuffix;
  Rotation tempFrontRotation = savedSettings.frontRotation;
  Rotation tempBackRotation = savedSettings.backRotation;
  bool tempFrontSideOnly = savedSettings.frontSideOnly;
  CutGuideStyle tempCutGuideStyle = savedSettings.cutGuideStyle;
  int tempPixelPerInch = savedSettings.pixelPerInch;

  return await showDialog<ExportSettings>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return PopScope(
            onPopInvokedWithResult: (didPop, result) {
              // Save settings whenever dialog is dismissed (including Escape key)
              if (didPop) {
                final settings = ExportSettings(
                  prefix: tempPrefix,
                  template: tempTemplate,
                  frontSuffix: tempFrontSuffix,
                  backSuffix: tempBackSuffix,
                  frontRotation: tempFrontRotation,
                  backRotation: tempBackRotation,
                  frontSideOnly: tempFrontSideOnly,
                  pixelPerInch: tempPixelPerInch,
                  cutGuideStyle: tempCutGuideStyle,
                );
                ExportStorage.saveExportSettings(settings);
              }
            },
            child: AlertDialog(
              title: Text('Export Settings'),
              content: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CheckboxListTile(
                      title: Text('Front Side Only'),
                      value: tempFrontSideOnly,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        setState(() {
                          tempFrontSideOnly = value ?? false;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Guides on Graphic:',
                            style: TextStyle(fontSize: 14)),
                        SizedBox(width: 12),
                        Expanded(
                          child: SegmentedButton<int>(
                            segments: [
                              ButtonSegment(value: 0, label: Text("None")),
                              ButtonSegment(value: 1, label: Text("Line")),
                              ButtonSegment(value: 2, label: Text("Corners")),
                            ],
                            selected: {tempCutGuideStyle.index},
                            onSelectionChanged: (Set<int> selection) {
                              setState(() {
                                tempCutGuideStyle =
                                    CutGuideStyle.values[selection.first];
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: TextEditingController(text: tempTemplate),
                      decoration: InputDecoration(
                        labelText: "File Name Template",
                        helperText:
                            "Use {prefix}, {page}, {side} as placeholders.",
                      ),
                      onChanged: (value) {
                        tempTemplate = value;
                      },
                    ),
                    TextField(
                      controller: TextEditingController(text: tempPrefix),
                      decoration:
                          InputDecoration(labelText: "File Name Prefix"),
                      onChanged: (value) {
                        tempPrefix = value;
                      },
                    ),
                    TextField(
                      controller: TextEditingController(text: tempFrontSuffix),
                      decoration:
                          InputDecoration(labelText: "Front Side Suffix"),
                      onChanged: (value) {
                        tempFrontSuffix = value;
                      },
                    ),
                    TextField(
                      controller: TextEditingController(text: tempBackSuffix),
                      decoration: InputDecoration(
                        labelText: "Back Side Suffix",
                        enabled: !tempFrontSideOnly,
                      ),
                      onChanged: (value) {
                        tempBackSuffix = value;
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<Rotation>(
                      value: tempFrontRotation,
                      decoration:
                          InputDecoration(labelText: "Front Post-Rotation"),
                      items: [
                        DropdownMenuItem(
                          value: Rotation.none,
                          child: Text("None"),
                        ),
                        DropdownMenuItem(
                          value: Rotation.clockwise90,
                          child: Text("Clockwise 90"),
                        ),
                        DropdownMenuItem(
                          value: Rotation.counterClockwise90,
                          child: Text("Counter-clockwise 90"),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          tempFrontRotation = value;
                        }
                      },
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<Rotation>(
                      value: tempBackRotation,
                      decoration: InputDecoration(
                        labelText: "Back Post-Rotation",
                      ),
                      items: [
                        DropdownMenuItem(
                          value: Rotation.none,
                          child: Text("None"),
                        ),
                        DropdownMenuItem(
                          value: Rotation.clockwise90,
                          child: Text("Clockwise 90"),
                        ),
                        DropdownMenuItem(
                          value: Rotation.counterClockwise90,
                          child: Text("Counter-clockwise 90"),
                        ),
                      ],
                      onChanged: tempFrontSideOnly
                          ? null
                          : (value) {
                              if (value != null) {
                                tempBackRotation = value;
                              }
                            },
                    ),
                    SizedBox(height: 16),
                    Builder(
                      builder: (context) {
                        final controller = TextEditingController(
                            text: tempPixelPerInch.toString());
                        final focusNode = FocusNode();

                        // Calculate pixel dimensions based on paper size and PPI
                        final pixelWidth =
                            layoutData.paperSize.widthInch * tempPixelPerInch;
                        final pixelHeight =
                            layoutData.paperSize.heightInch * tempPixelPerInch;
                        final helperText =
                            "Card size: ${projectSettings.cardSize.width} × ${projectSettings.cardSize.height} ${projectSettings.cardSize.unit == PhysicalSizeType.centimeter ? 'cm' : 'in'}\n"
                            "Paper size: ${layoutData.paperSize.width.toStringAsFixed(1)} × ${layoutData.paperSize.height.toStringAsFixed(1)} ${layoutData.paperSize.unit == PhysicalSizeType.centimeter ? 'cm' : 'in'}\n"
                            "Output size: ${pixelWidth.round()} × ${pixelHeight.round()} px";

                        void updatePPI(String value) {
                          int? parsedValue = int.tryParse(value);
                          if (parsedValue != null && parsedValue > 0) {
                            setState(() {
                              tempPixelPerInch = parsedValue;
                            });
                          }
                        }

                        // Add listener to update on focus loss
                        focusNode.addListener(() {
                          if (!focusNode.hasFocus) {
                            updatePPI(controller.text);
                          }
                        });

                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: "Resolution (PPI)",
                            helperText: helperText,
                            helperMaxLines: 3,
                          ),
                          keyboardType: TextInputType.number,
                          onSubmitted: updatePPI,
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(null); // Cancel
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final settings = ExportSettings(
                      prefix: tempPrefix,
                      template: tempTemplate,
                      frontSuffix: tempFrontSuffix,
                      backSuffix: tempBackSuffix,
                      frontRotation: tempFrontRotation,
                      backRotation: tempBackRotation,
                      frontSideOnly: tempFrontSideOnly,
                      pixelPerInch: tempPixelPerInch,
                      cutGuideStyle: tempCutGuideStyle,
                    );
                    Navigator.of(context).pop(settings); // Confirm
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
