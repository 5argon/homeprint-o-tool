import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/core/card_face.dart';
import 'package:path/path.dart' as p;
import 'package:homeprint_o_tool/core/form/linked_card_face_dropdown.dart';
import 'package:homeprint_o_tool/core/project_settings.dart';
import 'package:homeprint_o_tool/page/card/single_card_preview.dart';
import 'package:homeprint_o_tool/page/card/content_area_editor.dart';
import 'package:homeprint_o_tool/core/json.dart'; // For Rotation enum

import 'package:homeprint_o_tool/core/save_file.dart';

class EditCardFaceDialog extends StatefulWidget {
  final String basePath;
  final LinkedCardFaces linkedCardFaces;
  final ProjectSettings projectSettings;

  /// If using Linked Card Face, return the instance defined in the list.
  /// If using File, create a new instance based on the selected file.
  final Function(CardFace? card) onCardFaceChange;

  final CardFace? initialCard;
  final bool forLinkedCardFaceTab;

  const EditCardFaceDialog({
    super.key,
    required this.basePath,
    required this.linkedCardFaces,
    required this.onCardFaceChange,
    required this.forLinkedCardFaceTab,
    required this.projectSettings,
    this.initialCard, // Optional initial value
  });

  @override
  EditCardFaceDialogState createState() => EditCardFaceDialogState();
}

