import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:social4/screens/post/cubit/post_cubit.dart';
import 'package:social4/service/shared_preference_service.dart';

part 'post_detail_state.dart';

class PostDetailCubit extends Cubit<PostDetailState> {
  PostDetailCubit() : super(PostDetailInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final sharedPreferencesService = SharedPreferencesService();

  reset() {
    emit(PostDetailInitial());
  }

  Future<void> getPostById(String postId) async {
    // emit(PostDetailLoading());
    try {
      // final currentUserId = sharedPreferencesService.getString("userID");

      DocumentSnapshot postDoc =
          await _firestore.collection('posts').doc(postId).get();
      if (!postDoc.exists) {
        emit(PostDetailError(message: 'Post not found'));
        return;
      }

      String userId = postDoc['userId'];
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        emit(PostDetailError(message: 'User not found'));
        return;
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      Post post = Post.fromDocument(postDoc, userData);
      emit(PostDetailLoaded(post: post));
    } catch (e) {
      emit(PostDetailError(message: e.toString()));
    }
  }

  Future<void> likePost(String postId) async {
    Post post = (state as PostDetailLoaded).post;

    Post updatedPost = post.copyWith(
      likes: post.likes + 1,
      isLikedByCurrentUser: true,
    );

    post = updatedPost;
    emit(PostDetailLoaded(
      post: post,
    ));

    _updateLikeInFirestore(postId, true);
  }

  Future<void> unlikePost(String postId) async {
    Post post = (state as PostDetailLoaded).post;

    Post updatedPost = post.copyWith(
      likes: post.likes - 1,
      isLikedByCurrentUser: false,
    );

    post = updatedPost;
    emit(PostDetailLoaded(
      post: post,
    ));

    _updateLikeInFirestore(postId, false);
  }

  _updateLikeInFirestore(String postId, bool isLike) async {
    try {
      final userId = sharedPreferencesService.getString("userID");

      DocumentReference postRef = _firestore.collection('posts').doc(postId);
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot postSnapshot = await transaction.get(postRef);
        if (!postSnapshot.exists) return;

        int currentLikes = postSnapshot['likes'];
        List<dynamic> likedBy = postSnapshot['likedBy'];

        if (isLike) {
          if (!likedBy.contains(userId)) {
            transaction.update(postRef, {
              'likes': currentLikes + 1,
              'likedBy': FieldValue.arrayUnion([userId]),
            });
          }
        } else {
          if (likedBy.contains(userId)) {
            transaction.update(postRef, {
              'likes': currentLikes - 1,
              'likedBy': FieldValue.arrayRemove([userId]),
            });
          }
        }
      });
      await getPostById(postId); // Refresh posts after liking
    } catch (e) {
      // emit(PostDetailError(message: e.toString()));
    }
  }
}
