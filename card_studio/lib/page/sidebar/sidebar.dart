import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/page/include/include_data.dart';
import 'package:homeprint_o_tool/page/sidebar/loaded_project_display.dart';

class Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final newButton = Padding(
        padding: const EdgeInsets.all(8.0),
        child: OutlinedButton(
          onPressed: () async {
            onNew();
          },
          child: Text("New"),
        ));

    final loadButton = Padding(
      padding: const EdgeInsets.all(8.0),
      child: OutlinedButton(
          onPressed: () {
            onLoad();
          },
          child: Text("Load")),
    );

    final saveButton = Padding(
      padding: const EdgeInsets.all(8.0),
      child: OutlinedButton(
          onPressed: previousFileName == null
              ? null
              : () async {
                  onSave();
                },
          child: Text("Save")),
    );

    final effectiveSelectedIndex = baseDirectory == null ? -1 : selectedIndex;

    final sidebarChildren = <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "Project",
          style: textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ),
      LoadedProjectDisplay(
        baseDirectory: baseDirectory,
        loadedProjectFileName: previousFileName,
        hasChanges: hasChanges,
      ),
      newButton,
      loadButton,
      saveButton,
    ];

    // Cannot review and cannot export if no includes.
    final noIncludes = includes.isEmpty;

    final cardCount = countIncludes(includes);
    // Text followed by a circle with count of cards.
    final picksLabelWithCardCount = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Picks"),
        SizedBox(
          width: 10,
        ),
        CircleAvatar(
          radius: 20,
          backgroundColor: Theme.of(context).colorScheme.background,
          child: Text(
            cardCount.toString(),
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
          ),
        ),
      ],
    );

    final exportButtonInner = OutlinedButton(
        onPressed: noIncludes
            ? null
            : () {
                onExport();
              },
        child: Text("Export"));
    final exportButton = noIncludes
        ? Tooltip(
            message: "You have not picked any card yet.",
            child: exportButtonInner,
          )
        : exportButtonInner;

    var printingLabel = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Printing",
          style: textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        IconButton(
          icon: Icon(Icons.help_outline),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Printing Section"),
                  content: SizedBox(
                    width: 400,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            "Settings in this section are for the consumer side of the JSON file. It is recommended to set them up in the order from top to bottom."),
                        SizedBox(height: 10), // Add spacing between paragraphs
                        Text(
                            "\"Printer\" page determines how many cards can fit in a single page and how much room of error they have to cut out the bleed of each card. That is then used in \"Picks\" page. It let you select which and how many cards you want to print, in the unit of card groups that the author of JSON file had prepared, or individually. It can show which page a particular group or card you selected will be landed on. Finally, the \"Post-Processing\" page let you review the resulting uncut sheet image that will be saved, with an optional rotation or flipping of the image."),
                        SizedBox(height: 10), // Add spacing between paragraphs
                        Text(
                          "The settings are not saved into the JSON file when pressing the Save button above. Loading a different JSON or even closing and opening the app again will retain the settings. Each time this app reopens, they are reset to default values.",
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Close"),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );

    final addedSidebarWhenProjectLoaded = <Widget>[
      NavigationDrawerDestination(
          icon: Icon(Icons.widgets_outlined), label: Text("Master Settings")),
      NavigationDrawerDestination(
          icon: Icon(Icons.widgets_outlined), label: Text("Instances")),
      NavigationDrawerDestination(
          icon: Icon(Icons.widgets_outlined), label: Text("Cards")),
      Divider(
        indent: 20,
        endIndent: 20,
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: printingLabel,
      ),
      NavigationDrawerDestination(
          icon: Icon(Icons.widgets_outlined), label: Text("Printer")),
      NavigationDrawerDestination(
          icon: Icon(Icons.widgets_outlined), label: picksLabelWithCardCount),
      NavigationDrawerDestination(
          icon: Icon(Icons.widgets_outlined), label: Text("Post-Processing")),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: exportButton,
      ),
    ];

    if (baseDirectory != null) {
      sidebarChildren.addAll(addedSidebarWhenProjectLoaded);
    }

    final sidebar = SizedBox(
      width: 200,
      child: NavigationDrawer(
          onDestinationSelected: (i) => {
                onSelectedIndexChanged(i),
              },
          selectedIndex: effectiveSelectedIndex,
          children: sidebarChildren),
    );
    return sidebar;
  }

  final int selectedIndex;
  final Function(int) onSelectedIndexChanged;
  final Function() onNew;
  final Function() onLoad;
  final Function() onSave;
  final Function() onExport;
  final String? baseDirectory;
  final String? previousFileName;
  final bool hasChanges;
  final Future? fullScreenDisableFuture;
  final Includes includes;

  Sidebar({
    required this.selectedIndex,
    required this.onSelectedIndexChanged,
    required this.baseDirectory,
    required this.previousFileName,
    required this.hasChanges,
    required this.onNew,
    required this.onLoad,
    required this.onSave,
    required this.onExport,
    required this.fullScreenDisableFuture,
    required this.includes,
  });
}
