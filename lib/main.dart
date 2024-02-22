import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:math';
import 'dart:typed_data';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ARKitController arkitController;
  late InAppWebViewController inAppWebViewController;


  final uri =  WebUri("https://read.amazon.co.jp/manga/B07QQPYZ2R?sample=true&ref_=kwl_kr_iv_rec_1");
  final List<String> paths = ["assets/book/page1.jpeg", "assets/book/page2.jpeg", "assets/book/page3.jpeg", "assets/book/page4.jpeg"];

  int pathIndex = 0;
  late ARKitNode node;
  Vector3 pos = Vector3(0, -0.1, -0.1);
  Vector3 rot = Vector3(0, -20, 0);
  Vector3 relativePosition = Vector3(-0.2, -0.1, -0.1);
  Vector3 relativeRotation = Vector3(0, -20, 0);

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  Widget _buildFloatingActionButton() {
    return GestureDetector(
      onTap: () {
        arkitController.cameraPosition().then((camPos) {
          arkitController.getCameraEulerAngles().then((camRot) {
            pos = Vector3(relativePosition.x * sin(camRot.y), relativePosition.y, relativePosition.z * cos(camRot.y)) + camPos!;
            node.position = pos;
            rot = relativeRotation + Vector3(camRot.y, 0, 0);
            node.eulerAngles = rot;
            arkitController.remove("page");
            arkitController.add(node);
          });
        });
      },
      child: Container(
        height: 54,
        width: 54,
        margin: const EdgeInsets.only(right: 17, bottom: 50),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Icon(Icons.add, size: 25),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(
            url: uri
          ),
          onWebViewCreated:(InAppWebViewController controller) {
            inAppWebViewController = controller;
          }
         // onProgressChanged: ,
        ),
        Padding(
          padding: EdgeInsets.only(right: 20, left: 20),
          child: ARKitSceneView(onARKitViewCreated: onARKitViewCreated),
        ),
      ],
    ),
    floatingActionButton: _buildFloatingActionButton(),
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
        materials: [
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
    } else {
      pathIndex += 1;
      if (pathIndex == paths.length) {
        pathIndex = 0;
      }
    }
  void _takeWebViewScreenshot() async {
  // InAppWebViewControllerからスクリーンショットを取得
    Uint8List? screenshotBytes = await inAppWebViewController.takeScreenshot();
    if (screenshotBytes != null) {
    // スクリーンショットを使用して画像を作成
    // Image image = Image.memory(screenshotBytes);

    // 画像を表示
    this.arkitController = arkitController;
    node = ARKitNode(
      geometry: ARKitPlane(
        height: 0.2,
        width: 0.2,
        materials: [
          ARKitMaterial(
            diffuse: ARKitMaterialImage(
              Uint8List.fromList(screenshotBytes).toString()
            ),
            doubleSided: true,
          ),
        ],
      ),
      name: "page",
      position: pos,
      eulerAngles: rot,
    );
    arkitController.add(node);
  } else {
    // エラー処理
    print('Failed to capture screenshot');
  }
}
    arkitController.remove("page");
    onARKitViewCreated(arkitController);
  }
}
