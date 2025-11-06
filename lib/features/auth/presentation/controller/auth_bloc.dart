import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:med_just/core/local/cachekeys.dart';
import 'package:med_just/core/models/user_model.dart';
import 'package:med_just/core/utils/faliures.dart';
import 'package:med_just/core/local/secure_helper.dart'; // Import SecureStorage

import '../../data/repo/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  UserModel? currentUser; // Add this variable to store the current user

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckAuthStatus);

    add(AuthCheckRequested()); // Check auth status when created
  }

  // Getter to access the current user

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.login(event.email, event.password);

      response.fold((failure) => emit(AuthError(message: failure.message)), (
        user,
      ) {
        try {
          currentUser = user; // Save user in variable
          final userBox = Hive.box('userBox');
          if (user.yearId != null && user.yearId!.isNotEmpty) {
            userBox.put('yearId', user.yearId);
          }
          // Set isLoggedIn flag to true
          userBox.put('isLoggedIn', true);
          _setSecuredUserId(user.id);
          print('Login successful. Set isLoggedIn: true');
        } catch (e) {
          print("Error storing user data: $e");
        }
        emit(AuthAuthenticated(user: user));
      });
    } catch (e) {
      emit(AuthError(message: 'Login failed: ${e.toString()}'));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.register(
        event.email,
        event.password,
        event.name,
        event.phone,
        event.uninumber,
        event.userId,
        event.yearId,
      );

      result.fold((failure) => emit(AuthError(message: failure.message)), (
        user,
      ) {
        try {
          currentUser = user; // Save user in variable
          final userBox = Hive.box('userBox');
          userBox.put('yearId', event.yearId);
          // Set isLoggedIn flag to true after successful registration
          userBox.put('isLoggedIn', true);
          print('Registration successful. Set isLoggedIn: true');
        } catch (e) {
          print("Error storing user data: $e");
        }
        emit(AuthAuthenticated(user: user));
      });
    } catch (e) {
      emit(AuthError(message: 'Registration failed: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.logout();

      // Clear stored data
      currentUser = null; // Clear the user variable
      final userBox = Hive.box('userBox');
      userBox.delete('yearId');
      userBox.put('isLoggedIn', false);
      print('Logout successful. Set isLoggedIn: false');

      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Logout failed: ${e.toString()}'));
    }
  }

  Future<void> _onCheckAuthStatus(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // First check if user is logged in according to Hive
      final box = Hive.box('userBox');
      final isLoggedIn = box.get('isLoggedIn', defaultValue: false);
      String yearId = box.get('yearId', defaultValue: '');

      print('Auth check - isLoggedIn from Hive: $isLoggedIn');
      print('Auth check - yearId from Hive: $yearId');

      if (!isLoggedIn) {
        print(
          'User not logged in according to Hive. Emitting AuthUnauthenticated.',
        );
        currentUser = null; // Clear user variable
        emit(AuthUnauthenticated());
        return;
      }

      // Only try to get current user if Hive says we're logged in
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        UserModel userModel;

        if (user is String) {
          try {
            final Map<String, dynamic> userData = jsonDecode(user as String);
            userModel = UserModel.fromJson(userData);
          } catch (e) {
            print("Error parsing user data: $e");
            box.put('isLoggedIn', false);
            currentUser = null;
            emit(AuthUnauthenticated());
            return;
          }
        } else if (user is Map<String, dynamic>) {
          userModel = UserModel.fromJson(user);
        } else {
          print("Unexpected user data type: ${user.runtimeType}");
          box.put('isLoggedIn', false);
          currentUser = null;
          emit(AuthUnauthenticated());
          return;
        }

        currentUser = userModel;
        print(currentUser?.phone);
        emit(AuthAuthenticated(user: userModel));
      } else {
        box.put('isLoggedIn', false);
        currentUser = null;
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print("Auth check error: $e");
      currentUser = null;
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _setSecuredUserId(String userId) async {
    try {
      // Save the user id into secure storage using an instance and positional argument
      final secureStorage = SecureStorageService();
      await secureStorage.saveAuthToken(userId, userId);
    } catch (e, st) {
      log('Error saving secure user id: $e', error: e, stackTrace: st);
    }
  }
}
