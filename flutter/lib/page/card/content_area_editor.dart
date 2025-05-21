import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/core/card_face.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/page/layout/layout_data.dart';
import 'package:homeprint_o_tool/core/form/percentage_slider.dart';
import 'package:homeprint_o_tool/page/card/single_card_preview.dart';
import 'package:homeprint_o_tool/core/json.dart'; // For Rotation enum

class ContentAreaEditorDialog extends StatefulWidget {
  final String basePath;
  final CardFace cardFace;
  final SizePhysical cardSize;
  final double initialContentExpand;
  final ProjectSettings projectSettings;

  const ContentAreaEditorDialog({
    super.key,
    required this.basePath,
    required this.cardFace,
    required this.cardSize,
    required this.initialContentExpand,
    required this.projectSettings,
  });

  @override
  ContentAreaEditorDialogState createState() => ContentAreaEditorDialogState();
}

class ContentAreaEditorDialogState extends State<ContentAreaEditorDialog> {
  late double contentExpand;
  late TextEditingController contentWidthController;
  late TextEditingController contentHeightController;
  late FocusNode contentWidthFocusNode;
  late FocusNode contentHeightFocusNode;
  double? imageWidth;
  double? imageHeight;
  bool _updatingFields = false; // Flag to prevent recursive updates

  @override
  void initState() {
    super.initState();
    contentExpand = widget.initialContentExpand;
    contentWidthController = TextEditingController();
    contentHeightController = TextEditingController();
    contentWidthFocusNode = FocusNode();
    contentHeightFocusNode = FocusNode();

    // Add focus listeners to validate on defocus
    contentWidthFocusNode.addListener(() {
      if (!contentWidthFocusNode.hasFocus) {
        _validateAndUpdateFromWidth();
      }
    });

    contentHeightFocusNode.addListener(() {
      if (!contentHeightFocusNode.hasFocus) {
        _validateAndUpdateFromHeight();
      }
    });

    // Load image dimensions when initialized
    _loadImageDimensions();
  }

