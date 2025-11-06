import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/utils/expentions.dart';
import '../../../../core/utils/faliures.dart';

class FirebaseAuthDataSource {
  final fb.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthDataSource({
    fb.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  Future<Either<FirebaseAuthFailure, UserModel>> registerUser({
    required String email,
    required String password,
    required String username,
    required String phoneNumber,
    required String country,
    required String uninumber,
    required String userId,
    required String yearId,
    String? photoUrl,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final fb.User? firebaseUser = credential.user;
    if (firebaseUser == null) {
      return Left(
        FirebaseAuthFailure(message: 'Failed to create user in Firebase Auth'),
      );
    }

    final userDocRef = _firestore.collection('users').doc(firebaseUser.uid);

    final userModel = UserModel(
      id: firebaseUser.uid,
      name: username,
      email: email,
      phone: phoneNumber,
      photoUrl: photoUrl ?? '',
      createdAt: DateTime.now(),
    );

    // Create a map with all user data, including the new fields
    final userData = userModel.toJson();
    userData['uninumber'] = uninumber;
    userData['userId'] = userId;
    userData['yearId'] = yearId;

    await userDocRef.set(userData);

    return Right(userModel);
  }

  Future<UserModel> loginWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in aborted');

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final fb.User? firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw FireBaseException(message: 'Google login failed');
    }

    final userDocRef = _firestore.collection('users').doc(firebaseUser.uid);
    final doc = await userDocRef.get();

    if (!doc.exists) {
      final userModel = UserModel(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'Google User',
        email: firebaseUser.email ?? '',
        phone: firebaseUser.phoneNumber ?? '',
        photoUrl: '',
        createdAt: DateTime.now(),
      );

      await userDocRef.set(userModel.toJson());
      return userModel;
    }

    return UserModel.fromJson(doc.data()!);
  }

  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Firebase Auth
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the user ID
      final uid = userCredential.user!.uid;

      // Fetch user details from Firestore
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      // The error is here - you're probably expecting userDoc.data() to be a Map<String, String>
      // but it's returning a Map<String, dynamic> or in some cases a String
      final userData = userDoc.data()!;

      // Create a proper UserModel with the data
      return UserModel(
        id: uid,
        email: email,
        // Make sure to handle each field properly with null checks and type casts
        name: userData['name']?.toString() ?? '',
        yearId:
            userData['yearId'] is Map
                ? userData['yearId'] as Map<String, String>?
                : null,
        phone: userData['phone']?.toString() ?? '',
        uninumber: userData['uninumber']?.toString() ?? '',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Login with email error: $e');
      throw Exception('Login failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut(); // if signed in with Google
    } catch (_) {}
    await _firebaseAuth.signOut();
  }

  fb.User? get currentUser => _firebaseAuth.currentUser;

  Future<Either<FirebaseAuthFailure, UserModel>> getCurrentUser(
    String uid,
  ) async {
    try {
      final fb.User? firebaseUser = _firebaseAuth.currentUser;

      if (firebaseUser == null) {
        return Left(
          FirebaseAuthFailure(message: 'No user is currently logged in'),
        );
      }

      // Get user details from Firestore
      final doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!doc.exists || doc.data() == null) {
        return Left(
          FirebaseAuthFailure(message: 'User profile not found in database'),
        );
      }

      // Parse the Firestore data into UserModel
      final userData = doc.data()!;
      userData['id'] = firebaseUser.uid; // Ensure ID is included

      return Right(UserModel.fromJson(userData));
    } on FirebaseException catch (e) {
      return Left(FirebaseAuthFailure(message: 'Firebase error: ${e.message}'));
    } catch (e) {
      return Left(
        FirebaseAuthFailure(message: 'Failed to get current user: $e'),
      );
    }
  }
}
