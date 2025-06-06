// lib/models/account.dart
class Account {
  final String uid;
  final String username;
  final String displayName;
  final int feelingsSharedCount;
  final String bio;

  Account({
    required this.uid,
    required this.username,
    required this.displayName,
    required this.feelingsSharedCount,
    required this.bio
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      uid: json['uid'],
      username: json['username'],
      displayName: json['display_name'],
      feelingsSharedCount: json['feelings_shared_count'] ?? 0,
      bio: json['bio'] ?? '',
    );
  }
}