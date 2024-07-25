part of 'followers_cubit.dart';

@immutable
class FollowersState {}

class FollowersInitial extends FollowersState {}

class FollowersLoaded extends FollowersState {
  final List<UserModel> followerUsers;
  final List<UserModel> followingUsers;

  FollowersLoaded(this.followerUsers, this.followingUsers);
}
