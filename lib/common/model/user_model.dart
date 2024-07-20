class UserModel {
  final String id;
  final String name;
  final String username;
  final String profilePic;
  final String bio;

  UserModel(
      {required this.id,
      required this.name,
      required this.username,
      required this.profilePic,
      required this.bio});

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
      name: map['name'],
      username: map['username'],
      profilePic: map['profilePic'],
      bio: map['bio'],
    );
  }
}
