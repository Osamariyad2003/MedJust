import 'package:equatable/equatable.dart';
import 'package:med_just/core/models/user_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileSaving extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserModel profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdateSuccess extends ProfileState {
  final String message;

  const ProfileUpdateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