class EditCardFaceDialogState extends State<EditCardFaceDialog>
    with SingleTickerProviderStateMixin {
  CardFace? selectedCardFace;
  late TabController _tabController;
  String? initialFilePath;
  String? tempFilePath; // Temporary file path for the File tab
  late TextEditingController
      filePathController; // Controller for the text field

  // Content area controls
  bool useDefaultContentExpand = true;
  double customContentExpand = 1.0;

  // Rotation controls
  bool useDefaultRotation = true;
  Rotation customRotation = Rotation.none;

  @override
  void initState() {
    super.initState();
    // Determine initial tab and values
    if (widget.forLinkedCardFaceTab) {
      _tabController = TabController(length: 1, vsync: this, initialIndex: 0);
      // If we have an initial card and we're in the Linked Card Face tab,
      // ensure we set the tempFilePath if the card has a relative file path
      if (widget.initialCard != null &&
          widget.initialCard!.relativeFilePath.isNotEmpty) {
        initialFilePath = widget.initialCard!.relativeFilePath;
        tempFilePath = initialFilePath;

        // Initialize content area settings from initial card
        useDefaultContentExpand = widget.initialCard!.useDefaultContentExpand;
        customContentExpand = widget.initialCard!.contentExpand;

        // Initialize rotation settings from initial card
        useDefaultRotation = widget.initialCard!.useDefaultRotation;
        customRotation = widget.initialCard!.rotation;
      }
    } else if (widget.initialCard != null) {
      if (widget.initialCard!.isLinkedCardFace) {
        // Start with Linked Card Face tab selected
        _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
        selectedCardFace = widget.initialCard;
        tempFilePath = null; // Ensure File tab shows "No file selected"
      } else if (widget.initialCard!.relativeFilePath.isNotEmpty) {
        _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
        initialFilePath = widget.initialCard!.relativeFilePath;
        tempFilePath = initialFilePath;

        // Initialize content area settings from initial card
        useDefaultContentExpand = widget.initialCard!.useDefaultContentExpand;
        customContentExpand = widget.initialCard!.contentExpand;

        // Initialize rotation settings from initial card
        useDefaultRotation = widget.initialCard!.useDefaultRotation;
        customRotation = widget.initialCard!.rotation;
      } else {
        _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
      }
    } else {
      _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    }

    // Initialize the text controller with the initial file path
    filePathController = TextEditingController(text: tempFilePath);
  }

  @override
  void dispose() {
    filePathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var relativeFilePathTab = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Relative File Path",
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          Text(
            tempFilePath ?? "(No file selected)",
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              final path = await pickRelativePath(widget.basePath);
              if (path != null) {
                setState(() {
                  tempFilePath = path;
                });
              }
            },
            child: Text("Browse File"),
          ),

          // Show card preview and content area controls side by side if a file is selected
          if (tempFilePath != null) ...[
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side: Card preview
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 300,
                    child: SingleCardPreview(
                      bleedFactor: useDefaultContentExpand
                          ? widget.projectSettings.defaultContentExpand
                          : customContentExpand,
                      cardSize: widget.projectSettings.cardSize,
                      basePath: widget.basePath,
                      cardFace: CardFace.withRelativeFilePath(tempFilePath!),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // Right side: Content area settings
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Content Area Settings
                      Text(
                        "Content Area Settings",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      RadioListTile<bool>(
                        dense: true,
                        title: Text(
                            "Use Default Content Area (${(widget.projectSettings.defaultContentExpand * 100).toStringAsFixed(1)}%)"),
                        value: true,
                        groupValue: useDefaultContentExpand,
                        onChanged: (value) {
                          setState(() {
                            useDefaultContentExpand = value!;
                          });
                        },
                      ),
                      RadioListTile<bool>(
                        dense: true,
                        title: Text("Use Custom Content Area"),
                        value: false,
                        groupValue: useDefaultContentExpand,
                        onChanged: (value) {
                          setState(() {
                            useDefaultContentExpand = value!;
                          });
                        },
                      ),
                      if (!useDefaultContentExpand) ...[
                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Row(
                            children: [
                              Text(
                                  "${(customContentExpand * 100).toStringAsFixed(1)}%"),
                              SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () async {
                                  // Create a temporary CardFace to pass to the editor
                                  final tempCard =
                                      CardFace.withRelativeFilePath(
                                          tempFilePath!);

                                  final result = await showDialog<double>(
                                    context: context,
                                    builder: (context) =>
                                        ContentAreaEditorDialog(
                                      basePath: widget.basePath,
                                      cardFace: tempCard,
                                      cardSize: widget.projectSettings.cardSize,
                                      initialContentExpand: customContentExpand,
                                    ),
                                  );

                                  if (result != null) {
                                    setState(() {
                                      customContentExpand = result;
                                    });
                                  }
                                },
                                child: Text("Editor"),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Rotation Settings
                      SizedBox(height: 16),
                      Text(
                        "Rotation Settings",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      RadioListTile<bool>(
                        dense: true,
                        title: Text(
                            "Use Default Rotation (${widget.projectSettings.defaultRotation.name})"),
                        value: true,
                        groupValue: useDefaultRotation,
                        onChanged: (value) {
                          setState(() {
                            useDefaultRotation = value!;
                          });
                        },
                      ),
                      RadioListTile<bool>(
                        dense: true,
                        title: Text("Use Custom Rotation"),
                        value: false,
                        groupValue: useDefaultRotation,
                        onChanged: (value) {
                          setState(() {
                            useDefaultRotation = value!;
                          });
                        },
                      ),
                      if (!useDefaultRotation) ...[
                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: DropdownButton<Rotation>(
                            value: customRotation,
                            items: [
                              DropdownMenuItem(
                                value: Rotation.none,
                                child: Text("None"),
                              ),
                              DropdownMenuItem(
                                value: Rotation.clockwise90,
                                child: Text("Clockwise 90°"),
                              ),
                              DropdownMenuItem(
                                value: Rotation.counterClockwise90,
                                child: Text("Counter-clockwise 90°"),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  customRotation = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );

    var linkedCardFaceTab = Center(
      child: widget.linkedCardFaces.isEmpty
          ? Text("You have not defined any linked card face yet.")
          : LinkedCardFaceDropdown(
              linkedCardFaces: widget.linkedCardFaces,
              selectedValue: selectedCardFace,
              onChanged: (value) {
                setState(() {
                  selectedCardFace = value;
                  tempFilePath =
                      null; // Clear the file path when selecting a linked card face
                });
              },
            ),
    );

    return AlertDialog(
      title: widget.forLinkedCardFaceTab
          ? Text("Edit Linked Card Face")
          : Text("Edit Card Face"),
      content: SizedBox(
        width: 650,
        child: DefaultTabController(
          length: widget.forLinkedCardFaceTab ? 1 : 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!widget.forLinkedCardFaceTab)
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: "File"),
                    Tab(text: "Linked Card Face"),
                  ],
                ),
              SizedBox(
                height: 450,
                child: TabBarView(
                  controller: _tabController,
                  children: widget.forLinkedCardFaceTab
                      ? [relativeFilePathTab]
                      : [
                          relativeFilePathTab,
                          linkedCardFaceTab,
                        ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            final tempFilePath = this.tempFilePath;
            final selectedCardFace = this.selectedCardFace;
            if (_tabController.index == 0 && tempFilePath != null) {
              // New card should preserve everything except changing the file path.
              // But always new instance.
              final initialCard = widget.initialCard;
              final CardFace newCard;
              if (initialCard != null) {
                newCard =
                    initialCard.copyChangingRelativeFilePath(tempFilePath);
                // Update content expand settings
                newCard.useDefaultContentExpand = useDefaultContentExpand;
                if (!useDefaultContentExpand) {
                  newCard.contentExpand = customContentExpand;
                }
                // Update rotation settings
                newCard.useDefaultRotation = useDefaultRotation;
                if (!useDefaultRotation) {
                  newCard.rotation = customRotation;
                }
              } else {
                newCard = CardFace.withRelativeFilePath(tempFilePath);
                // Apply content expand settings to new card
                newCard.useDefaultContentExpand = useDefaultContentExpand;
                if (!useDefaultContentExpand) {
                  newCard.contentExpand = customContentExpand;
                }
                // Apply rotation settings to new card
                newCard.useDefaultRotation = useDefaultRotation;
                if (!useDefaultRotation) {
                  newCard.rotation = customRotation;
                }
              }
              widget.onCardFaceChange(newCard);
            } else if (_tabController.index == 1 && selectedCardFace != null) {
              // Different instance so component updates, but inside it's same UUID.
              final newCard = selectedCardFace.copyIncludingUuid();
              widget.onCardFaceChange(newCard);
            }
            Navigator.of(context).pop();
          },
          child: Text("OK"),
        ),
      ],
    );
  }
}

// Open dialog to pick JPG or PNG file, path returned is relative to baseDirectory
Future<String?> pickRelativePath(String basePath) async {
  final XFile? pickResult = await openFile(
    acceptedTypeGroups: [
      XTypeGroup(
        label: 'Image Files',
        extensions: ['png', 'jpg'],
      ),
    ],
  );
  if (pickResult == null) return null;
  final filePath = pickResult.path;
  final isUnderBasePath = p.isWithin(basePath, filePath);
  if (!isUnderBasePath) return null;
  final relativePath = p.relative(filePath, from: basePath);
  return relativePath;
}
