// lib/models/feeling.dart
import '../constants/feeling_emojis.dart';

class Feeling {
  final String name;
  final String color;

  Feeling({
    required this.name,
    required this.color,
  });

  factory Feeling.fromJson(Map<String, dynamic> json) {
    return Feeling(
      name: json['name'],
      color: json['color'],
    );
  }

  String get emoji => feelingEmojis[name] ?? '';
}