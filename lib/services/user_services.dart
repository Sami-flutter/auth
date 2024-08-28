// services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, String>> fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        return {
          'name': userDoc['name'] ?? 'No Name',
          'imageUrl': userDoc['imageUrl'] ?? '',
        };
      }
    }
    return {'name': 'No Name', 'imageUrl': ''};
  }
}
