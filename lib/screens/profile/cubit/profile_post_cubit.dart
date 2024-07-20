import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:social4/common/model/user_model.dart';
import 'package:social4/screens/post/cubit/post_cubit.dart';
import 'package:social4/service/shared_preference_service.dart';

part 'profile_post_state.dart';

class ProfilePostCubit extends Cubit<ProfilePostState> {
  ProfilePostCubit() : super(ProfilePostInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final sharedPreferencesService = SharedPreferencesService();
  final List<DocumentSnapshot> _posts = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  static const int postLimit = 10;
  List<Post> postList = [];

  Future<void> fetchPosts(
      {bool isRefresh = false,
      bool isMe = false,
      required UserModel userModelData}) async {
    UserModel userData = userModelData;

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
          .where("userId", isEqualTo: userData.id)
          .orderBy('timestamp', descending: true)
          .limit(postLimit);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      QuerySnapshot postSnapshot = await query.get();

      for (DocumentSnapshot postDoc in postSnapshot.docs) {
        Post post = Post.fromDocument(postDoc, userData.toMap());
        postList.add(post);
      }

      _posts.addAll(postSnapshot.docs);
      _lastDocument = _posts.isNotEmpty ? _posts.last : null;

      emit(ProfilePostLoaded(
          posts: postList, hasMore: postSnapshot.docs.length == postLimit));
    } catch (e) {
      emit(ProfilePostError(message: e.toString()));
    } finally {
      _isLoading = false;
    }
  }

  Future<void> likePost(String postId) async {
    List<Post> currentPosts = (state as ProfilePostLoaded).posts;
    int postIndex = currentPosts.indexWhere((post) => post.postId == postId);
    if (postIndex != -1) {
      Post post = currentPosts[postIndex];
      Post updatedPost = post.copyWith(
        likes: post.likes + 1,
        isLikedByCurrentUser: true,
      );

      currentPosts[postIndex] = updatedPost;
      emit(ProfilePostLoaded(
          posts: List.from(currentPosts),
          hasMore: (state as ProfilePostLoaded).hasMore));

      _updateLikeInFirestore(postId, true);
    }
  }

  Future<void> unlikePost(String postId) async {
    List<Post> currentPosts = (state as ProfilePostLoaded).posts;
    int postIndex = currentPosts.indexWhere((post) => post.postId == postId);
    if (postIndex != -1) {
      Post post = currentPosts[postIndex];
      Post updatedPost = post.copyWith(
        likes: post.likes - 1,
        isLikedByCurrentUser: false,
      );

      currentPosts[postIndex] = updatedPost;
      emit(ProfilePostLoaded(
          posts: List.from(currentPosts),
          hasMore: (state as ProfilePostLoaded).hasMore));

      _updateLikeInFirestore(postId, false);
    }
  }

  _updateLikeInFirestore(String postId, bool isLike) async {
    try {
      final userId = sharedPreferencesService.getString("userID");
      final name = sharedPreferencesService.getString("name");
      final username = sharedPreferencesService.getString("userName");
      final profilePic = sharedPreferencesService.getString("profilePic");

      final bio = sharedPreferencesService.getString("bio");

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
      await fetchPosts(
          isRefresh: true,
          userModelData: UserModel(
              id: userId ?? "",
              name: name ?? "",
              username: username ?? "",
              profilePic: profilePic ?? "",
              bio: bio ?? "")); // Refresh posts after liking
    } catch (e) {
      emit(ProfilePostError(message: e.toString()));
    }
  }
}
