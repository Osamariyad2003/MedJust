import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:med_just/core/local/secure_helper.dart';
import 'package:med_just/core/models/user_model.dart';

abstract class ProfileRepository {
  Future<UserModel?> getProfile(String userId);
  Future<UserModel> createDefaultProfile(String userId);
  Future<void> updateProfile(UserModel profile);
  Future<void> deleteProfile(String userId);
}

class FirebaseProfileRepository implements ProfileRepository {
  final FirebaseFirestore _firestore;
  final SecureStorageService _secureStorage;

  FirebaseProfileRepository({
    FirebaseFirestore? firestore,
    SecureStorageService? secureStorage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _secureStorage = secureStorage ?? SecureStorageService();

  @override
  Future<UserModel?> getProfile(String userId) async {
    try {
      final doc = await _firestore.collection('profiles').doc(userId).get();

      if (!doc.exists) {
        return null;
      }

      return UserModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  @override
  Future<UserModel> createDefaultProfile(String userId) async {
    try {
      // Get user data from secure storage or auth
      final userEmail = await _secureStorage.getUserEmail() ?? '';
      final userName = await _secureStorage.getUserName() ?? 'مستخدم جديد';

      final defaultProfile = UserModel(
        id: userId,
        name: userName,
        email: userEmail,
        address: '',
        yearId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        phone: '',
      );

      await _firestore
          .collection('profiles')
          .doc(userId)
          .set(defaultProfile.toJson());

      return defaultProfile;
    } catch (e) {
      throw Exception('Failed to create default profile: $e');
    }
  }

  @override
  Future<void> updateProfile(UserModel profile) async {
    try {
      final updatedProfile = profile.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection('profiles')
          .doc(profile.id)
          .update(updatedProfile.toJson());
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<void> deleteProfile(String userId) async {
    try {
      await _firestore.collection('profiles').doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete profile: $e');
    }
  }
}
