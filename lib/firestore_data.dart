import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot?> fetchDataBasedOnText(String text) async {
    // Example: Fetch data from 'texts' collection where 'content' field matches the text
    final querySnap = await _firestore.collection('texts').where('content', isEqualTo: text).get();
    if (querySnap.docs.isNotEmpty) {
      return querySnap.docs.first;
    }
    return null;
  }
}
