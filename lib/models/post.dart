class Post {
  final String uid;
  final String body;
  final DateTime createdAt;
  final int likesCount;
  final String authorUsername;

  Post({
    required this.uid,
    required this.body,
    required this.createdAt,
    required this.likesCount,
    required this.authorUsername,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      uid: json['uid'],
      body: json['body'],
      createdAt: DateTime.parse(json['created_at']),
      likesCount: json['likes_count'] ?? 0,
      authorUsername: json['author_username'] ?? 'unknown',
    );
  }
}
