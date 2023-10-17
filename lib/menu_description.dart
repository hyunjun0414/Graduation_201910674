import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:menumate/vision_api.dart';
import 'package:menumate/firestore_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  DisplayPictureScreenState createState() => DisplayPictureScreenState();
}

class DisplayPictureScreenState extends State<DisplayPictureScreen> {
  String? extractedText;
  DocumentSnapshot? firestoreData;
  final bool hasAllergyInfo = true;

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
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Raleway',  // 예시 폰트; 실제로 사용하려면 폰트를 추가해야 합니다.
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 30),
                Icon(
                  Icons.photo,
                  size: 200,
                  color: Colors.teal,
                ),
                SizedBox(height: 20),
                Card(
                  elevation: 5,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          (firestoreData?.data() as Map<String, dynamic>?)?['name'] ?? 'Menu Name',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          (firestoreData?.data() as Map<String, dynamic>?)?['allergens'] ?? '알러지 정보가 없습니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          (firestoreData?.data() as Map<String, dynamic>?)?['description'] ?? 'Menu Description',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
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