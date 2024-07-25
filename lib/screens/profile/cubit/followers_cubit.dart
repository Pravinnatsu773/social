import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:social4/common/model/user_model.dart';

part 'followers_state.dart';

class FollowersCubit extends Cubit<FollowersState> {
  FollowersCubit() : super(FollowersInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  fetchFollowingUsers(
    String userId,
    List<dynamic> followers,
    List<dynamic> following,
  ) async {
    CollectionReference userRef = _firestore.collection('users');

    List<UserModel> followerUserList = [];
    for (var id in followers) {
      DocumentSnapshot userData = await userRef.doc(id).get();

      followerUserList
          .add(UserModel.fromMap(userData.data() as Map<String, dynamic>));
    }

    List<UserModel> followingUserList = [];
    for (var id in following) {
      DocumentSnapshot userData = await userRef.doc(id).get();

      followingUserList
          .add(UserModel.fromMap(userData.data() as Map<String, dynamic>));
    }

    emit(FollowersLoaded(followerUserList, followingUserList));
  }
}
