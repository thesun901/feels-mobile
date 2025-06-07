
import 'feeling.dart';

class Message {
  final String uid;
  final String text;
  final Map<String, String> sender;
  final DateTime createdAt;
  final Feeling? feeling;

  Message({
    required this.uid,
    required this.text,
    required this.sender,
    required this.createdAt,
    this.feeling,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      uid: json['uid'] as String,
      text: json['text'] as String,
      sender: Map<String, String>.from(json['sender'] as Map),
      createdAt: DateTime.parse(json['created_at'] as String),
      feeling: (json.containsKey('feeling') && json['feeling'] != null)
          ? Feeling.fromJson(json['feeling'] as Map<String, dynamic>)
          : null,
    );
  }
}