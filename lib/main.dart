import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:camera/camera.dart';
import 'package:menumate/vision_api.dart';
import 'package:menumate/firestore_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(
      MaterialApp(
        theme: ThemeData.dark(),
        home: MyApp(
          camera: firstCamera,
        ),
      ),
    );
  } catch (error) {
    print("Error initializing the app: $error");
  }
}

// --------------------------------
// 카메라 화면
class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // 카메라 관리하는 컨트롤러 생성
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: Column(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // 미리보기
                return CameraPreview(_controller);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
      // 버튼 누를 시 카메라 화면의 캡쳐본을 보여주는 화면으로 이동
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            // 현재 카메라 화면 캡쳐
            final image = await _controller.takePicture();

            if (!mounted) return;

            // 사진 보여주기
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// --------------------------------
// 찍은 사진 보여주는 위젯
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  DisplayPictureScreenState createState() => DisplayPictureScreenState();
}

class DisplayPictureScreenState extends State<DisplayPictureScreen> {
  String? extractedText;
  DocumentSnapshot? firestoreData;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  _processImage() async {
    String? apiKey = dotenv.env['APP_KEY'];

    extractedText = await extractTextFromImage(widget.imagePath, apiKey!);

    if (extractedText != null) {
      final firestoreService = FirestoreService();
      firestoreData = await firestoreService.fetchDataBasedOnText(extractedText!);
      setState(() {}); // Update the state
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu description')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.file(File(widget.imagePath)),
            if (extractedText != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(extractedText!),
              ),
            if (firestoreData != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Firestore Data: ${firestoreData!.data()}'),
              ),
          ],
        ),
      ),
    );
  }
}