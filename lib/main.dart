import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'menu_description.dart';
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
        home: MyApp(
          camera: firstCamera,
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  } catch (error) {
    print("Error initializing the app: $error");
  }
}

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
      appBar: AppBar(title: const Text('Take a photo of the menu',
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
      ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          FloatingActionButton(
            onPressed: () async {
              try {
                await _initializeControllerFuture;
                await _controller.takePicture();
                await Navigator.of(context).push(MaterialPageRoute(builder: (context) => MenuDescriptionScreen()));
              } catch (e) {
                print(e);
              }
            },
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }
}
