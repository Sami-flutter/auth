import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> getUserId() async {
    User? user = _auth.currentUser;
    return user?.uid;
  }

  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      } else {
        return null;
      }
    } catch (e) {
      print('Failed to fetch user data: $e');
      return null;
    }
  }

  Future<bool> updateUserData(String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(userId).update(userData);
      return true;
    } catch (e) {
      print('Failed to update user data: $e');
      return false;
    }
  }
}
