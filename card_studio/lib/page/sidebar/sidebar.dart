import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/page/picks/include_data.dart';
import 'package:homeprint_o_tool/page/sidebar/loaded_project_display.dart';
import 'package:homeprint_o_tool/core/form/help_button.dart';

// Helper for responsive buttons
Widget buildResponsiveButton({
  required Icon icon,
  required String label,
  required VoidCallback? onPressed,
  required bool isCompact, // Pass isCompact as a parameter
}) {
  final outlinedButton = OutlinedButton.icon(
    onPressed: onPressed,
    icon: icon,
    label: Text(label),
  );
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: outlinedButton,
  );
}

// Helper for responsive navigation destinations
Widget buildResponsiveNavigationDestination({
  required Icon icon,
  required String label,
  required bool isCompact, // Pass isCompact as a parameter
}) {
  // Outermost widget must be NavigationDrawerDestination
  final navigation = NavigationDrawerDestination(
    icon: icon,
    label: Text(label),
  );
  return navigation;
}

class Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = MediaQuery.sizeOf(context).width < 800;

        final newButton = buildResponsiveButton(
          icon: Icon(Icons.add),
          label: "New JSON",
          onPressed: () async {
            onNew();
          },
          isCompact: isCompact,
        );
        final loadButton = buildResponsiveButton(
          icon: Icon(Icons.folder_open),
          label: "Load JSON",
          onPressed: () {
            onLoad();
          },
          isCompact: isCompact,
        );
        final saveButton = buildResponsiveButton(
          icon: Icon(Icons.save),
          label: "Save",
          onPressed: previousFileName == null
              ? null
              : () async {
                  onSave();
                },
          isCompact: isCompact,
        );

        final effectiveSelectedIndex =
            baseDirectory == null ? -1 : selectedIndex;

        final sectionHelpButton = HelpButton(
          title: "Project Section",
          paragraphs: [
            "A section for authoring the JSON printing specification file. Any changes you did in this section must be manually saved back into the file with the Save button. If you are on the consumer side that just wanted to print at home, you can ignore this section and start on the \"Printing\" section below.",
            "\"Project\" is to set constant values applying to all cards, most importantly the project's card size, because this app can only create an uncut sheet of cards of the same size. In \"Linked Card Face\", you can define a reusable card face that can be used as either card front or card back of any card, so they all link to one single image file and any changes to the graphic is updated throughout the project.",
            "\"Cards\" is the heart of the project where you first create a group of cards, then each individual card inside the group with their default quantity per one pick of the group. User can pick just a part of the project to print based on groups you defined, or any single card individually. Each card is defined by a relative path starting from the location of the JSON file. Hover on the JSON file name under the project label to see the full path.",
          ],
        );

        var projectLabel = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Project",
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            sectionHelpButton,
          ],
        );

        final sidebarChildren = <Widget>[
          newButton,
          loadButton,
        ];

        final projectChildren = <Widget>[
          Divider(
            indent: 20,
            endIndent: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: projectLabel,
          ),
          LoadedProjectDisplay(
            baseDirectory: baseDirectory,
            loadedProjectFileName: previousFileName,
            hasChanges: hasChanges,
          ),
          saveButton,
        ];

        // Only show the project section if a project is loaded.
        if (baseDirectory != null) {
          sidebarChildren.addAll(projectChildren);
        }

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
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground),
              ),
            ),
          ],
        );

        final exportButtonInner = OutlinedButton.icon(
            onPressed: noIncludes
                ? null
                : () {
                    onExport();
                  },
            icon: Icon(Icons.upload), // Upload icon for "Export"
            label: Text("Export"));
        final exportButton = noIncludes
            ? Tooltip(
                message: "You have not picked any card yet.",
                child: exportButtonInner,
              )
            : exportButtonInner;

        final printingHelpButton =
            HelpButton(title: "Printing Section", paragraphs: [
          "Settings in this section are for the consumer side of the JSON file. It is recommended to set them up in the order from top to bottom.",
          "\"Layout\" determines how many cards can fit in a single page and how much room of error they have to cut out the bleed of each card. That is then used in \"Picks\" page. It let you select which and how many cards you want to print, in the unit of card groups that the author of JSON file had prepared, or individually. It can show which page a particular group or card you selected will be landed on. Finally, the \"Post-Processing\" page let you review the resulting uncut sheet image that will be saved, with an optional rotation or flipping of the image.",
          "Everything in this section is not saved into the project JSON file when pressing Save in the above section. Loading a different JSON retain the settings. Each time this app reopens, they are reset to default values and must be configured again.",
        ]);
        var printingLabel = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Printing",
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            printingHelpButton
          ],
        );

        final addedSidebarWhenProjectLoaded = <Widget>[
          buildResponsiveNavigationDestination(
            icon: Icon(Icons.settings),
            label: "Project Settings",
            isCompact: isCompact,
          ),
          buildResponsiveNavigationDestination(
            icon: Icon(Icons.link),
            label: "Linked Card Face",
            isCompact: isCompact,
          ),
          buildResponsiveNavigationDestination(
            icon: Icon(Icons.style),
            label: "Cards",
            isCompact: isCompact,
          ),
          Divider(
            indent: 20,
            endIndent: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: printingLabel,
          ),
          NavigationDrawerDestination(
              icon: Icon(Icons.grid_on),
              label: Text("Layout")), // Grid icon for layout
          NavigationDrawerDestination(
              icon: Icon(Icons.checklist),
              label: picksLabelWithCardCount), // Checklist icon for picks
          NavigationDrawerDestination(
              icon: Icon(Icons.preview),
              label: Text("Review")), // Preview icon for review
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: exportButton,
          ),
        ];

        if (baseDirectory != null) {
          sidebarChildren.addAll(addedSidebarWhenProjectLoaded);
        }

        return SizedBox(
          width: isCompact ? 220 : 220,
          child: NavigationDrawer(
            onDestinationSelected: (i) => {
              onSelectedIndexChanged(i),
            },
            selectedIndex: effectiveSelectedIndex,
            children: sidebarChildren,
          ),
        );
      },
    );
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
