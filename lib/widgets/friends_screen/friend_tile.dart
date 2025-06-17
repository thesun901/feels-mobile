import 'package:feels_mobile/models/account.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../constants/colors.dart';
import '../../models/chat.dart';
import '../profile_picture.dart';
import 'action_buttons.dart';

class FriendTile extends HookConsumerWidget {
  const FriendTile({super.key, required this.friend, required this.existingChat});

  final Account friend;
  final Chat? existingChat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    Widget subtitleWidget;

    if (existingChat != null && existingChat?.lastMessage != null) {
      final prefix = existingChat?.lastMessage?.sender['username'] == friend.username ? '${existingChat?.lastMessage?.sender['username']}: ' : 'You: ';
      subtitleWidget = Text(
        prefix + (existingChat?.lastMessage?.text ?? friend.username),
        style: const TextStyle(color: AppColors.textDim, fontSize: 12),
      );
    } else {
      subtitleWidget = Text(
        friend.username,
        style: const TextStyle(color: AppColors.textDim, fontSize: 12),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: ProfilePicture(username: friend.username),
        title: Text(
          friend.displayName,
          style: const TextStyle(color: AppColors.textLight),
        ),
        subtitle: subtitleWidget,
        trailing: ActionButtons(friend: friend, existingChat: existingChat),
      ),
    );
  }
}