  @override
  void dispose() {
    contentWidthController.dispose();
    contentHeightController.dispose();
    contentWidthFocusNode.dispose();
    contentHeightFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadImageDimensions() async {
    try {
      // This will be updated via the SingleCardPreview callback
      // when the image descriptor is loaded
    } catch (e) {
      print("Error loading image dimensions: $e");
    }
  }

  void _updateContentDimensions(double width, double height) {
    // Called when image dimensions are available from SingleCardPreview
    setState(() {
      imageWidth = width;
      imageHeight = height;
      _updateContentFieldsFromExpand();
    });
  }

  void _updateContentFieldsFromExpand() {
    final imageWidth = this.imageWidth;
    final imageHeight = this.imageHeight;
    if (imageWidth == null || imageHeight == null) return;

    _updatingFields = true;
    try {
      double cardWidth = widget.cardSize.widthCm;
      double cardHeight = widget.cardSize.heightCm;

      if (widget.cardFace.rotation != Rotation.none) {
        double temp = cardWidth;
        cardWidth = cardHeight;
        cardHeight = temp;
      }

      double contentWidth;
      double contentHeight;
      final widthTouchingFirstIfExpanded =
          (cardWidth / cardHeight) > (imageWidth / imageHeight);
      if (widthTouchingFirstIfExpanded) {
        contentWidth = imageWidth * contentExpand;
        contentHeight = contentWidth * (cardHeight / cardWidth);
      } else {
        contentHeight = imageHeight * contentExpand;
        contentWidth = contentHeight * (cardWidth / cardHeight);
      }

      // Update text controllers with the calculated dimensions
      contentWidthController.text = contentWidth.toStringAsFixed(1);
      contentHeightController.text = contentHeight.toStringAsFixed(1);
    } finally {
      _updatingFields = false;
    }
  }

  void _validateAndUpdateFromWidth() {
    if (_updatingFields || imageWidth == null || imageHeight == null) return;

    double inputWidth = double.tryParse(contentWidthController.text) ?? 0.0;
    if (inputWidth <= 0) return;

    _updatingFields = true;
    try {
      double cardWidth = widget.cardSize.widthCm;
      double cardHeight = widget.cardSize.heightCm;

      if (widget.cardFace.rotation != Rotation.none) {
        double temp = cardWidth;
        cardWidth = cardHeight;
        cardHeight = temp;
      }

      // Calculate max width at 100% expand
      final widthTouchingFirstIfExpanded =
          (cardWidth / cardHeight) > (imageWidth! / imageHeight!);

      double maxWidth;
      if (widthTouchingFirstIfExpanded) {
        maxWidth = imageWidth!;
      } else {
        double maxHeight = imageHeight!;
        maxWidth = maxHeight * (cardWidth / cardHeight);
      }

      // Clamp input width to max width
      inputWidth = inputWidth.clamp(0.0, maxWidth);
      contentWidthController.text = inputWidth.toStringAsFixed(1);

      // Calculate height maintaining aspect ratio
      double aspectRatio = cardHeight / cardWidth;
      double newHeight = inputWidth * aspectRatio;
      contentHeightController.text = newHeight.toStringAsFixed(1);

      // Update expand percentage
      double widthExpand = inputWidth / imageWidth!;
      double heightExpand = newHeight / imageHeight!;
      double calculatedExpand =
          widthTouchingFirstIfExpanded ? widthExpand : heightExpand;
      calculatedExpand = calculatedExpand.clamp(0.0, 1.0);

      setState(() {
        contentExpand = calculatedExpand;
      });
    } finally {
      _updatingFields = false;
    }
  }

  void _validateAndUpdateFromHeight() {
    if (_updatingFields || imageWidth == null || imageHeight == null) return;

    double inputHeight = double.tryParse(contentHeightController.text) ?? 0.0;
    if (inputHeight <= 0) return;

    _updatingFields = true;
    try {
      double cardWidth = widget.cardSize.widthCm;
      double cardHeight = widget.cardSize.heightCm;

      if (widget.cardFace.rotation != Rotation.none) {
        double temp = cardWidth;
        cardWidth = cardHeight;
        cardHeight = temp;
      }

      // Calculate max height at 100% expand
      final widthTouchingFirstIfExpanded =
          (cardWidth / cardHeight) > (imageWidth! / imageHeight!);

      double maxHeight;
      if (widthTouchingFirstIfExpanded) {
        double maxWidth = imageWidth!;
        maxHeight = maxWidth * (cardHeight / cardWidth);
      } else {
        maxHeight = imageHeight!;
      }

      // Clamp input height to max height
      inputHeight = inputHeight.clamp(0.0, maxHeight);
      contentHeightController.text = inputHeight.toStringAsFixed(1);

      // Calculate width maintaining aspect ratio
      double aspectRatio = cardWidth / cardHeight;
      double newWidth = inputHeight * aspectRatio;
      contentWidthController.text = newWidth.toStringAsFixed(1);

      // Update expand percentage
      double widthExpand = newWidth / imageWidth!;
      double heightExpand = inputHeight / imageHeight!;
      double calculatedExpand =
          widthTouchingFirstIfExpanded ? widthExpand : heightExpand;
      calculatedExpand = calculatedExpand.clamp(0.0, 1.0);

      setState(() {
        contentExpand = calculatedExpand;
      });
    } finally {
      _updatingFields = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Content Area Editor'),
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: SizedBox(
                        height: 400, // Larger preview
                        child: SingleCardPreview(
                          bleedFactor: contentExpand,
                          cardSize: widget.cardSize,
                          basePath: widget.basePath,
                          cardFace: widget.cardFace,
                          projectSettings: widget.projectSettings,
                          onImageDescriptorLoaded: (width, height) {
                            _updateContentDimensions(width, height);
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Content Area Percentage',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8),
                    PercentageSlider(
                      value: contentExpand,
                      onChanged: (value) {
                        setState(() {
                          contentExpand = value;
                          _updateContentFieldsFromExpand();
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Content Dimensions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: contentWidthController,
                            focusNode: contentWidthFocusNode,
                            decoration: InputDecoration(
                              labelText: 'Content Width',
                              border: OutlineInputBorder(),
                              suffixText: 'px',
                            ),
                            keyboardType: TextInputType.number,
                            onFieldSubmitted: (_) =>
                                _validateAndUpdateFromWidth(),
                            onEditingComplete: () {
                              _validateAndUpdateFromWidth();
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: contentHeightController,
                            focusNode: contentHeightFocusNode,
                            decoration: InputDecoration(
                              labelText: 'Content Height',
                              border: OutlineInputBorder(),
                              suffixText: 'px',
                            ),
                            keyboardType: TextInputType.number,
                            onFieldSubmitted: (_) =>
                                _validateAndUpdateFromHeight(),
                            onEditingComplete: () {
                              _validateAndUpdateFromHeight();
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        ),
                      ],
                    ),
                    if (imageWidth != null && imageHeight != null) ...[
                      SizedBox(height: 16),
                      Text(
                        'Image Dimensions: ${imageWidth!.toStringAsFixed(0)} × ${imageHeight!.toStringAsFixed(0)} px',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                    // Add extra padding at the bottom for the fixed Apply button
                    SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            // Add fixed Apply button at the bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(200, 48),
                  ),
                  onPressed: () {
                    // Make sure to apply the contentExpand value
                    Navigator.of(context).pop(contentExpand);
                  },
                  child: Text('Apply'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
