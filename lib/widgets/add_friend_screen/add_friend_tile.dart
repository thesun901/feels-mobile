import 'package:feels_mobile/models/account.dart';
import 'package:feels_mobile/widgets/profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constants/colors.dart';
import '../../viewmodels/send_friend_request_provider.dart';
import '../../viewmodels/accounts_provider.dart';

class AddFriendTile extends ConsumerWidget {
  const AddFriendTile({
    super.key,
    required this.user,
    required this.sendRequest,
    required this.sendRequestNotifier,
  });

  final Account user;
  final AsyncValue<void> sendRequest;
  final SendFriendRequestNotifier sendRequestNotifier;

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
        leading: ProfilePicture(uid: user.uid),
        title: Text(
          user.username,
          style: const TextStyle(color: AppColors.textLight),
        ),
        subtitle: Text(
          user.displayName,
          style: const TextStyle(color: AppColors.textDim, fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: AppColors.peaceful),
          onPressed: sendRequest.isLoading
              ? null
              : () async {
                  try {
                    await sendRequestNotifier.send(receiverUid: user.uid);
                    // ignore: unused_result
                    ref.refresh(
                      accountsProvider(
                        const AccountsFilterParams(excludeFriends: true),
                      ),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invitation sent!')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Błąd: $e')));
                    }
                  }
                },
        ),
      ),
    );
  }
}
