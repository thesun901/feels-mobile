import 'package:feels_mobile/models/friend_request.dart';
import 'package:feels_mobile/widgets/profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constants/colors.dart';
import '../../viewmodels/respond_to_friend_request_provider.dart';
import '../../viewmodels/friend_request_provider.dart';

class RequestTile extends ConsumerWidget {
  const RequestTile({Key? key, required this.request}) : super(key: key);

  final FriendRequest request;

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
        leading: ProfilePicture(uid: request.uid),
        title: Text(
          request.sender.username,
          style: const TextStyle(color: AppColors.textLight),
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            'New friend request!',
            style: TextStyle(
              color: AppColors.peaceful,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textDim),
              onPressed: () async {
                await _handleResponse(ref, context, 'reject');
              },
            ),
            Container(
              width: 1,
              height: 30,
              color: AppColors.textDim.withValues(alpha: 0.4),
              margin: const EdgeInsets.symmetric(horizontal: 4),
            ),
            IconButton(
              icon: const Icon(Icons.check, color: AppColors.peaceful),
              onPressed: () async {
                await _handleResponse(ref, context, 'accept');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleResponse(
    WidgetRef ref,
    BuildContext context,
    String action,
  ) async {
    try {
      await ref.read(
        respondToFriendRequestProvider(
          RespondToFriendRequestParams(requestId: request.uid, action: action),
        ).future,
      );
      ref.invalidate(friendRequestsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              action == 'accept'
                  ? 'Invitation accepted'
                  : 'Invitation rejected',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Błąd: $e')));
      }
    }
  }
}
