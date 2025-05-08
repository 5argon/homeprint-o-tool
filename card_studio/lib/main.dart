import 'package:file_selector/file_selector.dart';
import 'package:homeprint_o_tool/core/card.dart';
import 'package:homeprint_o_tool/core/layout_const.dart';
import 'package:homeprint_o_tool/page/about/about_page.dart';
import 'package:homeprint_o_tool/page/picks/picks_page.dart';
import 'package:homeprint_o_tool/page/linked_card_face/linked_card_face_page.dart';
import 'package:homeprint_o_tool/page/layout/back_strategy.dart';
import 'package:homeprint_o_tool/page/project/project_page.dart';
import 'package:homeprint_o_tool/page/review/review_page.dart';
import 'package:flutter/material.dart';
import 'package:homeprint_o_tool/page/sidebar/sidebar.dart';
import 'package:homeprint_o_tool/theme.dart';
import 'package:provider/provider.dart';

import 'core/page_preview/render.dart';
import 'core/project_settings.dart';
import 'core/save_file.dart';
import 'page/card/card_page.dart';
import 'page/picks/include_data.dart';
import 'page/layout/layout_page.dart';
import 'page/layout/layout_struct.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MaterialTheme();
    return ChangeNotifierProvider(
      create: (BuildContext context) {},
      child: MaterialApp(
        title: 'Homeprint O\' Tool',
        themeMode: ThemeMode.system,
        theme: theme.light(),
        darkTheme: theme.dark(),
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
  paperSize: SizePhysical(21, 29.7, PhysicalSizeType.centimeter),
  marginSize: SizePhysical(0.25, 0.25, PhysicalSizeType.inch),
  edgeCutGuideSize: SizePhysical(0.5, 0.5, PhysicalSizeType.centimeter),
  backArrangement: BackArrangement.invertedRow,
  skips: [],
  removeOneColumn: false,
  removeOneRow: false,
  frontPostRotation: Rotation.none,
  backPostRotation: Rotation.none,
);

var defaultProjectSettings = ProjectSettings(
    SizePhysical(6.15, 8.8, PhysicalSizeType.centimeter),
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
  LinkedCardFaces _linkedCardFaces = [];

  /// Not stored in the save file.
  Includes _includes = [];
  Includes _skipIncludes = [];
  LayoutData _layoutData = defaultLayoutData;
  bool _hasChanges = false;

  Future? fullScreenDisableFuture;
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

          final baseDirectory = _baseDirectory;
          if (baseDirectory == null) {
            return needProjectLoaded;
          }

          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.waiting:
              return loadingPage;
            default:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              switch (_selectedIndex) {
                case 0:
                  // Pass baseDirectory directly to ProjectPage instead of through Navigator
                  return ProjectPage(
                    projectSettings: _projectSettings,
                    onProjectSettingsChanged: (projectSettings) {
                      setState(() {
                        _projectSettings = projectSettings;
                      });
                    },
                    baseDirectory: baseDirectory,
                  );
                case 1:
                  {
                    var linkedCardFacePage = LinkedCardFacePage(
                      basePath: baseDirectory,
                      projectSettings: _projectSettings,
                      linkedCardFaces: _linkedCardFaces,
                      definedCards: _definedCards,
                      onDefinedCardsChange: (definedCards) {
                        setState(() {
                          _definedCards = definedCards;
                        });
                      },
                      onLinkedCardFacesChange: (linkedCardFaces) {
                        setState(() {
                          _linkedCardFaces = linkedCardFaces;
                        });
                      },
                    );
                    return linkedCardFacePage;
                  }
                case 2:
                  final baseDirectory = _baseDirectory;
                  if (baseDirectory == null) {
                    return needProjectLoaded;
                  }
                  var cardPage = CardPage(
                    basePath: baseDirectory,
                    projectSettings: _projectSettings,
                    definedCards: _definedCards,
                    linkedCardFaces: _linkedCardFaces,
                    includes: _includes,
                    skipIncludes: _skipIncludes,
                    onIncludesChanged: (includes) {
                      setState(() {
                        _includes = includes;
                      });
                    },
                    onSkipIncludesChanged: (skipIncludes) {
                      setState(() {
                        _skipIncludes = skipIncludes;
                      });
                    },
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
                  var picksPage = PicksPage(
                    basePath: baseDirectory,
                    projectSettings: _projectSettings,
                    layoutData: _layoutData,
                    definedCards: _definedCards,
                    linkedCardFaces: _linkedCardFaces,
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
                  return picksPage;
                case 5:
                  final baseDirectory = _baseDirectory;
                  if (baseDirectory != null) {
                    var reviewPage = ReviewPage(
                      layoutData: _layoutData,
                      projectSettings: _projectSettings,
                      includes: _includes,
                      skipIncludes: _skipIncludes,
                      baseDirectory: baseDirectory,
                      linkedCardFaces: _linkedCardFaces,
                    );
                    return reviewPage;
                  }
                  return Text("Need base directory to render cards.");
                case 6:
                  return AboutPage();
                default:
                  return wipPage;
              }
          }
        },
        future: fullScreenDisableFuture);

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

    onNew() async {
      final filePathFuture = getSaveLocation(
        acceptedTypeGroups: [jsonType],
        initialDirectory: _baseDirectory,
        suggestedName: "project.json",
      );
      setState(() {
        fullScreenDisableFuture = filePathFuture;
      });
      final filePath = await filePathFuture;
      if (filePath != null) {
        // Append .json if not already.
        final filePathJson =
            !filePath.path.endsWith(".json") ? "$filePath.json" : filePath.path;
        final saveFile =
            SaveFile(_projectSettings, _linkedCardFaces, _definedCards);
        final saveResult = await saveFile.saveToFile(filePathJson);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Created a new project. Base directory is now : ${saveResult.baseDirectory}"),
        ));
        setState(() {
          _projectSettings = defaultProjectSettings;
          _definedCards = defaultDefinedCards;
          _linkedCardFaces = [];
          _baseDirectory = saveResult.baseDirectory;
          _previousFileName = saveResult.fileName;
          _includes = [];
        });
      }
    }

    onLoad() {
      final fut = SaveFile.loadFromFilePicker().then((loadResult) {
        if (loadResult != null) {
          setState(() {
            _selectedIndex = 2;
            _projectSettings = loadResult.saveFile.projectSettings;
            _definedCards = loadResult.saveFile.cardGroups;
            _linkedCardFaces = loadResult.saveFile.linkedCardFaces;
            _baseDirectory = loadResult.basePath;
            _previousFileName = loadResult.fileName;
            _includes = [];
            _skipIncludes = [];
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Loaded a project JSON. Base directory is now : ${loadResult.basePath}"),
          ));
        }
      });
      setState(() {
        fullScreenDisableFuture = fut;
      });
    }

    onSave() async {
      final filePathFuture = getSaveLocation(
        acceptedTypeGroups: [jsonType],
        initialDirectory: _baseDirectory,
        suggestedName: _previousFileName,
      );
      final filePath = await filePathFuture;
      if (filePath != null) {
        final saveFile =
            SaveFile(_projectSettings, _linkedCardFaces, _definedCards);
        final saveResult = await saveFile.saveToFile(filePath.path);
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
    }

    onExport() async {
      final baseDirectory = _baseDirectory;
      if (baseDirectory != null) {
        final flutterView = View.of(context);
        if (context.mounted) {
          final renderingFuture = renderRender(
              context,
              flutterView,
              _projectSettings,
              _layoutData,
              _includes,
              _skipIncludes,
              baseDirectory,
              _linkedCardFaces, (currentPage) {
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
    }

    final sidebarSelectedIndex = _baseDirectory == null
        ? -1
        : _selectedIndex; // Disable sidebar when no base directory.

    return Builder(builder: (context) {
      final sidebar = Sidebar(
        selectedIndex: sidebarSelectedIndex,
        onSelectedIndexChanged: (i) => setState(() {
          _selectedIndex = i;
        }),
        baseDirectory: _baseDirectory,
        previousFileName: _previousFileName,
        hasChanges: _hasChanges,
        onNew: onNew,
        onLoad: onLoad,
        onSave: onSave,
        onExport: onExport,
        fullScreenDisableFuture: fullScreenDisableFuture,
        includes: _includes,
        linkedCardFaces: _linkedCardFaces,
        definedCards: _definedCards,
      );
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              sidebar,
              Expanded(child: rendering),
            ],
          ),
        ),
      );
    });
  }
}
