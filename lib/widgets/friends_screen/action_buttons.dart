import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:feels_mobile/models/chat.dart';
import 'package:feels_mobile/models/account.dart';
import 'package:feels_mobile/screens/chat_screen.dart';
import 'package:feels_mobile/viewmodels/accounts_provider.dart';
import 'package:feels_mobile/viewmodels/unfriend_provider.dart';
import 'package:feels_mobile/viewmodels/api_service_provider.dart';

class ActionButtons extends ConsumerWidget {
  const ActionButtons({super.key, required this.friend, required this.existingChat});

  final Account friend;
  final Chat? existingChat;

  Future<void> _handleChatButtonPressed(BuildContext context, WidgetRef ref) async {
    try {
      final apiService = ref.read(apiServiceProvider);

      if (existingChat != null) {
        // Navigate to existing chat
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(chatId: existingChat!.uid),
            ),
          );
        }
      } else {
        // Create new chat and navigate to it
        final newChat = await apiService.createChat(friend.username);
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(chatId: newChat.uid),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start chat: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.message_outlined),
          tooltip: 'Chat with ${friend.displayName}',
          onPressed: () => _handleChatButtonPressed(context, ref),
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