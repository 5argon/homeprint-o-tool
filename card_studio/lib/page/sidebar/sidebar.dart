import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/page/sidebar/loaded_project_display.dart';

class Sidebar extends StatefulWidget {
  @override
  State<Sidebar> createState() => _SidebarState();

  final Function() onNew;
  final Function() onLoad;
  final Function() onSave;
  final Function() onExport;
  final String? previousFileName;
  final bool hasChanges;

  Sidebar({
    required this.previousFileName,
    required this.hasChanges,
    required this.onNew,
    required this.onLoad,
    required this.onSave,
    required this.onExport,
  });
}

class _SidebarState extends State<Sidebar> {
  int _selectedIndex = 2;

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
          onPressed: () async {
            widget.onSave();
          },
          child: Text("Save")),
    );

    final sidebar = SizedBox(
      width: 200,
      child: NavigationDrawer(
          onDestinationSelected: (i) => {
                setState(() {
                  _selectedIndex = i;
                })
              },
          selectedIndex: _selectedIndex,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Tooltip(
                message:
                    "A project file defines relationship of individual card images relative to its location, independently of printer and paper dimension. Any changes using menu above the dividing line below can be saved back to the project file.",
                child: Text(
                  "Project",
                  style: textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            LoadedProjectDisplay(
              loadedProjectFileName: widget.previousFileName,
              hasChanges: widget.hasChanges,
            ),
            newButton,
            loadButton,
            saveButton,
            NavigationDrawerDestination(
                icon: Icon(Icons.widgets_outlined),
                label: Text("Project Settings")),
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
                icon: Icon(Icons.widgets_outlined),
                label: Tooltip(
                    message:
                        "Setup paper size and printing layout. These are preserved even if you loaded into other project files.",
                    child: Text("Printer"))),
            NavigationDrawerDestination(
                icon: Icon(Icons.widgets_outlined),
                label: Tooltip(
                    message:
                        "Pick cards to be printed. While it defaults to print one set of the entire project, you can change it to print only a subset, or print more copies of a certain cards.",
                    child: Text("Picks"))),
            NavigationDrawerDestination(
                icon: Icon(Icons.widgets_outlined),
                label: Tooltip(
                    message:
                        "View how the final uncut sheet looks like, when all the cards you choose in Picks menu are laid out according to Printer settings.",
                    child: Text("Review"))),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OutlinedButton(
                  onPressed: () {
                    widget.onExport();
                  },
                  child: Text("Export")),
            ),
          ]),
    );
    return sidebar;
  }
}
