import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUserProfile({
    required String uid,
    required String email,
  }) async {
    await _db.collection('users').doc(uid).set({
      'email': email,
      'username': '',
      'phone': '',
      'level': 1,
      'xp': 0,
      'coins': 0,
      'streak': 0,
      'totalFocusTime': 0,
      'totalSessions': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }
}
