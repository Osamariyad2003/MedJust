import 'package:equatable/equatable.dart';
import 'package:med_just/core/models/user_model.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final UserModel profile;

  const UpdateProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}

class UpdateProfileImage extends ProfileEvent {
  final String imagePath;

  const UpdateProfileImage(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class UpdatePreferences extends ProfileEvent {
  final Map<String, dynamic> preferences;

  const UpdatePreferences(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

class UpdateYearId extends ProfileEvent {
  final String? yearId;
  UpdateYearId(this.yearId);
}

class UpdateAddress extends ProfileEvent {
  final String address;
  UpdateAddress(this.address);
}

class SaveProfile extends ProfileEvent {}
