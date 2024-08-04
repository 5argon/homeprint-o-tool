import 'package:homeprint_o_tool/core/card.dart';
import 'package:homeprint_o_tool/page/include/include_page.dart';
import 'package:homeprint_o_tool/page/layout/back_strategy.dart';
import 'package:homeprint_o_tool/page/review/review_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/page_preview/render.dart';
import 'core/project_settings.dart';
import 'core/save_file.dart';
import 'page/card/card_page.dart';
import 'page/include/include_data.dart';
import 'page/layout/layout_page.dart';
import 'page/layout/layout_struct.dart';

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
        title: 'Homeprint O\' Tool',
        themeMode: ThemeMode.system,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 0, 70, 56)),
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
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
  pixelPerInch: 300,
  paperSize: SizePhysical(13, 19, PhysicalSizeType.inch),
  // paperSize: SizePhysical(19, 13, PhysicalSizeType.inch),
  // paperSize: SizePhysical(21, 29.7, PhysicalSizeType.centimeter),
  marginSize: SizePhysical(0.4, 0.4, PhysicalSizeType.centimeter),
  edgeCutGuideSize: SizePhysical(0.1, 0.1, PhysicalSizeType.centimeter),
  // edgeCutGuideSize: SizePhysical(0.1, 2.1, PhysicalSizeType.centimeter),
  // perCardPadding: SizePhysical(0.2, 0.2, PhysicalSizeType.centimeter),
  perCardPadding: SizePhysical(0.4, 0.4, PhysicalSizeType.centimeter),
  perCardCutGuideLength: ValuePhysical(0.3, PhysicalSizeType.centimeter),
  layoutStyle: LayoutStyle.duplex,
  backStrategy: BackStrategy.invertedRow,
  exportRotation: ExportRotation.rotate90OppositeWay,
  skips: [],
);

var defaultProjectSettings = ProjectSettings(
    SizePhysical(6.15, 8.8, PhysicalSizeType.centimeter),
    SynthesizedBleed.mirror,
    Alignment.center,
    1.0,
    Rotation.none);

