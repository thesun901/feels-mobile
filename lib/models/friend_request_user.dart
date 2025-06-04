class FriendRequestUser {
  final String uid;
  final String username;
  final String displayName;

  FriendRequestUser({
    required this.uid,
    required this.username,
    required this.displayName,
  });

  factory FriendRequestUser.fromJson(Map<String, dynamic> json) {
    return FriendRequestUser(
      uid: json['uid'],
      username: json['username'],
      displayName: json['display_name'],
    );
  }
}