import 'package:card_studio/page/review/review_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/project_settings.dart';
import 'core/save_file.dart';
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

var sampleLayoutData = LayoutData(
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

var sampleProjectSettings = ProjectSettings(
    "",
    SizePhysical(6.3, 8.15, PhysicalSizeType.centimeter),
    SynthesizedBleed.mirror);

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 4;
  @override
  initState() {
    super.initState();
    var initLoad = SaveFile.loadFromPath(
        "/Users/5argon/Desktop/TabooPrintProject/test.json");
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    var layoutPage = LayoutPage(
      layoutData: sampleLayoutData,
      projectSettings: sampleProjectSettings,
    );

    var reviewPage = ReviewPage(
      layoutData: sampleLayoutData,
      projectSettings: sampleProjectSettings,
    );

    Widget visiblePage;
    switch (_selectedIndex) {
      case 4:
        visiblePage = layoutPage;
        break;
      case 5:
        visiblePage = reviewPage;
        break;
      default:
        visiblePage = layoutPage;
    }

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
                      child:
                          OutlinedButton(onPressed: () {}, child: Text("Load")),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                          OutlinedButton(onPressed: () {}, child: Text("Save")),
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
                          onPressed: () {}, child: Text("Export")),
                    ),
                  ]),
            ),
            Expanded(child: visiblePage),
          ],
        ),
      ),
    );
  }
}
