import 'package:feels_mobile/widgets/profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/post.dart';
import '../../constants/colors.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    // Zamiana koloru HEX na Color
    final Color feelingColor = Color(
      int.parse(post.feeling.color.replaceFirst('#', '0xff')),
    );
    final String feelingName = post.feeling.name;
    final String emoji = post.feeling.emoji;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Pasek emocji z dynamicznym kolorem i nazwą
          Container(
            decoration: BoxDecoration(
              color: feelingColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.centerRight,
            child: Text(
              feelingName,
              style: const TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Zawartość posta
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: feelingColor,
                      child: ProfilePicture(
                        size: 20,
                        username: post.authorUsername,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${post.authorUsername} feels... $feelingName $emoji',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            timeAgo(post.createdAt),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDim,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  post.body,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String timeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inMinutes < 1) return 'just now';
    if (duration.inMinutes < 60) return '${duration.inMinutes} minutes ago';
    if (duration.inHours < 24) return '${duration.inHours} hours ago';
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }
}
