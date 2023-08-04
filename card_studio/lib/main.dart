import 'package:card_studio/core/card.dart';
import 'package:card_studio/page/review/review_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/project_settings.dart';
import 'core/save_file.dart';
import 'page/include/include_data.dart';
import 'page/layout/layout_page.dart';
import 'page/layout/layout_struct.dart';
import 'page/layout/render.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) {},
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 0, 70, 56)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

var defaultLayoutData = LayoutData(
  SizePhysical(21, 29.7, PhysicalSizeType.centimeter),
  300,
  SizePhysical(0.5, 0.5, PhysicalSizeType.centimeter),
  SizePhysical(1, 1, PhysicalSizeType.centimeter),
  SizePhysical(0.5, 0.5, PhysicalSizeType.centimeter),
  ValuePhysical(0.3, PhysicalSizeType.centimeter),
  LayoutStyle.duplex,
  false,
  false,
  false,
);

var defaultProjectSettings = ProjectSettings(
    SizePhysical(6.3, 8.15, PhysicalSizeType.centimeter),
    SynthesizedBleed.mirror);

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 4;

  /// Prefix this path to all the individual card file name to load image from.
  /// Image cannot load yet without this since they are all relative to this path.
  /// Unfortunately this is `null` when the app just started. User is required
  /// to select a base directory at some point. Loading any JSON file will set
  /// that directory as a base.
  String? _baseDirectory;
  String? _previousFileName = "project.json";

  // These three are defined by project.
  ProjectSettings _projectSettings = defaultProjectSettings;
  DefinedCards _definedCards = [CardGroup([], "Default Group")];
  DefinedInstances _definedInstances = [];

  /// Not stored in the save file.
  Includes _includes = [];
  LayoutData _layoutData = defaultLayoutData;

  Future? fileLoadingFuture;

  @override
  initState() {
    super.initState();
    loadThenAssign("/Users/5argon/Desktop/TabooPrintProject/test.json");
  }

  loadThenAssign(String path) {
    fileLoadingFuture = SaveFile.loadFromPath(path).then((value) {
      setState(() {
        _baseDirectory = value.basePath;
        _projectSettings = value.saveFile.projectSettings;
        _definedCards = value.saveFile.cardGroups;
        _definedInstances = value.saveFile.instances;
      });
      return;
    });
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    Widget visiblePage = FutureBuilder(
        builder: (context, snapshot) {
          Widget loadingPage = Center(
            child: CircularProgressIndicator(),
          );

          Widget wipPage = Center(
            child: Text("WIP"),
          );

          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.waiting:
              return loadingPage;
            default:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              switch (_selectedIndex) {
                case 4:
                  var layoutPage = LayoutPage(
                    layoutData: defaultLayoutData,
                    projectSettings: defaultProjectSettings,
                  );
                  return layoutPage;
                case 5:
                  var reviewPage = ReviewPage(
                    layoutData: defaultLayoutData,
                    projectSettings: defaultProjectSettings,
                  );
                  return reviewPage;
                default:
                  return wipPage;
              }
          }
        },
        future: fileLoadingFuture);

    return Builder(builder: (context) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              SizedBox(
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
                        child: Text(
                          "Project",
                          style: textTheme.titleMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OutlinedButton(
                            onPressed: () {
                              final fut = SaveFile.loadFromFilePicker()
                                  .then((loadResult) {
                                if (loadResult != null) {
                                  setState(() {
                                    _projectSettings =
                                        loadResult.saveFile.projectSettings;
                                    _definedCards =
                                        loadResult.saveFile.cardGroups;
                                    _definedInstances =
                                        loadResult.saveFile.instances;
                                    _baseDirectory = loadResult.basePath;
                                  });
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                        "Loaded a project JSON. Base directory is now : ${loadResult.basePath}"),
                                  ));
                                }
                              });
                              setState(() {
                                fileLoadingFuture = fut;
                              });
                            },
                            child: Text("Load")),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OutlinedButton(
                            onPressed: () async {
                              final filePath =
                                  await FilePicker.platform.saveFile(
                                dialogTitle:
                                    "Where the file is saved will be set as project's base directory as well.",
                                initialDirectory: _baseDirectory,
                                fileName: _previousFileName,
                                allowedExtensions: ['json'],
                              );
                              if (filePath != null) {
                                final saveFile = SaveFile(_projectSettings,
                                    _definedInstances, _definedCards);
                                final saveResult =
                                    await saveFile.saveToFile(filePath);
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      "Save successful. Base directory is now : ${saveResult.baseDirectory}"),
                                ));
                                setState(() {
                                  _baseDirectory = saveResult.baseDirectory;
                                  _previousFileName = saveResult.fileName;
                                });
                              }
                            },
                            child: Text("Save")),
                      ),
                      NavigationDrawerDestination(
                          icon: Icon(Icons.widgets_outlined),
                          label: Text("Settings")),
                      NavigationDrawerDestination(
                          icon: Icon(Icons.widgets_outlined),
                          label: Text("Instance")),
                      NavigationDrawerDestination(
                          icon: Icon(Icons.widgets_outlined),
                          label: Text("Card")),
                      Divider(
                        indent: 20,
                        endIndent: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Export",
                          style: textTheme.titleMedium,
                        ),
                      ),
                      NavigationDrawerDestination(
                          icon: Icon(Icons.widgets_outlined),
                          label: Text("Include")),
                      NavigationDrawerDestination(
                          icon: Icon(Icons.widgets_outlined),
                          label: Text("Layout")),
                      NavigationDrawerDestination(
                          icon: Icon(Icons.widgets_outlined),
                          label: Text("Review")),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OutlinedButton(
                            onPressed: () {
                              renderRender(context, _projectSettings,
                                  _layoutData, _includes);
                            },
                            child: Text("Export")),
                      ),
                    ]),
              ),
              Expanded(child: visiblePage),
            ],
          ),
        ),
      );
    });
  }
}
