part of 'post_cubit.dart';

@immutable
class PostState {}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<Post> posts;
  final bool hasMore;

  PostLoaded({required this.posts, required this.hasMore});
}

class PostError extends PostState {
  final String message;

  PostError({required this.message});
}
