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
    Widget aspectRatioBox =
        AspectRatio(aspectRatio: 16 / 9, child: Container(color: Colors.green));
    Widget render = Container(
      height: 500,
      color: Colors.red,
      child: Row(children: [
        Expanded(
            child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Container(color: Colors.yellow, child: aspectRatioBox),
        )),
        Expanded(
            child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Container(color: Colors.yellow, child: aspectRatioBox),
        )),
      ]),
    );
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 500,
            color: Colors.red,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.all(lrPreviewPadding),
                          child: SinglePage(Size(21, 29.7), Size(6.3, 8.8),
                              Size(0.3, 0.3), Size(0.7, 0.7), 0.5, 0.02, []),
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.all(lrPreviewPadding),
                          child: SinglePage(Size(21, 29.7), Size(6.3, 8.8),
                              Size(0.3, 0.3), Size(0.7, 0.7), 0.5, 0.02, []),
                        ),
                      ),
                    ],
                  ),
                ),
                // Expanded(
                //     child: Row(
                //   children: [
                //     Expanded(
                //       child: Padding(
                //         padding: EdgeInsets.all(lrPreviewPadding),
                //         child: SinglePage(Size(21, 29.7), Size(6.3, 8.8),
                //             Size(0.3, 0.3), Size(0.7, 0.7), 0.5, 0.02, []),
                //       ),
                //       //     child: Padding(
                //       //   padding: EdgeInsets.all(lrPreviewPadding),
                //       //   child: SinglePage(Size(21, 29.7), Size(6.3, 8.8),
                //       //       Size(0.3, 0.3), Size(0.7, 0.7), 0.5, 0.02, []),
                //       // )
                //     ),
                //     Expanded(
                //         child: Padding(
                //       padding: EdgeInsets.all(lrPreviewPadding),
                //       child: SinglePage(Size(21, 29.7), Size(6.3, 8.8),
                //           Size(0.3, 0.3), Size(0.7, 0.7), 0.5, 0.02, []),
                //     )),
                //   ],
                // )),
                Container(
                  height: 16,
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(
                        "Front",
                        style: textTheme.labelSmall,
                        textAlign: TextAlign.center,
                      )),
                      Expanded(
                          child: Text(
                        "Back",
                        style: textTheme.labelSmall,
                        textAlign: TextAlign.center,
                      )),
                    ],
                  ),
                ),
                Container(
                  height: 24,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          child: Text("Dual"),
                        ),
                        SizedBox(width: 4),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text("Front"),
                        ),
                        SizedBox(width: 4),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text("Back"),
                        ),
                        SizedBox(width: 4),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text("Mark"),
                        ),
                      ],
                    ),
                  ),
                )
              ],
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
