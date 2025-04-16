import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/page/sidebar/loaded_project_display.dart';

class Sidebar extends StatefulWidget {
  @override
  State<Sidebar> createState() => _SidebarState();

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
  });
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final newButton = Padding(
        padding: const EdgeInsets.all(8.0),
        child: OutlinedButton(
          onPressed: () async {
            widget.onNew();
          },
          child: Text("New"),
        ));

    final loadButton = Padding(
      padding: const EdgeInsets.all(8.0),
      child: OutlinedButton(
          onPressed: () {
            widget.onLoad();
          },
          child: Text("Load")),
    );

    final saveButton = Padding(
      padding: const EdgeInsets.all(8.0),
      child: OutlinedButton(
          onPressed: widget.previousFileName == null
              ? null
              : () async {
                  widget.onSave();
                },
          child: Text("Save")),
    );

    final effectiveSelectedIndex =
        widget.baseDirectory == null ? -1 : widget.selectedIndex;

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
        baseDirectory: widget.baseDirectory,
        loadedProjectFileName: widget.previousFileName,
        hasChanges: widget.hasChanges,
      ),
      newButton,
      loadButton,
      saveButton,
    ];

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
        child: Tooltip(
          message:
              "All settings below the dividing line are for printing side. These are not saved into the project file.",
          child: Text(
            "Printing",
            style: textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
      NavigationDrawerDestination(
          icon: Icon(Icons.widgets_outlined), label: Text("Printer")),
      NavigationDrawerDestination(
          icon: Icon(Icons.widgets_outlined), label: Text("Picks")),
      NavigationDrawerDestination(
          icon: Icon(Icons.widgets_outlined), label: Text("Review")),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: OutlinedButton(
            onPressed: () {
              widget.onExport();
            },
            child: Text("Export")),
      ),
    ];

    if (widget.baseDirectory != null) {
      sidebarChildren.addAll(addedSidebarWhenProjectLoaded);
    }

    final sidebar = SizedBox(
      width: 200,
      child: NavigationDrawer(
          onDestinationSelected: (i) => {
                widget.onSelectedIndexChanged(i),
              },
          selectedIndex: effectiveSelectedIndex,
          children: sidebarChildren),
    );
    return sidebar;
  }
}
