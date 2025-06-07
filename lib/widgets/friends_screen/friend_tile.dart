import 'package:feels_mobile/models/account.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constants/colors.dart';
import '../profile_picture.dart';
import 'action_buttons.dart';

class FriendTile extends ConsumerWidget {
  const FriendTile({super.key, required this.friend});

  final Account friend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        subtitle: Text(
          friend.username,
          style: const TextStyle(color: AppColors.textDim, fontSize: 12),
        ),
        trailing: ActionButtons(friend: friend),
      ),
    );
  }
}
