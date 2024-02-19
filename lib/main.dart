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

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('ARKit in Flutter')),
      body: ARKitSceneView(onARKitViewCreated: onARKitViewCreated));

  void onARKitViewCreated(ARKitController arkitController) {
    setState(() {
      this.arkitController = arkitController;
    });
    // final node = ARKitNode(
    //   geometry: ARKitSphere(
    //     materials: [
    //       ARKitMaterial(
    //         diffuse: ARKitMaterialProperty.image("assets/NCG255-scaled.jpg"),
    //         doubleSided: true,
    //       ),
    //     ],
    //     radius: 1
    //   ),
    //   position: Vector3(0, 0, 0),
    // );
    final node = ARKitNode(
      geometry: ARKitPlane(
        height: 0.5,
        width: 0.5,
        materials : [
          ARKitMaterial(
            diffuse: ARKitMaterialProperty.image("assets/NCG255-scaled.jpg"),
            doubleSided: true,
          ),
        ],
      ),
      position: Vector3(0, 0, 0.5),
    );
    arkitController.add(node);
  }
}
