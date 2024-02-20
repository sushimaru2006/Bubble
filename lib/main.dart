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
  int index = 0;
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
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        index += 1;
        arkitController.remove("page");
        onARKitViewCreated(arkitController);
      },
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
            diffuse: ARKitMaterialProperty.image(paths[index]),
            doubleSided: true,
          ),
        ],
      ),
      name: "page",
      position: Vector3(0, 0, -0.3),
    );
    arkitController.add(node);
  }
}
