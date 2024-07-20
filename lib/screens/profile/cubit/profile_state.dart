part of 'profile_cubit.dart';

@immutable
class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileUpdating extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserModel userProfile;

  ProfileLoaded({required this.userProfile});
}

class ProfileUpdated extends ProfileState {
  final Map<String, dynamic> userProfile;

  ProfileUpdated({required this.userProfile});
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError({required this.message});
}
