import 'package:feels_mobile/models/account.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../constants/colors.dart';
import '../../models/chat.dart';
import 'friend_tile.dart';

class FriendList extends ConsumerWidget {
  const FriendList({
    super.key,
    required this.accountsAsync,
    required this.chatsAsync,
    required this.searchQuery,
  });

  final AsyncValue<List<Account>> accountsAsync;
  final AsyncValue<List<Chat>> chatsAsync;
  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return accountsAsync.when(
      data: (friends) => chatsAsync.when(
        data: (chats) {
          final filtered = friends
              .where(
                (a) =>
            a.displayName.toLowerCase().contains(searchQuery) ||
                a.username.toLowerCase().contains(searchQuery),
          )
              .toList();

          if (filtered.isEmpty) {
            return const Center(
              child: Text(
                'No friends.',
                style: TextStyle(color: AppColors.textDim),
              ),
            );
          }

          // Create a map of username to chat for quick lookup
          final Map<String, Chat?> chatMap = {};

          for (final friend in filtered) {
            Chat? matchingChat;

            for (final chat in chats) {
              if (chat.participantUsernames.contains(friend.username)) {
                matchingChat = chat;
                break;
              }
            }

            chatMap[friend.username] = matchingChat;
          }

          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) => FriendTile(friend: filtered[index], existingChat: chatMap[filtered[index].username]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Error loading chats: $e',
            style: const TextStyle(color: AppColors.angry),
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          'Error: $e',
          style: const TextStyle(color: AppColors.angry),
        ),
      ),
    );
  }
}
