part of 'auth_cubit.dart';

@immutable
class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLoaded extends AuthState {
  final UserModel? user;

  AuthLoaded({
    this.user,
  });
}

class AuthError extends AuthState {
  final String? errorMessage;

  AuthError({this.errorMessage});
}
