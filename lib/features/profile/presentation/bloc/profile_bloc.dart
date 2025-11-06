import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_just/core/local/secure_helper.dart';
import 'package:med_just/features/profile/data/profile_repo.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;
  final SecureStorageService _secureStorage;

  ProfileBloc({
    required ProfileRepository repository,
    SecureStorageService? secureStorage,
  }) : _repository = repository,
       _secureStorage = secureStorage ?? SecureStorageService(),
       super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);

    on<UpdateAddress>(_onUpdateAddress);
    on<UpdateYearId>(_onUpdateYearId);
    on<SaveProfile>(_onSaveProfile);

    debugPrint('onCreate -- ProfileBloc');
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      // Get user ID from secure storage
      final userId = await _secureStorage.getUserId();

      if (userId == null || userId.isEmpty) {
        debugPrint('No user ID found in secure storage');
        emit(const ProfileError('يجب تسجيل الدخول أولاً'));
        return;
      }

      debugPrint('Loading profile for user: $userId');
      final profile = await _repository.getProfile(userId);

      if (profile == null) {
        debugPrint('Profile not found, creating default profile');
        // Create default profile if none exists
        final defaultProfile = await _repository.createDefaultProfile(userId);
        emit(ProfileLoaded(defaultProfile));
      } else {
        emit(ProfileLoaded(profile));
      }

      debugPrint('Profile loaded successfully');
    } catch (e) {
      debugPrint('Error loading profile: $e');
      emit(ProfileError('فشل في تحميل البيانات: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateAddress(
    UpdateAddress event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentProfile = (state as ProfileLoaded).profile;
      final updatedProfile = currentProfile.copyWith(address: event.address);
      emit(ProfileLoaded(updatedProfile));
    }
  }

  Future<void> _onUpdateYearId(
    UpdateYearId event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentProfile = (state as ProfileLoaded).profile;
      // Convert the incoming String? to the expected Map<String, String>? for copyWith
      final Map<String, String>? yearIdMap =
          event.yearId == null ? null : {'yearId': event.yearId!};
      final updatedProfile = currentProfile.copyWith(yearId: yearIdMap);
      emit(ProfileLoaded(updatedProfile));
    }
  }

  Future<void> _onSaveProfile(
    SaveProfile event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) return;

    emit(ProfileSaving());

    try {
      final profile = (state as ProfileLoaded).profile;
      await _repository.updateProfile(profile);
      emit(ProfileUpdateSuccess('تم حفظ التغييرات بنجاح'));

      // Reload profile to get updated data
      add(LoadProfile());
    } catch (e) {
      debugPrint('Error saving profile: $e');
      emit(ProfileError('فشل في حفظ التغييرات: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    debugPrint('ProfileBloc closed');
    return super.close();
  }
}
