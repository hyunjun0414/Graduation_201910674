import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:menumate/firestore_data.dart';

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
  Map<String, Map<String, String>> translatedData = {};
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
    final firestoreService = FirestoreService();

    if (extractedText != null) {
      List<String> words = extractedText!.split(RegExp(r'\s+'));
      List<String> foundWords = [];

      for (String word in words) {
        if (word.isNotEmpty) {
          var doc = await firestoreService.fetchDataBasedOnWords(word);
          if (doc != null) {
            firestoreData.add(doc);
            foundWords.add(word);
            //firestore 에서 가져온 데이터 번역 수행
            var data = doc.data() as Map<String, dynamic>;
            String imageUrl = data['imageUrl'] ??
                'https://cdn-icons-png.flaticon.com/512/1996/1996055.png';
            String allergens = data['allergens'] ?? 'No Allergens';
            String translatedName =
                await firestoreService.translateText(data['name'], 'en');
            String translatedAllergens = allergens.isNotEmpty
                ? await firestoreService.translateText(allergens, 'en')
                : allergens;
            String translatedDescription =
                await firestoreService.translateText(data['description'], 'en');

            translatedData[doc.id] = {
              'name': translatedName,
              'allergens': translatedAllergens,
              'description': translatedDescription,
              'imageUrl': imageUrl // imageUrl 추가
            };
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
    if (isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xffCDF5F9),
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (firestoreData.isEmpty) {
      return _buildNoDataScreen();
    }

    return _buildDataScreen();
  }

  MaterialApp _buildNoDataScreen() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xffCDF5F9),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 100),
              Text(
                "There are no matching data. Click the button to let the developer know",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 80),
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                onPressed: _saveRemainingTexts,
                child: Text("Inform the developer"),
              ),
              SizedBox(height: 150),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Return to previous screen
                },
                child: Text('Return to previous screen'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  MaterialApp _buildDataScreen() {
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
                for (var doc in firestoreData) _buildItemWidget(doc.id),
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
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
      onPressed: _saveRemainingTexts,
      child: Text(
        "There are also foods that cannot be found. Click the here to leave feedback to the developers",
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildItemWidget(String docId) {
    var translatedItemData = translatedData[docId];
    // imageUrl이 translatedData에 포함되도록 변경합니다.
    var imageUrl = translatedItemData?['imageUrl'] ??
        'https://cdn-icons-png.flaticon.com/512/1996/1996055.png';

    return Card(
      elevation: 4.0,
      margin: EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
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
              translatedItemData?['name'] ?? 'MenuName',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              translatedItemData?['allergens'] ?? 'No allergens',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            Text(
              translatedItemData?['description'] ?? 'Description',
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

  Future<String> _loadImage(String imageUrl) async {
    try {
      // 이미지 URL이 'gs://'로 시작하는 경우만 Firebase Storage에서 URL 가져오기
      if (imageUrl.startsWith('gs://')) {
        return await FirebaseStorage.instance
            .refFromURL(imageUrl)
            .getDownloadURL();
      }
      // 이미 완전한 URL이라면 그대로 사용
      return imageUrl;
    } catch (e) {
      print("Error loading image: $e");
      return 'https://cdn-icons-png.flaticon.com/512/1996/1996055.png'; // 오류 시 기본 이미지 URL 반환
    }
  }

  void _saveRemainingTexts() async {
    String remainingTexts =
        notFoundTexts.join(" ").replaceAll(RegExp(r'\d+'), '').trim();
    if (remainingTexts.isNotEmpty) {
      final firestoreService = FirestoreService();
      await firestoreService.saveExtractedText(remainingTexts);
    }
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
