import 'package:feels_mobile/models/account.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../viewmodels/accounts_provider.dart';
import '../../viewmodels/unfriend_provider.dart';

class ActionButtons extends ConsumerWidget {
  const ActionButtons({super.key, required this.friend});

  final Account friend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.message_outlined),
          tooltip: 'Chat with ${friend.displayName}',
          onPressed: () {},
        ),
        PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'unfriend') {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Unfriend'),
                  content: Text(
                    'Are you sure you want to unfriend ${friend.displayName}?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                try {
                  await ref.read(unfriendProvider(friend.uid).future);
                  ref.invalidate(
                    accountsProvider(
                      const AccountsFilterParams(onlyFriends: true),
                    ),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Friend deleted')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              }
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'unfriend',
              child: Text('Delete Friend'),
            ),
          ],
        ),
      ],
    );
  }
}
