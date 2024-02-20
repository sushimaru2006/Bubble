import 'dart:async';
import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ARKitController arkitController;
  final controller = Completer<WebViewController>();
  final List<String> paths = ["assets/book/page1.jpeg", "assets/book/page2.jpeg", "assets/book/page3.jpeg", "assets/book/page4.jpeg"];
  int path_index = 0;
  String sample = "Not tapped.";

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('ARKit in Flutter')),
    body: ARKitSceneView(onARKitViewCreated: onARKitViewCreated),
    // floatingActionButton: FloatingActionButton(
    //   onPressed: () {
    //     index += 1;
    //     if (index == paths.length){
    //       index = 0;
    //     }
    //     arkitController.remove("page");
    //     onARKitViewCreated(arkitController);
    //   },
    // ),
    bottomNavigationBar: BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.arrow_back),
          label: 'Back',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.arrow_forward),
          label: 'Next',
        ),
      ],
      onTap: _onItemTapped,
    ),
  );

  void onARKitViewCreated(ARKitController arkitController) {
    setState(() {
      this.arkitController = arkitController;
    });
    ARKitNode node = ARKitNode(
      geometry: ARKitPlane(
        height: 0.3,
        width: 0.3,
        materials : [
          ARKitMaterial(
            diffuse: ARKitMaterialProperty.image(paths[path_index]),
            doubleSided: true,
          ),
        ],
      ),
      name: "page",
      position: Vector3(0, 0, -0.3),
    );
    arkitController.add(node);
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      path_index -= 1;
      if (path_index < 0) {
        path_index = paths.length - 1;
      }
    }
    else {
      path_index += 1;
      if (index == paths.length) {
        path_index = 0;
      }
    }
    arkitController.remove("page");
    onARKitViewCreated(arkitController);
  }
}
