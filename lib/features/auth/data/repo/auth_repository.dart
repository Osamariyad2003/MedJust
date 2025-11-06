import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:med_just/core/utils/faliures.dart';
import 'package:med_just/features/auth/data/data_source/auth_datasource.dart';
import '../../../../core/models/user_model.dart';

class AuthRepository {
  final FirebaseAuthDataSource _authService = FirebaseAuthDataSource();
  Future<Either<FirebaseAuthFailure, UserModel>> login(
    String email,
    String password,
  ) async {
    try {
      // Get user model or data from auth service
      dynamic result = await _authService.loginWithEmail(
        email: email,
        password: password,
      );

      UserModel userModel;

      // This is where the error is happening - handle different return types properly
      if (result is String) {
        // If it's a JSON string, parse it
        try {
          final Map<String, dynamic> userData = jsonDecode(result);
          userModel = UserModel.fromJson(userData);
        } catch (e) {
          print('Error parsing user data: $e');
          throw Exception('Invalid user data format');
        }
      } else if (result is Map<String, dynamic>) {
        // If it's a Map, convert to UserModel
        userModel = UserModel.fromJson(result);
      } else if (result is UserModel) {
        // If it's already a UserModel, use it directly
        userModel = result;
      } else {
        throw Exception('Unexpected user data type: ${result.runtimeType}');
      }

      return right(userModel);
    } catch (e) {
      print('Login error: $e');
      return left(FirebaseAuthFailure(message: e.toString()));
    }
  }

  Future<Either<FirebaseAuthFailure, UserModel>> register(
    String email,
    String password,
    String name,
    String phone,
    String uninumber,
    String userId,
    String yearId,
  ) async {
    try {
      return await _authService.registerUser(
        email: email,
        password: password,
        username: name,
        phoneNumber: phone,
        uninumber: uninumber,
        userId: userId,
        yearId: yearId,
        country: '', // Keep this for backward compatibility
      );
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await _authService.signOut();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final firebaseUser = _authService.currentUser;

      if (firebaseUser == null) {
        return null;
      }

      // Get user details from Firestore
      final doc = await _authService.getCurrentUser(firebaseUser.uid);

      // Return a structured Map with user data
      return {'id': firebaseUser.uid, 'email': firebaseUser.email ?? ''};
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }
}
