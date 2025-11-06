import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:med_just/core/models/user_model.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:med_just/core/models/year_model.dart';

abstract class ProfileDataSource {
  Future<UserModel?> getUserProfile(String userId);
  Future<bool> updateUserProfile(UserModel profile);
  Future<bool> updateProfileImage(String userId, String imageUrl);
  Future<Year?> getUserYear(String yearId);
}

class ProfileFirestoreDataSource implements ProfileDataSource {
  final FirebaseFirestore _firestore;
  ProfileFirestoreDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        print('User not found with ID: $userId');
        return null;
      }
      final profileMap = doc.data();
      if (profileMap is Map<String, dynamic>) {
        return UserModel.fromJson(profileMap);
      } else {
        print('Error: Unexpected profileMap type: ${profileMap.runtimeType}');
        return null;
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  @override
  Future<bool> updateUserProfile(UserModel profile) async {
    try {
      await _firestore.collection('users').doc(profile.id).update({
        'name': profile.name,
        'phone': profile.phone,
        'email': profile.email,
        'yearId': profile.yearId, // can be string or map
        'address': profile.address,
      });
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  @override
  Future<bool> updateProfileImage(String userId, String photoUrl) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'photoUrl': photoUrl,
      });
      return true;
    } catch (e) {
      print('Error updating profile image: $e');
      return false;
    }
  }

  @override
  Future<Year?> getUserYear(String yearId) async {
    final doc = await _firestore.collection('years').doc(yearId).get();
    if (!doc.exists) return null;
    return Year.fromJson({'id': doc.id, ...doc.data()!});
  }

  // @override
  // Future<String?> uploadImageToCloudinary(File imageFile) async {
  //   try {
  //     // Upload to cloudinary
  //     final response = await _cloudinary.uploadFile(
  //       CloudinaryFile.fromFile(
  //         imageFile.path,
  //         folder: 'profile_images',
  //         resourceType: CloudinaryResourceType.Image,
  //       ),
  //     );

  //     // Return the secure URL
  //     return response.secureUrl;
  //   } catch (e) {
  //     print('Error uploading to Cloudinary: $e');
  //     return null;
  //   }
  // }

  // @override
  // Future<bool> updateUserPreferences(
  //   String userId,
  //   Map<String, dynamic> preferences,
  // ) async {
  //   try {
  //     await _firestore.collection('users').doc(userId).update({
  //       'preferences': preferences,
  //     });
  //     return true;
  //   } catch (e) {
  //     print('Error updating user preferences: $e');
  //     return false;
  //   }
  // }
}
