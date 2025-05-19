import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/core/card_face.dart';
import 'package:homeprint_o_tool/page/layout/layout_data.dart';

import '../../core/json.dart';
import '../../core/form/percentage_slider.dart';
import 'single_card_preview.dart';

class ContentAreaEditorDialog extends StatefulWidget {
  final String basePath;
  final CardFace cardFace;
  final SizePhysical cardSize;
  final double initialContentExpand;

  const ContentAreaEditorDialog({
    super.key,
    required this.basePath,
    required this.cardFace,
    required this.cardSize,
    required this.initialContentExpand,
  });

  @override
  ContentAreaEditorDialogState createState() => ContentAreaEditorDialogState();
}

class ContentAreaEditorDialogState extends State<ContentAreaEditorDialog> {
  late double contentExpand;
  late TextEditingController contentWidthController;
  late TextEditingController contentHeightController;
  double? imageWidth;
  double? imageHeight;
  bool _updatingFields = false; // Flag to prevent recursive updates

  @override
  void initState() {
    super.initState();
    contentExpand = widget.initialContentExpand;
    contentWidthController = TextEditingController();
    contentHeightController = TextEditingController();

    // We'll update these controllers when we get the image dimensions
    _loadImageDimensions();
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
    if (imageWidth == null || imageHeight == null) return;

    _updatingFields = true;
    try {
      // Calculate content width and height based on the expansion percentage
      double cardWidth = widget.cardSize.widthCm;
      double cardHeight = widget.cardSize.heightCm;

      // Check if card is rotated
      if (widget.cardFace.rotation != Rotation.none) {
        double temp = cardWidth;
        cardWidth = cardHeight;
        cardHeight = temp;
      }

      // Calculate direct content dimensions based on the expansion percentage
      double contentWidth = imageWidth! * contentExpand;
      double contentHeight = imageHeight! * contentExpand;

      // Update text controllers with the calculated dimensions
      contentWidthController.text = contentWidth.toStringAsFixed(1);
      contentHeightController.text = contentHeight.toStringAsFixed(1);
    } finally {
      _updatingFields = false;
    }
  }

  void _updateExpandFromContentDimensions() {
    if (imageWidth == null || imageHeight == null) return;

    double inputContentWidth =
        double.tryParse(contentWidthController.text) ?? 0;
    double inputContentHeight =
        double.tryParse(contentHeightController.text) ?? 0;

    if (inputContentWidth <= 0 || inputContentHeight <= 0) return;

    double cardWidth = widget.cardSize.widthCm;
    double cardHeight = widget.cardSize.heightCm;

    // Check if card is rotated
    if (widget.cardFace.rotation != Rotation.none) {
      double temp = cardWidth;
      cardWidth = cardHeight;
      cardHeight = temp;
    }

    // Calculate expansion percentages for both dimensions
    double widthExpand = inputContentWidth / imageWidth!;
    double heightExpand = inputContentHeight / imageHeight!;

    // Use the larger ratio as it will constrain the content area
    double calculatedExpand =
        (widthExpand > heightExpand) ? widthExpand : heightExpand;

    // Clamp and update
    calculatedExpand = calculatedExpand.clamp(0.0, 1.0);
    setState(() {
      contentExpand = calculatedExpand;
    });
  }

  void _updateWidthBasedOnHeight() {
    if (imageWidth == null || imageHeight == null || _updatingFields) return;

    _updatingFields = true;
    try {
      double inputContentHeight =
          double.tryParse(contentHeightController.text) ?? 0;
      if (inputContentHeight <= 0) return;

      double cardWidth = widget.cardSize.widthCm;
      double cardHeight = widget.cardSize.heightCm;

      // Check if card is rotated
      if (widget.cardFace.rotation != Rotation.none) {
        double temp = cardWidth;
        cardWidth = cardHeight;
        cardHeight = temp;
      }

      // Calculate width maintaining aspect ratio
      double aspectRatio = cardWidth / cardHeight;
      double newWidth = inputContentHeight * aspectRatio;

      contentWidthController.text = newWidth.toStringAsFixed(1);

      // Update the expansion percentage
      _updateExpandFromContentDimensions();
    } finally {
      _updatingFields = false;
    }
  }

  void _updateHeightBasedOnWidth() {
    if (imageWidth == null || imageHeight == null || _updatingFields) return;

    _updatingFields = true;
    try {
      double inputContentWidth =
          double.tryParse(contentWidthController.text) ?? 0;
      if (inputContentWidth <= 0) return;

      double cardWidth = widget.cardSize.widthCm;
      double cardHeight = widget.cardSize.heightCm;

      // Check if card is rotated
      if (widget.cardFace.rotation != Rotation.none) {
        double temp = cardWidth;
        cardWidth = cardHeight;
        cardHeight = temp;
      }

      // Calculate height maintaining aspect ratio
      double aspectRatio = cardHeight / cardWidth;
      double newHeight = inputContentWidth * aspectRatio;

      contentHeightController.text = newHeight.toStringAsFixed(1);

      // Update the expansion percentage
      _updateExpandFromContentDimensions();
    } finally {
      _updatingFields = false;
    }
  }

  @override
  void dispose() {
    contentWidthController.dispose();
    contentHeightController.dispose();
    super.dispose();
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
          // Removed Apply button from here
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
                          child: TextField(
                            controller: contentWidthController,
                            decoration: InputDecoration(
                              labelText: 'Content Width',
                              border: OutlineInputBorder(),
                              suffixText: 'px',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (_) {
                              _updateExpandFromContentDimensions();
                              _updateHeightBasedOnWidth();
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: contentHeightController,
                            decoration: InputDecoration(
                              labelText: 'Content Height',
                              border: OutlineInputBorder(),
                              suffixText: 'px',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (_) {
                              _updateExpandFromContentDimensions();
                              _updateWidthBasedOnHeight();
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
