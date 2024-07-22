class UserModel {
  final String id;
  final String name;
  final String username;
  final String profilePic;
  final String bio;

  final List? followers;
  final List? following;
  final bool isFollowedByMe;
  final String fcmToken;

  UserModel(
      {required this.id,
      required this.name,
      required this.username,
      required this.profilePic,
      required this.bio,
      this.followers,
      this.following,
      this.isFollowedByMe = false,
      this.fcmToken = ""});
  UserModel copyWith({
    String? id,
    String? name,
    String? username,
    String? profilePic,
    String? bio,
    List? followers,
    List? following,
    bool? isFollowedByMe,
  }) {
    return UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        username: username ?? this.username,
        profilePic: profilePic ?? this.profilePic,
        bio: bio ?? this.bio,
        followers: followers ?? this.followers,
        following: following ?? this.following,
        isFollowedByMe: isFollowedByMe ?? this.isFollowedByMe);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'profilePic': profilePic,
      'bio': bio
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        id: map['id'],
        name: map['name'] ?? "",
        username: map['username'] ?? "",
        profilePic: map['profilePic'] ?? "",
        bio: map['bio'] ?? "",
        followers: map['followers'] != null ? (map['followers'] as List?) : [],
        following: map['following'] != null ? (map['following'] as List?) : [],
        isFollowedByMe: false,
        fcmToken: map['fcmToken']);
  }
}
