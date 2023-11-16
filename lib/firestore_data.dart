import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class FirestoreService {
  final _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot?> fetchDataBasedOnWords(String word) async {
    try {
      final docSnap = await _firestore.collection('foods').doc(word).get();
      if (docSnap.exists) {
        return docSnap;
      }
    } catch (e) {
      print("Error fetching data from Firestore: $e");
    }
    return null;
  }

  Future<void> saveExtractedText(String text) async {
    await FirebaseFirestore.instance.collection('feedbacks').add({
      'extractedText': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<String> translateText(String text, String targetLanguage) async {
    final apiKey = dotenv.env['APP_KEY'] ?? '';
    final url = Uri.parse('https://translation.googleapis.com/language/translate/v2?key=$apiKey');


    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'q': text,
          'target': targetLanguage,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['translations'][0]['translatedText'];
      } else {
        print('Translation API error: ${response.statusCode}'); // 에러 로그
        return 'Error: Unable to translate'; // 적절한 기본 메시지 제공 또는 적절히 처리
      }
    } catch (e) {
      print('Translation API exception: $e'); // 예외 로그
      return 'Exception: Unable to translate'; // 예외 처리
    }
  }
}
