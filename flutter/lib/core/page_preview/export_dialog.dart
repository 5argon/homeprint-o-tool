import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/core/export_storage.dart';
import 'package:homeprint_o_tool/core/form/help_button.dart';
import 'package:homeprint_o_tool/core/json.dart';
import 'package:homeprint_o_tool/core/page_preview/cut_guide_style.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/page/layout/layout_data.dart';

enum ExportAction {
  /// Export raster PNG sheets (normal export).
  exportPng,

  /// Export a single SVG cut-line file.
  exportCutSvg,
}

class ExportSettings {
  final String prefix;
  final String template;
  final String frontSuffix;
  final String backSuffix;
  final Rotation frontRotation;
  final Rotation backRotation;
  final bool frontSideOnly;
  final bool backSideFirst;
  final int pixelPerInch;
  final CutGuideStyle cutGuideStyle;

  /// Corner radius for the cut SVG export, in millimetres.
  final double cutCornerRadiusMm;

  /// Which action triggered the dialog to close.
  final ExportAction action;

  ExportSettings({
    required this.prefix,
    required this.template,
    required this.frontSuffix,
    required this.backSuffix,
    required this.frontRotation,
    required this.backRotation,
    required this.frontSideOnly,
    required this.backSideFirst,
    required this.pixelPerInch,
    required this.cutGuideStyle,
    required this.cutCornerRadiusMm,
    this.action = ExportAction.exportPng,
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
  bool tempBackSideFirst = savedSettings.backSideFirst;
  CutGuideStyle tempCutGuideStyle = savedSettings.cutGuideStyle;
  int tempPixelPerInch = savedSettings.pixelPerInch;
  double tempCutCornerRadiusMm = savedSettings.cutCornerRadiusMm;

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
                  backSideFirst: tempBackSideFirst,
                  pixelPerInch: tempPixelPerInch,
                  cutGuideStyle: tempCutGuideStyle,
                  cutCornerRadiusMm: tempCutCornerRadiusMm,
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
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
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
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text('Back Side First'),
                                  value: tempBackSideFirst,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                  onChanged: tempFrontSideOnly
                                      ? null
                                      : (value) {
                                          setState(() {
                                            tempBackSideFirst = value ?? false;
                                          });
                                        },
                                ),
                              ),
                              HelpButton(
                                title: 'Back Side First',
                                paragraphs: [
                                  "When cutting duplex sheet, you need to decide which side you are cutting and hope for the best that the other side doesn't have too much offset. The side you cut will have perfect alignment to the cut lines.",
                                  "In most card games with the same card backs intended to be randomly shuffled in a deck, cutting from the back side is better to ensure card backs looks exactly the same. Especially when the graphic is symmetric, it will be very obvious if it is even a little bit off.",
                                  "This option puts the graphic which would have been the card's back on the Front Side of the exported duplex pair instead. If you are having a printing house cut it for you and they always cut from the front, you will not need additional explanation to them if you had already swapped the backside to be the front.",
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller:
                                TextEditingController(text: tempFrontSuffix),
                            decoration:
                                InputDecoration(labelText: "Front Side Suffix"),
                            onChanged: (value) {
                              tempFrontSuffix = value;
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller:
                                TextEditingController(text: tempBackSuffix),
                            enabled: !tempFrontSideOnly,
                            decoration: InputDecoration(
                              labelText: "Back Side Suffix",
                            ),
                            onChanged: (value) {
                              tempBackSuffix = value;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<Rotation>(
                            value: tempFrontRotation,
                            decoration: InputDecoration(
                                labelText: "Front Post-Rotation"),
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
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<Rotation>(
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
                        ),
                      ],
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
                    SizedBox(height: 16),
                    Divider(),
                    SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final controller = TextEditingController(
                            text: tempCutCornerRadiusMm.toString());
                        final focusNode = FocusNode();

                        void updateRadius(String value) {
                          double? parsed = double.tryParse(value);
                          if (parsed != null && parsed >= 0) {
                            setState(() {
                              tempCutCornerRadiusMm = parsed;
                            });
                          }
                        }

                        focusNode.addListener(() {
                          if (!focusNode.hasFocus) {
                            updateRadius(controller.text);
                          }
                        });

                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: 'Cut SVG Corner Radius (mm)',
                            helperText:
                                'Rounded corner radius for cut lines. Used when exporting cut SVG.',
                          ),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          onSubmitted: updateRadius,
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
                      backSideFirst: tempBackSideFirst,
                      pixelPerInch: tempPixelPerInch,
                      cutGuideStyle: tempCutGuideStyle,
                      cutCornerRadiusMm: tempCutCornerRadiusMm,
                      action: ExportAction.exportCutSvg,
                    );
                    Navigator.of(context).pop(settings);
                  },
                  child: Text('Export Cut SVG'),
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
                      backSideFirst: tempBackSideFirst,
                      pixelPerInch: tempPixelPerInch,
                      cutGuideStyle: tempCutGuideStyle,
                      cutCornerRadiusMm: tempCutCornerRadiusMm,
                      action: ExportAction.exportPng,
                    );
                    Navigator.of(context).pop(settings); // Confirm
                  },
                  child: Text('Export PNG'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
