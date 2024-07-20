import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social4/service/shared_preference_service.dart';

part 'post_state.dart';

// Post model
class Post {
  final String postId;
  final String userId;
  final String content;
  final String img;
  final Timestamp timestamp;
  final int likes;
  final String name;
  final String userName;
  final String userProfilePic;

  final bool isLikedByCurrentUser;
  final int commentCount;

  Post(
      {required this.postId,
      required this.userId,
      required this.content,
      required this.img,
      required this.timestamp,
      required this.likes,
      required this.name,
      required this.userName,
      required this.userProfilePic,
      required this.isLikedByCurrentUser,
      required this.commentCount});
  Post copyWith(
      {String? postId,
      String? userId,
      String? content,
      String? img,
      Timestamp? timestamp,
      int? likes,
      String? name,
      String? userName,
      String? userProfilePic,
      bool? isLikedByCurrentUser,
      int? commentCount}) {
    return Post(
        postId: postId ?? this.postId,
        userId: userId ?? this.userId,
        content: content ?? this.content,
        userName: userName ?? this.userName,
        name: name ?? this.name,
        img: img ?? this.img,
        timestamp: timestamp ?? this.timestamp,
        userProfilePic: userProfilePic ?? this.userProfilePic,
        likes: likes ?? this.likes,
        isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
        commentCount: commentCount ?? this.commentCount);
  }

  factory Post.fromDocument(
      DocumentSnapshot doc, Map<String, dynamic> userData) {
    final userId = SharedPreferencesService().getString("userID");

    bool isLiked = (doc['likedBy'] as List<dynamic>).contains(userId);

    return Post(
        postId: doc.id,
        userId: doc['userId'],
        content: doc['content'],
        timestamp: doc['timestamp'],
        likes: doc['likes'],
        img: doc['img'],
        name: userData['name'],
        userName: userData['username'],
        userProfilePic: userData['profilePic'] ?? "",
        isLikedByCurrentUser: isLiked,
        commentCount: doc['commentCount'] ?? 0);
  }
}

// Cubit
class PostCubit extends Cubit<PostState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final sharedPreferencesService = SharedPreferencesService();
  final List<DocumentSnapshot> _posts = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  static const int postLimit = 10;
  List<Post> postList = [];

  PostCubit() : super(PostInitial());

  Future<void> fetchPosts({bool isRefresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      if (isRefresh) {
        _posts.clear();
        postList.clear();
        _lastDocument = null;
      }

      Query query = _firestore
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .limit(postLimit);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      QuerySnapshot postSnapshot = await query.get();

      for (DocumentSnapshot postDoc in postSnapshot.docs) {
        String userId = postDoc['userId'];
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(userId).get();
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        Post post = Post.fromDocument(postDoc, userData);
        postList.add(post);
      }

      _posts.addAll(postSnapshot.docs);
      _lastDocument = _posts.isNotEmpty ? _posts.last : null;

      emit(PostLoaded(
          posts: postList, hasMore: postSnapshot.docs.length == postLimit));
    } catch (e) {
      emit(PostError(message: e.toString()));
    } finally {
      _isLoading = false;
    }
  }

  Future<void> addPost(String content, File? image) async {
    // emit(PostAdding());
    String? imagedUrl;
    try {
      final userId = sharedPreferencesService.getString("userID");
      CollectionReference posts = _firestore.collection('posts');

      if (image != null) {
        imagedUrl = await _uploadImage(image);

        if (imagedUrl == null) return;
      }
      await posts.add({
        'userId': userId,
        'content': content,
        'img': imagedUrl ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'likedBy': [],
        "commentCount": 0
      });
      // emit(PostAdded());
      await fetchPosts(isRefresh: true); // Refresh posts after adding a new one

    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      String fileName = image.path.split('/').last;
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('posts/$fileName');
      UploadTask uploadTask = firebaseStorageRef.putFile(image);

      TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print('File uploaded at $downloadUrl');

      return downloadUrl;
    } catch (e) {}
  }

  // Future<void> likePost(String postId) async {
  //   try {
  //     final userId = sharedPreferencesService.getString("userID");

  //     DocumentReference postRef = _firestore.collection('posts').doc(postId);
  //     await _firestore.runTransaction((transaction) async {
  //       DocumentSnapshot postSnapshot = await transaction.get(postRef);
  //       if (!postSnapshot.exists) return;

  //       int currentLikes = postSnapshot['likes'];
  //       List<dynamic> likedBy = postSnapshot['likedBy'] ?? [];
  //       if (likedBy.contains(userId)) return;

  //       transaction.update(postRef, {
  //         'likes': likedBy.length + 1,
  //         'likedBy': FieldValue.arrayUnion([userId]),
  //       });
  //     });
  //     await fetchPosts(isRefresh: true); // Refresh posts after liking
  //   } catch (e) {
  //     emit(PostError(message: e.toString()));
  //   }
  // }

  // Future<void> unlikePost(String postId) async {
  //   try {
  //     final userId = sharedPreferencesService.getString("userID");

  //     DocumentReference postRef = _firestore.collection('posts').doc(postId);
  //     await _firestore.runTransaction((transaction) async {
  //       DocumentSnapshot postSnapshot = await transaction.get(postRef);
  //       if (!postSnapshot.exists) return;

  //       int currentLikes = postSnapshot['likes'];
  //       List<dynamic> likedBy = postSnapshot['likedBy'];
  //       if (!likedBy.contains(userId)) return;

  //       transaction.update(postRef, {
  //         'likes': currentLikes > 0 ? likedBy.length - 1 : 0,
  //         'likedBy': FieldValue.arrayRemove([userId]),
  //       });
  //     });
  //     await fetchPosts(isRefresh: true); // Refresh posts after unliking
  //   } catch (e) {
  //     emit(PostError(message: e.toString()));
  //   }
  // }

  Future<void> likePost(String postId) async {
    List<Post> currentPosts = (state as PostLoaded).posts;
    int postIndex = currentPosts.indexWhere((post) => post.postId == postId);
    if (postIndex != -1) {
      Post post = currentPosts[postIndex];
      Post updatedPost = post.copyWith(
        likes: post.likes + 1,
        isLikedByCurrentUser: true,
      );

      currentPosts[postIndex] = updatedPost;
      emit(PostLoaded(
          posts: List.from(currentPosts),
          hasMore: (state as PostLoaded).hasMore));

      _updateLikeInFirestore(postId, true);
    }
  }

  Future<void> unlikePost(String postId) async {
    List<Post> currentPosts = (state as PostLoaded).posts;
    int postIndex = currentPosts.indexWhere((post) => post.postId == postId);
    if (postIndex != -1) {
      Post post = currentPosts[postIndex];
      Post updatedPost = post.copyWith(
        likes: post.likes - 1,
        isLikedByCurrentUser: false,
      );

      currentPosts[postIndex] = updatedPost;
      emit(PostLoaded(
          posts: List.from(currentPosts),
          hasMore: (state as PostLoaded).hasMore));

      _updateLikeInFirestore(postId, false);
    }
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
      await fetchPosts(isRefresh: true); // Refresh posts after liking
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }
}
