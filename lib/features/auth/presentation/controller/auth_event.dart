import '../../../../core/models/user_model.dart';

abstract class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested({required this.email, required this.password});
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String phone;
  final String uninumber;
  final String userId;
  final String yearId;

  AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.uninumber,
    required this.userId,
    required this.yearId,
  });
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthUserUpdated extends AuthEvent {
  final UserModel? user;

  AuthUserUpdated({this.user});
}
