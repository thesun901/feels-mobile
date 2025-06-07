import './message.dart';

class Chat {
  final String uid;
  final List<String> participantUsernames;
  final Message? lastMessage;
  final DateTime? lastMessageTime;

  Chat({
    required this.uid,
    required this.participantUsernames,
    this.lastMessage,
    this.lastMessageTime,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      uid: json['uid'],
      participantUsernames: List<String>.from(
        (json['participants'] as List).map(
              (p) => p['username'] as String,
        ),
      ),
      lastMessage: json.containsKey('last_message')
          ? Message.fromJson(json['last_message'])
          : null,
      lastMessageTime: json.containsKey('last_message_at')
          ? DateTime.parse(json['last_message_at'])
          : null,

    );
  }
}
