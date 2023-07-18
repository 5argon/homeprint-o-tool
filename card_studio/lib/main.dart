import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'page/layout/layout_page.dart';

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

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            SizedBox(
              width: 200,
              child: NavigationDrawer(selectedIndex: 3, children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Project",
                    style: textTheme.titleMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton(onPressed: () {}, child: Text("Load")),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton(onPressed: () {}, child: Text("Save")),
                ),
                NavigationDrawerDestination(
                    icon: Icon(Icons.widgets_outlined),
                    label: Text("Instance")),
                NavigationDrawerDestination(
                    icon: Icon(Icons.widgets_outlined), label: Text("Card")),
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
                    icon: Icon(Icons.widgets_outlined), label: Text("Include")),
                NavigationDrawerDestination(
                    icon: Icon(Icons.widgets_outlined), label: Text("Layout")),
                NavigationDrawerDestination(
                    icon: Icon(Icons.widgets_outlined), label: Text("Preview")),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                      OutlinedButton(onPressed: () {}, child: Text("Export")),
                ),
              ]),
            ),
            Expanded(child: LayoutPage()),
          ],
        ),
      ),
    );
  }
}
