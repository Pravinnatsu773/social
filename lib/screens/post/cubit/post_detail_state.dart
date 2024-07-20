part of 'post_detail_cubit.dart';

@immutable
class PostDetailState {}

class PostDetailInitial extends PostDetailState {}

class PostDetailLoading extends PostDetailState {}

class PostLoaded extends PostDetailState {
  final List<Post> posts;
  final bool hasMore;

  PostLoaded({required this.posts, required this.hasMore});
}

class PostAdding extends PostDetailState {}

class PostAdded extends PostDetailState {}

class PostDetailLoaded extends PostDetailState {
  final Post post;

  PostDetailLoaded({required this.post});
}

class PostDetailError extends PostDetailState {
  final String message;

  PostDetailError({required this.message});
}