DefinedCards defaultDefinedCards = [CardGroup([], "Default Group")];

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 2;

  /// Prefix this path to all the individual card file name to load image from.
  /// Image cannot load yet without this since they are all relative to this path.
  /// Unfortunately this is `null` when the app just started. User is required
  /// to select a base directory at some point. Loading any JSON file will set
  /// that directory as a base.
  String? _baseDirectory;
  String? _previousFileName;

  // These three are defined by project.
  ProjectSettings _projectSettings = defaultProjectSettings;
  DefinedCards _definedCards = defaultDefinedCards;
  DefinedInstances _definedInstances = [];

  /// Not stored in the save file.
  Includes _includes = [];
  Includes _skipIncludes = [];
  LayoutData _layoutData = defaultLayoutData;

  Future? fileLoadingFuture;
  Future? renderingFuture;
  int exportingCurrentPage = 0;
  ExportingFrontBack exportingFrontBack = ExportingFrontBack.front;
  int exportingTotalPage = 0;

  @override
  initState() {
    super.initState();
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

          Widget needProjectLoaded = Center(
            child: Text(
                "No project loaded. Use New or Load button on the sidebar to get started."),
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
                case 2:
                  final baseDirectory = _baseDirectory;
                  if (baseDirectory == null) {
                    return needProjectLoaded;
                  }
                  var cardPage = CardPage(
                    basePath: baseDirectory,
                    projectSettings: _projectSettings,
                    definedCards: _definedCards,
                    definedInstances: _definedInstances,
                    onDefinedCardsChange: (definedCards) {
                      setState(() {
                        _definedCards = definedCards;
                      });
                    },
                  );
                  return cardPage;
                case 3:
                  var layoutPage = LayoutPage(
                    layoutData: _layoutData,
                    onLayoutDataChanged: (ld) {
                      setState(() {
                        _layoutData = ld;
                      });
                    },
                    projectSettings: _projectSettings,
                  );
                  return layoutPage;
                case 4:
                  final baseDirectory = _baseDirectory;
                  if (baseDirectory == null) {
                    return Text("Need base directory to render cards.");
                  }
                  var includePage = IncludePage(
                    basePath: baseDirectory,
                    projectSettings: _projectSettings,
                    layoutData: _layoutData,
                    definedCards: _definedCards,
                    definedInstances: _definedInstances,
                    includes: _includes,
                    skipIncludes: _skipIncludes,
                    onIncludesChanged: (p0) {
                      setState(() {
                        _includes = p0;
                      });
                    },
                    onSkipIncludesChanged: (p0) {
                      setState(() {
                        _skipIncludes = p0;
                      });
                    },
                  );
                  return includePage;
                case 5:
                  final baseDirectory = _baseDirectory;
                  if (baseDirectory != null) {
                    var reviewPage = ReviewPage(
                      layoutData: _layoutData,
                      projectSettings: _projectSettings,
                      includes: _includes,
                      skipIncludes: _skipIncludes,
                      baseDirectory: baseDirectory,
                    );
                    return reviewPage;
                  }
                  return Text("Need base directory to render cards.");
                default:
                  return wipPage;
              }
          }
        },
        future: fileLoadingFuture);

    Widget rendering = FutureBuilder(
        builder: (context, snapshot) {
          String frontBack =
              exportingFrontBack == ExportingFrontBack.front ? "Front" : "Back";
          Widget exporting = Center(
            child: Text(
                "Exporting page $exportingCurrentPage of $exportingTotalPage ($frontBack)"),
          );
          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.waiting:
              return exporting;
            default:
              {
                return visiblePage;
              }
          }
        },
        future: renderingFuture);

    final newButton = Padding(
        padding: const EdgeInsets.all(8.0),
        child: OutlinedButton(
          onPressed: () async {
            final filePath = await FilePicker.platform.saveFile(
              dialogTitle:
                  "Where the file is saved will be set as project's base directory as well.",
              initialDirectory: _baseDirectory,
              fileName: _previousFileName,
              allowedExtensions: ['json'],
            );
            if (filePath != null) {
              final saveFile =
                  SaveFile(_projectSettings, _definedInstances, _definedCards);
              final saveResult = await saveFile.saveToFile(filePath);
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    "Created a new project. Base directory is now : ${saveResult.baseDirectory}"),
              ));
              setState(() {
                _projectSettings = defaultProjectSettings;
                _definedCards = defaultDefinedCards;
                _definedInstances = [];
                _baseDirectory = saveResult.baseDirectory;
                _previousFileName = saveResult.fileName;
                _includes = [];
              });
            }
          },
          child: Text("New"),
        ));

    final loadButton = Padding(
      padding: const EdgeInsets.all(8.0),
      child: OutlinedButton(
          onPressed: () {
            final fut = SaveFile.loadFromFilePicker().then((loadResult) {
              if (loadResult != null) {
                setState(() {
                  _projectSettings = loadResult.saveFile.projectSettings;
                  _definedCards = loadResult.saveFile.cardGroups;
                  _definedInstances = loadResult.saveFile.instances;
                  _baseDirectory = loadResult.basePath;
                  _previousFileName = loadResult.fileName;
                  // Overwrite inclues to all cards on load.
                  Includes newIncludes = [];
                  for (var i = 0; i < _definedCards.length; i++) {
                    newIncludes.add(IncludeItem.cardGroup(_definedCards[i], 1));
                  }
                  _includes = newIncludes;
                  _skipIncludes = [];
                });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
    );

    final saveButton = Padding(
      padding: const EdgeInsets.all(8.0),
      child: OutlinedButton(
          onPressed: () async {
            final filePath = await FilePicker.platform.saveFile(
              dialogTitle:
                  "Where the file is saved will be set as project's base directory as well.",
              initialDirectory: _baseDirectory,
              fileName: _previousFileName,
              allowedExtensions: ['json'],
            );
            if (filePath != null) {
              final saveFile =
                  SaveFile(_projectSettings, _definedInstances, _definedCards);
              final saveResult = await saveFile.saveToFile(filePath);
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
    );

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
                        loadedProjectFileName: _previousFileName,
                      ),
                      newButton,
                      loadButton,
                      saveButton,
                      NavigationDrawerDestination(
                          icon: Icon(Icons.widgets_outlined),
                          label: Text("Project Settings")),
                      NavigationDrawerDestination(
                          icon: Icon(Icons.widgets_outlined),
                          label: Text("Instances")),
                      NavigationDrawerDestination(
                          icon: Icon(Icons.widgets_outlined),
                          label: Text("Cards")),
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
                            onPressed: () async {
                              final baseDirectory = _baseDirectory;
                              if (baseDirectory != null) {
                                final flutterView = View.of(context);
                                final directory =
                                    await openExportDirectoryPicker();
                                if (directory != null && context.mounted) {
                                  final renderingFuture = renderRender(
                                      context,
                                      directory,
                                      flutterView,
                                      _projectSettings,
                                      _layoutData,
                                      _includes,
                                      _skipIncludes,
                                      baseDirectory, (currentPage) {
                                    setState(() {
                                      exportingCurrentPage = currentPage;
                                    });
                                  }, (frontBack) {
                                    setState(() {
                                      exportingFrontBack = frontBack;
                                    });
                                  }, (totalPage) {
                                    setState(() {
                                      exportingTotalPage = totalPage;
                                    });
                                  });
                                  setState(() {
                                    this.renderingFuture = renderingFuture;
                                  });
                                }
                              }
                            },
                            child: Text("Export")),
                      ),
                    ]),
              ),
              Expanded(child: rendering),
            ],
          ),
        ),
      );
    });
  }
}

class LoadedProjectDisplay extends StatelessWidget {
  const LoadedProjectDisplay({
    super.key,
    required String? loadedProjectFileName,
  }) : _previousFileName = loadedProjectFileName;

  final String? _previousFileName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        _previousFileName ?? "(No Loaded Project)",
        style: textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),
    );
  }
}
