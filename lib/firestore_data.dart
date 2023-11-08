import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot?> fetchDataBasedOnText(String text) async {
    try {
      final docSnap = await _firestore.collection('foods').doc(text).get();
      if (docSnap.exists) {
        return docSnap;
      }
    } catch (e) {
      print("Error fetching data from Firestore: $e");
      // 여기서 추가적으로 사용자에게 오류 메시지를 표시할 수 있습니다.
    }
    return null;
  }
  Future<void> saveExtractedText(String text) async {
    await FirebaseFirestore.instance.collection('feedbacks').add({
      'extractedText': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
