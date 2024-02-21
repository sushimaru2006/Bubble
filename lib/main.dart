import 'dart:async';
import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:math';


void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // arkitのコントローラー
  late ARKitController arkitController;

  final controller = Completer<WebViewController>();

  // 画像のパス
  final List<String> paths = ["assets/book/page1.jpeg", "assets/book/page2.jpeg", "assets/book/page3.jpeg", "assets/book/page4.jpeg"];
  // 画像パスのインデックス
  int pathIndex = 0;

  // arNode
  late ARKitNode node;

  // Nodeの位置と回転
  Vector3 pos = Vector3(0, -0.2, -0.2);
  Vector3 rot = Vector3(0, 30, 0);

  // カメラの位置からの相対的な位置と回転
  Vector3 relativePosition = Vector3(-0.2, -0.2, -0.2);

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
        arkitController.cameraPosition().then((camPos) {
          arkitController.getCameraEulerAngles().then((camRot) {
            pos = Vector3(relativePosition.x * sin(camRot.y), relativePosition.y, relativePosition.z * cos(camRot.y)) + camPos!;
            node.position = pos;
            arkitController.remove("page");
            arkitController.add(node);
          });
        });
      },
    ),
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
    this.arkitController = arkitController;
    node = ARKitNode(
      geometry: ARKitPlane(
        height: 0.2,
        width: 0.2,
        materials : [
          ARKitMaterial(
            diffuse: ARKitMaterialProperty.image(paths[pathIndex]),
            doubleSided: true,
          ),
        ],
      ),
      name: "page",
      position: pos,
      eulerAngles: rot,
    );
    arkitController.add(node);
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      pathIndex -= 1;
      if (pathIndex < 0) {
        pathIndex = paths.length - 1;
      }
    }
    else {
      pathIndex += 1;
      if (pathIndex == paths.length) {
        pathIndex = 0;
      }
    }
    arkitController.remove("page");
    onARKitViewCreated(arkitController);
  }
}
