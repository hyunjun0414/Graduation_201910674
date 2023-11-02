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
    if (firestoreData == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xffCDF5F9),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("일치하는 데이터가 없습니다. 피드백을 제공해주시면 감사하겠습니다!"),
                SizedBox(height: 50,),
                ElevatedButton(
                  onPressed: _requestFeedback,
                  child: Text("피드백 제공"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 일치하는 데이터가 있는 경우의 기존 UI 반환
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xffCDF5F9),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 30),
                Icon(
                  Icons.restaurant,
                  size: 200,
                  color: Colors.black38,
                ),
                SizedBox(height: 5),
                Text(
                  (firestoreData?.data() as Map<String, dynamic>?)?['name'] ?? 'MenuName',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 17),
                Text(
                  (firestoreData?.data() as Map<String, dynamic>?)?['allergens'] ?? '알러지가 없습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 17),
                Text(
                  (firestoreData?.data() as Map<String, dynamic>?)?['description'] ?? 'MenuName',
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
      ),
    );
  }

  void _requestFeedback() {
    // 피드백을 받는 코드 (예: 알림창 또는 다른 페이지로 이동)
  }
}
