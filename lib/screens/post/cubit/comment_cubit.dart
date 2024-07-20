import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social4/service/shared_preference_service.dart';

part 'comment_state.dart';

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final String name;
  final String userName;
  final String userProfilePic;
  final int likes;
  final bool isLikedByCurrentUser;

  final DateTime timestamp;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.name,
    required this.userName,
    required this.userProfilePic,
    required this.likes,
    required this.isLikedByCurrentUser,
    required this.timestamp,
  });

  Comment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? content,
    String? name,
    String? userName,
    String? userProfilePic,
    int? likes,
    bool? isLikedByCurrentUser,
    DateTime? timestamp,
  }) {
    return Comment(
        id: id ?? this.id,
        postId: postId ?? this.postId,
        userId: userId ?? this.userId,
        content: content ?? this.content,
        name: name ?? this.name,
        userName: userName ?? this.userName,
        userProfilePic: userProfilePic ?? this.userProfilePic,
        likes: likes ?? this.likes,
        isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
        timestamp: timestamp ?? this.timestamp);
  }

  factory Comment.fromDocument(
      DocumentSnapshot doc, Map<String, dynamic> userData) {
    final userId = SharedPreferencesService().getString("userID");

    bool isLiked = (doc['likedBy'] as List<dynamic>).contains(userId);
    return Comment(
      id: doc.id,
      postId: doc['postId'],
      userId: doc['userId'],
      content: doc['content'],
      name: userData['name'],
      userName: userData['username'],
      userProfilePic: userData['profilePic'],
      likes: doc['likes'],
      isLikedByCurrentUser: isLiked,
      timestamp: (doc['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'userId': userId,
      'content': content,
      'timestamp': timestamp,
    };
  }
}

class CommentCubit extends Cubit<CommentState> {
  final sharedPreferencesService = SharedPreferencesService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CommentCubit() : super(CommentInitial());

  Future<void> fetchComments(String postId, {bool isRefresh = false}) async {
    if (isRefresh) {
      emit(CommentLoading());
    }
    try {
      QuerySnapshot commentSnapshot = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get();

      List<Comment> comments = [];
      for (DocumentSnapshot commentDoc in commentSnapshot.docs) {
        String userId = commentDoc['userId'];
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(userId).get();
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        Comment comment = Comment.fromDocument(commentDoc, userData);
        comments.add(comment);
      }

      emit(CommentLoaded(comments: comments));
    } catch (e) {
      emit(CommentError(message: e.toString()));
    }
  }

  Future<void> addComment(String postId, String content,
      {bool isReferesh = false}) async {
    try {
      final userId = sharedPreferencesService.getString("userID");

      DocumentReference postRef = _firestore.collection('posts').doc(postId);
      CollectionReference comments = postRef.collection('comments');

      DocumentReference commentDocRef = await comments.add({
        'postId': postId,
        'userId': userId,
        'content': content,
        'likes': 0,
        'likedBy': [],
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Fetch the added comment to get the complete comment object
      DocumentSnapshot commentDoc = await commentDocRef.get();
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      Comment newComment = Comment.fromDocument(commentDoc, userData);

      // Update comment count
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot postSnapshot = await transaction.get(postRef);
        if (!postSnapshot.exists) return;

        int currentCommentCount = postSnapshot['commentCount'];
        transaction.update(postRef, {
          'commentCount': currentCommentCount + 1,
        });
      });

      if (state is CommentLoaded) {
        List<Comment> updatedComments =
            List.from((state as CommentLoaded).comments)..insert(0, newComment);
        emit(CommentLoaded(comments: updatedComments));
      } else {
        emit(CommentLoaded(comments: [newComment]));
      }

      // emit(CommentLoaded(newComment: newComment));
    } catch (e) {
      emit(CommentError(message: e.toString()));
    }
  }

  Future<void> likeComment(String commentId) async {
    List<Comment> currentComments = (state as CommentLoaded).comments;
    int commentIndex =
        currentComments.indexWhere((comment) => comment.id == commentId);
    if (commentIndex != -1) {
      Comment comment = currentComments[commentIndex];
      Comment updatedPost = comment.copyWith(
        likes: comment.likes + 1,
        isLikedByCurrentUser: true,
      );

      currentComments[commentIndex] = updatedPost;
      emit(CommentLoaded(
        comments: currentComments,
      ));

      _updateLikeInFirestore(comment.postId, commentId, true);
    }
  }

  Future<void> unlikeComment(String commentId) async {
    List<Comment> currentComments = (state as CommentLoaded).comments;
    int commentIndex =
        currentComments.indexWhere((comment) => comment.id == commentId);
    if (commentIndex != -1) {
      Comment comment = currentComments[commentIndex];
      Comment updatedPost = comment.copyWith(
        likes: comment.likes - 1,
        isLikedByCurrentUser: false,
      );

      currentComments[commentIndex] = updatedPost;
      emit(CommentLoaded(comments: currentComments));

      _updateLikeInFirestore(comment.postId, commentId, false);
    }
  }

  _updateLikeInFirestore(String postId, String commentId, bool isLike) async {
    try {
      final userId = sharedPreferencesService.getString("userID");

      DocumentReference postRef = _firestore.collection('posts').doc(postId);
      DocumentReference commentRef =
          postRef.collection('comments').doc(commentId);
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot commentSnapshot = await transaction.get(commentRef);
        if (!commentSnapshot.exists) return;

        int currentLikes = commentSnapshot['likes'];
        List<dynamic> likedBy = commentSnapshot['likedBy'];

        if (isLike) {
          if (!likedBy.contains(userId)) {
            transaction.update(commentRef, {
              'likes': currentLikes + 1,
              'likedBy': FieldValue.arrayUnion([userId]),
            });
          }
        } else {
          if (likedBy.contains(userId)) {
            transaction.update(commentRef, {
              'likes': currentLikes - 1,
              'likedBy': FieldValue.arrayRemove([userId]),
            });
          }
        }
      });
      await fetchComments(postId); // Refresh posts after liking
    } catch (e) {
      emit(CommentError(message: e.toString()));
    }
  }
}
