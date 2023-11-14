import 'package:card_studio/core/card.dart';
import 'package:card_studio/page/layout/back_strategy.dart';
import 'package:card_studio/page/review/review_page.dart';
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
        title: 'Namer App',
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
  // paperSize: SizePhysical(8.3, 11.7, PhysicalSizeType.inch),
  marginSize: SizePhysical(0.2, 0.5, PhysicalSizeType.centimeter),
  edgeCutGuideSize: SizePhysical(0.1, 0.1, PhysicalSizeType.centimeter),
  perCardWhitePadding: SizePhysical(0.5, 0.5, PhysicalSizeType.centimeter),
  perCardCutGuideLength: ValuePhysical(0.3, PhysicalSizeType.centimeter),
  layoutStyle: LayoutStyle.duplex,
  backStrategy: BackStrategy.invertedRow,
  skips: [21, 22, 23, 24, 25],
);

var defaultProjectSettings = ProjectSettings(
    SizePhysical(6.3, 8.15, PhysicalSizeType.centimeter),
    SynthesizedBleed.mirror);

DefinedCards defaultDefinedCards = [CardGroup([], "Default Group")];

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 4;

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
    // loadThenAssign("/Users/5argon/Desktop/TabooPrintProject/test.json");
  }

  loadThenAssign(String path) {
    fileLoadingFuture = SaveFile.loadFromPath(path).then((value) {
      setState(() {
        _baseDirectory = value.basePath;
        _projectSettings = value.saveFile.projectSettings;
        _definedCards = value.saveFile.cardGroups;
        _definedInstances = value.saveFile.instances;
        // Include everything for now.
        for (var i = 0; i < _definedCards.length; i++) {
          _includes.add(IncludeItem.cardGroup(_definedCards[i], 1));
        }
        // final lita = _definedCards.where((element) {
        //   return element.name == "Lita";
        // }).first;
        // _includes.add(IncludeItem.cardGroup(lita, 1));
        // for (var i = 0; i < _definedCards.length; i++) {
        //   if (_definedCards[i].name != "Lita") {
        //     _includes.add(IncludeItem.cardGroup(_definedCards[i], 2));
        //   }
        // }
        // final pete = _definedCards.where((element) {
        //   return element.name == "Parallel Ashcan Pete";
        // }).first;
        // final zoey = _definedCards.where((element) {
        //   return element.name == "Parallel Zoey Samaras";
        // }).first;
        // final jim = _definedCards.where((element) {
        //   return element.name == "Parallel Jim Culver";
        // }).first;
        // final laid = _definedCards.where((element) {
        //   return element.name == "Laid to Rest";
        // }).first;
        // final suzi = _definedCards.where((element) {
        //   return element.name == "Subject 5U-21";
        // }).first;
        // final blob = _definedCards.where((element) {
        //   return element.name == "The Blob That Ate Everything ELSE";
        // }).first;

        // _includes.add(IncludeItem.cardGroup(pete, 1));
        // _includes.add(IncludeItem.cardGroup(zoey, 1));
        // _includes.add(IncludeItem.cardGroup(jim, 2));

        // _includes.add(IncludeItem.cardGroup(suzi, 1));
        // _includes.add(IncludeItem.cardGroup(zoey, 1));
        // _includes.add(IncludeItem.cardGroup(laid, 1));
        // _includes.add(IncludeItem.cardGroup(jim, 1));
        // _includes.add(IncludeItem.cardGroup(blob, 2));
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
                case 2:
                  final baseDirectory = _baseDirectory;
                  if (baseDirectory == null) {
                    return Text("Need base directory to render cards.");
                  }
                  var cardPage = CardPage(
                    basePath: baseDirectory,
                    projectSettings: _projectSettings,
                    definedCards: _definedCards,
                    definedInstances: _definedInstances,
                  );
                  return cardPage;
                case 4:
                  var layoutPage = LayoutPage(
                    layoutData: _layoutData,
                    projectSettings: _projectSettings,
                  );
                  return layoutPage;
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
                  return wipPage;
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
                  // for (var i = 0; i < _definedCards.length; i++) {
                  //   newIncludes.add(IncludeItem.cardGroup(_definedCards[i], 1));
                  // }

                  newIncludes.add(IncludeItem.cardGroup(_definedCards[0], 1));
                  newIncludes.add(IncludeItem.cardGroup(_definedCards[1], 2));
                  newIncludes.add(IncludeItem.cardGroup(_definedCards[4], 1));
                  newIncludes.add(IncludeItem.cardGroup(_definedCards[6], 1));
                  newIncludes
                      .add(IncludeItem.cardEach(_definedCards[5].cards[0], 1));
                  newIncludes
                      .add(IncludeItem.cardEach(_definedCards[5].cards[1], 1));
                  newIncludes
                      .add(IncludeItem.cardEach(_definedCards[5].cards[7], 1));
                  newIncludes
                      .add(IncludeItem.cardEach(_definedCards[7].cards[4], 1));
                  newIncludes
                      .add(IncludeItem.cardEach(_definedCards[2].cards[0], 1));
                  newIncludes
                      .add(IncludeItem.cardEach(_definedCards[2].cards[1], 1));
                  _includes = newIncludes;

                  Includes newSkipIncludes = [];
                  newSkipIncludes
                      .add(IncludeItem.cardGroup(_definedCards[8], 1));
                  newSkipIncludes
                      .add(IncludeItem.cardGroup(_definedCards[4], 1));
                  _skipIncludes = newSkipIncludes;
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
                        child: Text(
                          "Project",
                          style: textTheme.titleMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _previousFileName ?? "(No Loaded Project)",
                          style: textTheme.bodySmall,
                        ),
                      ),
                      newButton,
                      loadButton,
                      saveButton,
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
