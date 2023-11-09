import 'package:cloud_firestore/cloud_firestore.dart';

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
}
