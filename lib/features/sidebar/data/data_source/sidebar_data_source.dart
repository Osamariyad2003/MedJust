import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:med_just/features/sidebar/data/model/header_model.dart';

class SidebarDataSource {
  final FirebaseFirestore _firebaseFirestore;
  final FirebaseAuth? _firebaseAuth = FirebaseAuth.instance;
  SidebarDataSource({FirebaseFirestore? firebaseFirestore})
    : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;
  // SidebarDataSource
  Future<HeaderModel> getHeader({required String uid}) async {
    try {
      DocumentSnapshot document =
          await _firebaseFirestore.collection("users").doc(uid).get();
      Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
      if (data != null) {
        return HeaderModel.fromJson(data);
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth?.signOut();
    } catch (error) {
      throw Exception('Sign out failed: $error');
    }
  }
}
