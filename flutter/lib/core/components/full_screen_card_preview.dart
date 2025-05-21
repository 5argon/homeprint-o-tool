import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homeprint_o_tool/core/card_face.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/page/card/single_card_preview.dart';
import 'package:homeprint_o_tool/page/layout/layout_data.dart';

/// A dialog that displays a card in full screen.
/// This component is used to show a larger preview when a user clicks on a card preview.
class FullScreenCardPreview extends StatelessWidget {
  final String basePath;
  final SizePhysical cardSize;
  final double bleedFactor;
  final CardFace? cardFace;
  final ProjectSettings projectSettings;

  const FullScreenCardPreview({
    super.key,
    required this.basePath,
    required this.cardSize,
    required this.bleedFactor,
    required this.cardFace,
    required this.projectSettings,
  });

  /// Shows a full screen dialog with a card preview
  static Future<void> show(
    BuildContext context, {
    required String basePath,
    required SizePhysical cardSize,
    required double bleedFactor,
    required CardFace? cardFace,
    required ProjectSettings projectSettings,
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => FullScreenCardPreview(
        basePath: basePath,
        cardSize: cardSize,
        bleedFactor: bleedFactor,
        cardFace: cardFace,
        projectSettings: projectSettings,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size to make preview as large as possible while maintaining aspect ratio
    final size = MediaQuery.of(context).size;
    final safeAreaInsets = MediaQuery.of(context).padding;
    final availableHeight = size.height -
        safeAreaInsets.top -
        safeAreaInsets.bottom -
        120; // Account for some padding and controls
    final availableWidth =
        size.width - 40; // Account for some horizontal padding

    final cardName = cardFace?.name ?? 'Card Preview';
    final fileName = cardFace?.relativeFilePath.isNotEmpty == true
        ? cardFace!.relativeFilePath.split('/').last
        : 'No Image';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: KeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
          }
        },
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cardName),
                  if (cardFace?.relativeFilePath.isNotEmpty == true)
                    Text(
                      fileName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: availableWidth,
                        maxHeight: availableHeight,
                      ),
                      alignment: Alignment.center,
                      child: cardFace != null
                          ? SingleCardPreview(
                              basePath: basePath,
                              cardSize: cardSize,
                              bleedFactor: bleedFactor,
                              cardFace: cardFace,
                              projectSettings: projectSettings,
                              showBorder: true,
                              disableClick:
                                  true, // Prevent infinite recursion of previews
                            )
                          : const Center(child: Text("No image available")),
                    ),
                    const SizedBox(height: 16),
                    if (cardFace?.relativeFilePath.isNotEmpty == true)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "Path: ${cardFace!.relativeFilePath}",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
