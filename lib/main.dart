import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:math';
import 'dart:typed_data';

void main() => runApp(MaterialApp(home: Init()));

class Init extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

      ),
      home: HomePage(key),
      routes: {
        '/kindleRoute': (context) => Kindle(key),
        '/driveRoute': (context) => GoogleDrive(key),
        '/sample': (context) => Sample(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage(Key? key) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR PageView'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/kindleRoute');
              },
              child: const Text('kindle'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/driveRoute');
              },
              child: const Text('googledrive'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/sample');
              },
              child: const Text('sample'))
          ],
        ),
      ),
    );
  }
}

class Kindle extends StatefulWidget {
  const Kindle(Key? key) : super(key: key);

  @override
  _KindleState createState() => _KindleState();
}


class _KindleState extends State<Kindle> {
  late InAppWebViewController inAppWebViewController;
  final uri = WebUri("https://read.amazon.co.jp/kindle-library");
  String currentUrl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('kindle'),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: uri),
        onLoadStop: (controller, url) {
          setState(() {
            currentUrl = url.toString();
          });
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AR(currentUrl: currentUrl),
              ),
            );
          },
          child: const Text('AR mode'),
        ),
      ),
    );
  }
}

class GoogleDrive extends StatefulWidget {
  const GoogleDrive(Key? key) : super(key: key);

  @override
  _GoogleDriveState createState() => _GoogleDriveState();
}

class _GoogleDriveState extends State<GoogleDrive> {
  late InAppWebViewController inAppWebViewController;
  final uri = WebUri("https://drive.google.com/drive/u/0/home");
  String currentUrl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GoogleDrive'),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: uri),
        onLoadStop: (controller, url) {
          setState(() {
            currentUrl = url.toString();
          });
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AR(currentUrl: currentUrl),
              ),
            );
          },
          child: const Text('AR mode'),
        ),
      ),
    );
  }
}
class AR extends StatefulWidget {
  final String currentUrl;

  const AR({Key? key, required this.currentUrl}) : super(key: key);
  @override
  _ARState createState() => _ARState();
}

class _ARState extends State<AR> {
  late ARKitController arkitController;
  late InAppWebViewController inAppWebViewController;
  String currentUrl = '';

  late final uri =  WebUri(currentUrl);
  final List<String> paths = ["assets/book/page1.jpeg", "assets/book/page2.jpeg", "assets/book/page3.jpeg", "assets/book/page4.jpeg"];

  int pathIndex = 0;
  late ARKitNode node;

  // Nodeの位置と回転
  Vector3 pos = Vector3(0, -0.15, -0.15);
  Vector3 rot = Vector3(0, -20, 0);

  // カメラの位置からの相対的な位置と回転
  Vector3 relativePosition = Vector3(-0.15, -0.15, -0.15);
  Vector3 relativeRotation = Vector3(0, -20, 0);

  // スライダーの値
  double sliderValue = -20;

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    currentUrl = widget.currentUrl;
  }

  Widget _buildFloatingActionButton() {
    return GestureDetector(
      onTap: () {
        arkitController.cameraPosition().then((camPos) {
          arkitController.getCameraEulerAngles().then((camRot) {
            pos = Vector3(relativePosition.x * sin(camRot.y), relativePosition.y, relativePosition.z * cos(camRot.y)) + camPos!;
            rot = relativeRotation + Vector3(camRot.y, 0, 0);
            arkitController.remove("page");
            _takeWebViewScreenshot();
          });
        });
      },
      child: Container(
        height: 2000,
        width: 54,
        margin: const EdgeInsets.only(right: 50, bottom: 50),
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
          padding: const EdgeInsets.only(top: 109),
          child: ARKitSceneView(onARKitViewCreated: onARKitViewCreated),
        ),
        _buildFloatingActionButton(),
        Positioned(
          top: 70,
          right: 10,
          child: RotatedBox(
            quarterTurns: 3,
            child: Slider(
              value: sliderValue,
              min: -21,
              max: -19,
              onChanged: (value) {
                setState(() {
                  sliderValue = value;
                });
                relativeRotation.y = value;
                rot = Vector3(rot.x, value, rot.z);
                node.eulerAngles = rot;
                arkitController.remove("page");
                arkitController.add(node);
              },
            ),
          )
        )
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
      Navigator.pop(context);
      },
      child: const Icon(Icons.arrow_back),

    ),
  );

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    _takeWebViewScreenshot();
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
  }

  void _takeWebViewScreenshot() async {
  // InAppWebViewControllerからスクリーンショットを取得
    Uint8List? screenshotBytes = await inAppWebViewController.takeScreenshot();
    if (screenshotBytes != null) {
      // 画像を表示
      arkitController = arkitController;
      node = ARKitNode(
        geometry: ARKitPlane(
          height: 0.37,
          width: 0.18,
          materials: [
            ARKitMaterial(
              diffuse: ARKitMaterialProperty.image(
                base64Encode(screenshotBytes)
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
      // エラー処理
      // print('Failed to capture screenshot');
    }
  }
}

class Sample extends StatefulWidget {
  @override
  _SampleState createState() => _SampleState();
}

class _SampleState extends State<Sample> {
  // arkitのコントローラー
  late ARKitController arkitController;

  // 画像のパス
  final List<String> paths = ["assets/book/page1.jpeg", "assets/book/page2.jpeg", "assets/book/page3.jpeg", "assets/book/page4.jpeg"];
  // 画像パスのインデックス
  int pathIndex = 0;

  // arNode
  late ARKitNode node;

  // Nodeの位置と回転
  Vector3 pos = Vector3(0, -0.12, -0.12);
  Vector3 rot = Vector3(0, -20, 0);

  // カメラの位置からの相対的な位置と回転
  Vector3 relativePosition = Vector3(-0.12, -0.12, -0.12);
  Vector3 relativeRotation = Vector3(0, -20, 0);

  // スライダーの値
  double sliderValue = -20;

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        Container(
          // ARのScene
          child: ARKitSceneView(onARKitViewCreated: onARKitViewCreated),
        ),
        // 上にスライダーを重ねる
        Positioned(
          top: 50,
          left: 50,
          child: RotatedBox(
            quarterTurns: 3,
            child: Slider(
              value: sliderValue,
              min: -21,
              max: -19,
              onChanged: (value) {
                setState(() {
                  sliderValue = value;
                });
                relativeRotation.y = value;
                rot = Vector3(rot.x, value, rot.z);
                node.eulerAngles = rot;
                arkitController.remove("page");
                arkitController.add(node);
              },
            ),
          )
        )
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        // カメラの座標を取得
        arkitController.cameraPosition().then((camPos) {
          // カメラの回転を取得
          arkitController.getCameraEulerAngles().then((camRot) {
            // nodeの場所を計算。自分の周囲0.2の円周上を動かす
            pos = Vector3(relativePosition.x * sin(camRot.y), relativePosition.y, relativePosition.z * cos(camRot.y)) + camPos!;
            node.position = pos;

            // nodeの向きを変更
            rot = relativeRotation + Vector3(camRot.y, 0, 0);
            node.eulerAngles = rot;

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

  void onARKitViewCreated(ARKitController arkitController) async {
    this.arkitController = arkitController;
    node = ARKitNode(
      geometry: ARKitPlane(
        height: 0.2,
        width: 0.2,
        materials : [
          ARKitMaterial(
            diffuse: ARKitMaterialProperty.image(paths[pathIndex]),
            // diffuse: ARKitMaterialProperty.image("https://picsum.photos/250?image=9"),
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

