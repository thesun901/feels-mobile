import 'dart:ui';
import 'package:feels_mobile/constants/feeling_emojis.dart';
import 'package:feels_mobile/models/feeling.dart';

Map<String, Map<String, dynamic>> buildEmotionsMap(List<Feeling> feelings) {
  final Map<String, Map<String, dynamic>> emotions = {};
  for (final feeling in feelings) {
    emotions[feeling.name] = {
      'emoji': feelingEmojis[feeling.name] ?? '',
      'color': _hexToColor(feeling.color),
    };
  }
  return emotions;
}

Color _hexToColor(String hex) {
  hex = hex.replaceFirst('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  return Color(int.parse(hex, radix: 16));
}