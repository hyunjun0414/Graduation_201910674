import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:menumate/vision_api.dart';
import 'package:menumate/firestore_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  String? extractedText;
  DocumentSnapshot? firestoreData;
  final bool hasAllergyInfo = true; // 알러지 정보가 있는지 여부를 나타내는 변수
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
      firestoreData =
          await firestoreService.fetchDataBasedOnText(extractedText!);
      setState(() {}); // 상태 업데이트
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.lightBlueAccent,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 30),
                Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.white,
                ),
                SizedBox(height: 5),
                Text(
                  (firestoreData?.data() as Map<String, dynamic>?)?['name'] ?? 'MenuName',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  (firestoreData?.data() as Map<String, dynamic>?)?['allergens'] ?? '알러지가 없습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  (firestoreData?.data() as Map<String, dynamic>?)?['description'] ?? 'MenuName',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
