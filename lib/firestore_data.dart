import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot?> fetchDataBasedOnText(String text) async {
    // Use the text directly as the document ID to fetch data
    final docSnap = await _firestore.collection('foods').doc(text).get();

    if (docSnap.exists) {
      return docSnap;
    }
    return null;
  }
}
