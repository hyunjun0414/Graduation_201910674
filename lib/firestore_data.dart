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
        // 상세한 오류 메시지를 포함하여 로그를 남깁니다.
        print('Translation API error: ${response.statusCode}, ${response.body}');
        return 'Error: Unable to translate';
      }
    } catch (e) {
      // 네트워크 오류나 기타 예외에 대한 처리
      print('Translation API exception: $e');
      return 'Exception: Unable to translate';
    }
  }

}
