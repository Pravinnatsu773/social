part of 'profile_post_cubit.dart';

@immutable
class ProfilePostState {}

class ProfilePostInitial extends ProfilePostState {}

class ProfilePostLoading extends ProfilePostState {}

class ProfilePostLoaded extends ProfilePostState {
  final List<Post> posts;
  final bool hasMore;

  ProfilePostLoaded({required this.posts, required this.hasMore});
}

class ProfilePostError extends ProfilePostState {
  final String message;

  ProfilePostError({required this.message});
}
