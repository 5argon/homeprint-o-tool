import 'package:flutter/material.dart';

class OutputLayoutControl extends StatelessWidget {
  const OutputLayoutControl({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container();
    // return DefaultTabController(
    //   initialIndex: 1,
    //   length: 3,
    //   child: Scaffold(
    //     appBar: AppBar(
    //       title: const Text('TabBar Sample'),
    //       bottom: const TabBar(
    //         tabs: <Widget>[
    //           Tab(
    //             icon: Icon(Icons.cloud_outlined),
    //           ),
    //           Tab(
    //             icon: Icon(Icons.beach_access_sharp),
    //           ),
    //           Tab(
    //             icon: Icon(Icons.brightness_5_sharp),
    //           ),
    //         ],
    //       ),
    //     ),
    //     body: const TabBarView(
    //       children: <Widget>[
    //         Center(
    //           child: Text("It's cloudy here"),
    //         ),
    //         Center(
    //           child: Text("It's rainy here"),
    //         ),
    //         Center(
    //           child: Text("It's sunny here"),
    //         ),
    //       ],
    //     ),
    //   ),
    // );

    // return Padding(
    //   padding: const EdgeInsets.all(16.0),
    //   child: Column(
    //     children: [
    //       Row(
    //         children: [
    //           Text("Page Size"),
    //           SizedBox(
    //             width: 100,
    //             child: TextFormField(
    //               decoration: InputDecoration(
    //                 labelText: "Width",
    //                 suffixText: "cm",
    //               ),
    //             ),
    //           ),
    //           SizedBox(
    //             width: 100,
    //             child: TextFormField(
    //               decoration: InputDecoration(
    //                 labelText: "Height",
    //                 suffixText: "cm",
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //       Divider()
    //     ],
    //   ),
    // );
  }
}
