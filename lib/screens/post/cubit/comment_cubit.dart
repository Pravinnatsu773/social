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

  final int repliesCount;
  final List<Comment> replies;
  final DateTime timestamp;

  Comment(
      {required this.id,
      required this.postId,
      required this.userId,
      required this.content,
      required this.name,
      required this.userName,
      required this.userProfilePic,
      required this.likes,
      required this.isLikedByCurrentUser,
      required this.timestamp,
      required this.repliesCount,
      required this.replies});

  Comment copyWith(
      {String? id,
      String? postId,
      String? userId,
      String? content,
      String? name,
      String? userName,
      String? userProfilePic,
      int? likes,
      bool? isLikedByCurrentUser,
      DateTime? timestamp,
      int? repliesCount,
      List<Comment>? replies}) {
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
        timestamp: timestamp ?? this.timestamp,
        replies: replies ?? this.replies,
        repliesCount: repliesCount ?? this.repliesCount);
  }

  factory Comment.fromDocument(
      DocumentSnapshot doc, Map<String, dynamic> userData,
      {bool isReplie = false}) {
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
      repliesCount: doc['repliesCount'] ?? 0,
      replies: isReplie ? [] : (List<Comment>.from(doc['replies'])),
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

  Future<void> fetchCommentsByCommentId(String postId, String commentId) async {
    // emit(CommentLoading());
    try {
      // final commentDoc =
      //     await _firestore.collection('comments').doc(commentId).get();
      // if (!commentDoc.exists) throw Exception("Comment does not exist");

      final repliesQuerySnapshot = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .orderBy('timestamp', descending: false)
          .get();

      List<Comment> replies = [];
      for (DocumentSnapshot respliesDoc in repliesQuerySnapshot.docs) {
        String userId = respliesDoc['userId'];
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(userId).get();
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        Comment reply =
            Comment.fromDocument(respliesDoc, userData, isReplie: true);
        replies.add(reply);
      }

      List<Comment> updatedComents =
          List.from((state as CommentLoaded).comments);
      List<Comment> updatedReplies = updatedComents
          .where((element) => element.id == commentId)
          .first
          .replies;
      updatedReplies = replies;
      int index =
          updatedComents.indexWhere((element) => element.id == commentId);
      if (index != -1) {
        updatedComents[index] =
            updatedComents[index].copyWith(replies: updatedReplies);
      }

      emit(CommentLoaded(comments: updatedComents));
    } catch (e) {
      // emit(CommentError(message: e.toString()));
    }
  }

  Future<void> addComment(String postId, String content,
      {bool isReferesh = false, String? parentCommentId}) async {
    try {
      final userId = sharedPreferencesService.getString("userID");

      DocumentReference postRef = _firestore.collection('posts').doc(postId);
      CollectionReference comments = postRef.collection('comments');

      if (parentCommentId != null) {
        CollectionReference replies = postRef
            .collection('comments')
            .doc(parentCommentId)
            .collection('replies');
        DocumentReference repliesDocRef = await replies.add({
          'postId': postId,
          'userId': userId,
          'content': content,
          'parentCommnetId': parentCommentId,
          'likes': 0,
          'repliesCount': 0,
          'likedBy': [],
          'timestamp': FieldValue.serverTimestamp(),
        });

        DocumentSnapshot repliesDoc = await repliesDocRef.get();

        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(userId).get();
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        Comment newReplie =
            Comment.fromDocument(repliesDoc, userData, isReplie: true);
        // Update comment count

        DocumentReference commnetRef =
            postRef.collection('comments').doc(parentCommentId);
        await _firestore.runTransaction((transaction) async {
          DocumentSnapshot commnetSnapshot = await transaction.get(commnetRef);
          if (!commnetSnapshot.exists) return;

          int currentCommentCount = commnetSnapshot['repliesCount'];
          transaction.update(commnetRef, {
            'repliesCount': currentCommentCount + 1,
          });
        });

        if (state is CommentLoaded) {
          List<Comment> finalCommentList = [];
          List<Comment> updatedComents =
              List.from((state as CommentLoaded).comments);
          List<Comment> updatedReplies = updatedComents
              .where((element) => element.id == parentCommentId)
              .first
              .replies;
          updatedReplies = [...updatedReplies, newReplie];
          int index = updatedComents
              .indexWhere((element) => element.id == parentCommentId);
          if (index != -1) {
            updatedComents[index] = updatedComents[index].copyWith(
                replies: updatedReplies,
                repliesCount: updatedComents[index].repliesCount + 1);
          }
          emit(CommentLoaded(comments: updatedComents));
        } else {
          emit(CommentLoaded(
              comments: List.from((state as CommentLoaded).comments)));
        }
// fetchComments(postId)
        // await fetchCommentsByCommentId(postId, parentCommentId);
      } else {
        DocumentReference commentDocRef = await comments.add({
          'postId': postId,
          'userId': userId,
          'content': content,
          'repliesCount': 0,
          'replies': [],
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
              List.from((state as CommentLoaded).comments)
                ..insert(0, newComment);
          emit(CommentLoaded(comments: updatedComments));
        } else {
          emit(CommentLoaded(comments: [newComment]));
        }
      }
      // await fetchComments(postId);
      // emit(CommentLoaded(newComment: newComment));
    } catch (e) {
      emit(CommentError(message: e.toString()));
    }
  }

  Future<void> likeComment(String commentId,
      {bool isReply = false, String? replyId}) async {
    List<Comment> currentComments = (state as CommentLoaded).comments;

    int commentIndex =
        currentComments.indexWhere((comment) => comment.id == commentId);

    if (isReply) {
      if (commentIndex != -1) {
        Comment comment = currentComments[commentIndex];
        int replyIndex = currentComments[commentIndex]
            .replies
            .indexWhere((reply) => reply.id == replyId);
        if (replyIndex != -1) {
          Comment reply = currentComments[commentIndex].replies[replyIndex];
          Comment updatedReply = reply.copyWith(
              likes: reply.likes + 1, isLikedByCurrentUser: true);
          currentComments[commentIndex].replies[replyIndex] = updatedReply;

          emit(CommentLoaded(comments: currentComments));

          _updateLikeInFirestore(comment.postId, commentId, true,
              isReply: true, replyId: replyId);
        }
      }
    } else {
      if (commentIndex != -1) {
        Comment comment = currentComments[commentIndex];
        Comment updatedPost = comment.copyWith(
          likes: comment.likes + 1,
          isLikedByCurrentUser: true,
        );

        currentComments[commentIndex] = updatedPost;
        emit(CommentLoaded(comments: currentComments));

        _updateLikeInFirestore(comment.postId, commentId, true);
      }
    }
  }

  Future<void> unlikeComment(String commentId,
      {bool isReply = false, String? replyId}) async {
    List<Comment> currentComments = (state as CommentLoaded).comments;

    int commentIndex =
        currentComments.indexWhere((comment) => comment.id == commentId);

    if (isReply) {
      if (commentIndex != -1) {
        Comment comment = currentComments[commentIndex];
        int replyIndex = currentComments[commentIndex]
            .replies
            .indexWhere((reply) => reply.id == replyId);
        if (replyIndex != -1) {
          Comment reply = currentComments[commentIndex].replies[replyIndex];
          Comment updatedReply = reply.copyWith(
              likes: reply.likes - 1, isLikedByCurrentUser: false);
          currentComments[commentIndex].replies[replyIndex] = updatedReply;

          emit(CommentLoaded(comments: currentComments));

          _updateLikeInFirestore(comment.postId, commentId, false,
              isReply: true, replyId: replyId);
        }
      }
    } else {
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
  }

  _updateLikeInFirestore(String postId, String commentId, bool isLike,
      {bool isReply = false, String? replyId}) async {
    try {
      final userId = sharedPreferencesService.getString("userID");

      DocumentReference postRef = _firestore.collection('posts').doc(postId);
      DocumentReference commentRef =
          postRef.collection('comments').doc(commentId);
      if (isReply) {
        commentRef = postRef
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .doc(replyId);
      }
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
      // await fetchComments(postId); // Refresh posts after liking
    } catch (e) {
      emit(CommentError(message: e.toString()));
    }
  }
}
