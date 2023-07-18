import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'single_page.dart';

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
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 34, 255, 163)),
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
    var lrPreviewPadding = 8.0;
    var leftSide = Padding(
      padding: EdgeInsets.all(lrPreviewPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: SinglePage(Size(21, 29.7), Size(6.3, 8.8), Size(0.3, 0.3),
                Size(0.7, 0.7), 0.5, 0.02, []),
          ),
          SizedBox(height: 4),
          Text(
            "Front",
            style: textTheme.labelSmall,
          )
        ],
      ),
    );

    var dualPreviewRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: leftSide,
        ),
        Flexible(
          child: leftSide,
        ),
      ],
    );

    return Scaffold(
      body: Column(
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
            child: SizedBox(
              height: 500,
              child: Column(
                children: [
                  Expanded(
                    child: dualPreviewRow,
                  ),
                  SizedBox(
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SegmentedButton(
                            segments: [
                              ButtonSegment(value: 0, label: Text("Dual")),
                              ButtonSegment(value: 1, label: Text("Front")),
                              ButtonSegment(value: 2, label: Text("Back")),
                            ],
                            selected: {0},
                            onSelectionChanged: (p0) {},
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          // Flexible(
          //   child: SinglePage(Size(21, 29.7), Size(6.3, 8.8), Size(0.3, 0.3),
          //       Size(0.7, 0.7), 0.5, 0.02, []),
          // ),
          // OutputLayoutControl()
        ],
      ),
    );
  }
}

class OutputLayoutControl extends StatelessWidget {
  const OutputLayoutControl({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Text("Page Size"),
              SizedBox(
                width: 100,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Width",
                    suffixText: "cm",
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Height",
                    suffixText: "cm",
                  ),
                ),
              ),
            ],
          ),
          Divider()
        ],
      ),
    );
  }
}
