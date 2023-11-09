import 'package:cloud_firestore/cloud_firestore.dart';
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
  final bool hasAllergyInfo = true; // 알러지 정보가 있는지 여부를 나타내는 변수
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

      for (String word in words) {
        if (word.isNotEmpty) {
          var data = await firestoreService.fetchDataBasedOnWords(word);
          if (data != null) {
            firestoreData.add(data);
          }
        }
      }
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
                for (var data in firestoreData) _buildItemWidget(data),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemWidget(DocumentSnapshot data) {
    var itemData = data.data() as Map<String, dynamic>;
    return Column(
      children: [
        Icon(Icons.restaurant, size: 200, color: Colors.black38),
        SizedBox(height: 5),
        Text(
          itemData['name'] ?? 'MenuName',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          itemData['allergens'] ?? 'allergens',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          itemData['description'] ?? 'description',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
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
