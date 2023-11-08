import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:menumate/vision_api.dart';
import 'package:menumate/firestore_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool isLoading = true; // 로딩 상태를 true로 초기화합니다.

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  _processImage() async {
    setState(() {
      isLoading = true; // 이미지 처리 시작 시 로딩 상태를 true로 설정합니다.
    });

    String? apiKey = dotenv.env['APP_KEY'];
    extractedText = await extractTextFromImage(widget.imagePath, apiKey!);

    if (extractedText != null) {
      final firestoreService = FirestoreService();
      firestoreData =
          await firestoreService.fetchDataBasedOnText(extractedText!);
    }

    setState(() {
      isLoading = false; // 이미지 처리 완료 시 로딩 상태를 false로 설정합니다.
    });
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 상태일 때 로딩 인디케이터를 보여줍니다.
    if (isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xffCDF5F9),
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // 로딩이 끝났지만 데이터가 없을 때의 화면을 보여줍니다.
    if (firestoreData == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xffCDF5F9),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("죄송합니다 일치하는 데이터가 없습니다. 아래 버튼을 누르면 chrome에서 검색해 드릴게요"),
                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: _requestFeedback,
                  child: Text("chrome 브라우저에서 검색"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 데이터가 있을 때의 화면을 보여줍니다.
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
                  (firestoreData?.data() as Map<String, dynamic>?)?['name'] ??
                      'MenuName',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 17),
                Text(
                  (firestoreData?.data()
                          as Map<String, dynamic>?)?['allergens'] ??
                      '알러지가 없습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 17),
                Text(
                  (firestoreData?.data()
                          as Map<String, dynamic>?)?['description'] ??
                      'MenuName',
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

  void _requestFeedback() async {
    // Firestore에 추출된 텍스트 저장
    final firestoreService = FirestoreService();
    await firestoreService.saveExtractedText(extractedText!);

    // 크롬에서 추출된 텍스트로 검색
    String searchUrl = "https://www.google.com/search?q=$extractedText";
    if (await canLaunchUrl(Uri.parse(searchUrl))) {
      await launchUrl(Uri.parse(searchUrl));
    } else {
      throw 'Could not launch $searchUrl';
    }
  }
}
