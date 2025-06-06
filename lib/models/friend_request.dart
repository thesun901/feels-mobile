import 'friend_request_user.dart';

class FriendRequest {
  final String uid;
  final String status;
  final String? message;
  final DateTime? createdAt;
  final DateTime? respondedAt;
  final FriendRequestUser sender;
  final FriendRequestUser receiver;

  FriendRequest({
    required this.uid,
    required this.status,
    this.message,
    this.createdAt,
    this.respondedAt,
    required this.sender,
    required this.receiver,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      uid: json['uid'],
      status: json['status'],
      message: json['message'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      respondedAt: json['responded_at'] != null ? DateTime.parse(json['responded_at']) : null,
      sender: FriendRequestUser.fromJson(json['sender']),
      receiver: FriendRequestUser.fromJson(json['receiver']),
    );
  }
}