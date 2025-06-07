import 'package:feels_mobile/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:feels_mobile/models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.cardBackground
              : (message.feeling != null
                    ? Color(
                        int.parse(
                          message.feeling!.color.replaceFirst('#', '0xff'),
                        ),
                      ).withValues(alpha: 0.75)
                    : Colors.grey[300]),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message.sender['username'] ?? 'Unknown',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: (message.feeling != null)
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            Text(
              message.text,
              style: TextStyle(color: isMe ? Colors.white : ((message.feeling != null)
                  ? Colors.white
                  : Colors.black)),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    color: isMe ? Colors.white70 : (message.feeling != null)
                        ? Colors.white
                        : Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
                if (message.feeling != null) ...[
                  const SizedBox(width: 16),
                  Text(
                    '${message.feeling!.name} ${message.feeling!.emoji}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isMe
                          ? Color(
                              int.parse(
                                message.feeling!.color.replaceFirst(
                                  '#',
                                  '0xff',
                                ),
                              ),
                            )
                          : Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
