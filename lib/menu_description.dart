import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:menumate/firestore_data.dart';
import 'package:url_launcher/url_launcher.dart';

class DescriptionPage extends StatefulWidget {
  final String imagePath;
  final String extractedText;

  const DescriptionPage(
      {super.key, required this.imagePath, required this.extractedText});

  @override
  DescriptionPageState createState() => DescriptionPageState();
}

class DescriptionPageState extends State<DescriptionPage> {
  String? extractedText;
  List<DocumentSnapshot> firestoreData = [];
  List<String> notFoundTexts = []; // Firestore에서 찾지 못한 텍스트를 저장하는 리스트
  bool isLoading = true; // 로딩 상태를 true로 초기화합니다.

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  _processImage() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    extractedText = widget.extractedText;

    if (extractedText != null) {
      final firestoreService = FirestoreService();
      List<String> words = extractedText!.split(RegExp(r'\s+'));
      List<String> foundWords = [];

      for (String word in words) {
        if (word.isNotEmpty) {
          var data = await firestoreService.fetchDataBasedOnWords(word);
          if (data != null) {
            firestoreData.add(data);
            foundWords.add(word);
          }
        }
      }

      notFoundTexts = words.toSet().difference(foundWords.toSet()).toList();
    }
    if (!mounted) return;
    setState(() {
      isLoading = false;
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
    if (firestoreData.isEmpty) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xffCDF5F9),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 100,),
                // 버튼과 텍스트 사이의 간격
                Text(
                  "There are no matching data. Click the button to let the developer know",
                  textAlign: TextAlign.center,style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                ),
                SizedBox(height: 80),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey
                  ),
                  onPressed: _saveRemainingTexts,
                  child: Text("inform the developer"),
                ),
                SizedBox(height: 150),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // 현재 화면을 닫고 이전 화면으로 돌아갑니다.
                  },
                  child: Text('Return to previous screen'),
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
        backgroundColor: Colors.white60,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var data in firestoreData) _buildItemWidget(data),
                if (notFoundTexts.isNotEmpty) _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveRemainingTexts,
      child: Text(
        "There are also foods that cannot be found. Click the button to leave feedback to the developers",
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildItemWidget(DocumentSnapshot data) {
    var itemData = data.data() as Map<String, dynamic>;
    var imageUrl = itemData['imageUrl'] ??
        'https://cdn-icons-png.flaticon.com/512/1996/1996055.png';
    return Card(
      elevation: 4.0, // 카드의 그림자 깊이
      margin: EdgeInsets.all(8.0), // 카드 주변의 여백
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // 카드의 모서리 둥글게
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0), // 카드 내부의 패딩
        child: Column(
          children: [
            // Firebase Storage에서 이미지를 불러와서 표시
            FutureBuilder(
              future: _loadImage(imageUrl),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Image.network(snapshot.data as String);
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            SizedBox(height: 5),
            Text(
              itemData['name'] ?? 'MenuName',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              itemData['allergens'] ?? 'No allergens',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            Text(
              itemData['description'] ?? 'description',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

// Firebase Storage에서 이미지 URL을 불러오는 함수
  Future<String> _loadImage(String imagePath) async {
    try {
      if (imagePath.startsWith('gs://')) {
        return await FirebaseStorage.instance
            .refFromURL(imagePath)
            .getDownloadURL();
      }
      // Firebase Storage URL이 아닌 경우 기본 이미지 URL을 반환
      return 'https://cdn-icons-png.flaticon.com/512/1996/1996055.png'; // 여기에 적절한 기본 이미지 URL을 설정하세요.
    } catch (e) {
      print("Error loading image: $e");
      // 오류가 발생한 경우에도 기본 이미지 URL을 반환
      return 'https://cdn-icons-png.flaticon.com/512/1996/1996055.png'; // 여기에 적절한 기본 이미지 URL을 설정하세요.
    }
  }

  void _requestFeedback() async {
    // Firestore에 추출된 텍스트 저장
    final firestoreService = FirestoreService();
    await firestoreService.saveExtractedText(extractedText!);
  }

  void _saveRemainingTexts() async {
    // 기존 기능 실행
    String remainingTexts =
        notFoundTexts.join(" ").replaceAll(RegExp(r'\d+'), '').trim();
    if (remainingTexts.isNotEmpty) {
      final firestoreService = FirestoreService();
      await firestoreService.saveExtractedText(remainingTexts);
    }

    // 알림창 표시 함수 호출
    _showAlert();
  }

  void _showAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Thank you"),
          content: Text("Your feedback has been sent to the developers."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // 대화 상자를 닫습니다.
              },
            ),
          ],
        );
      },
    );
  }
}
