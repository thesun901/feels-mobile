import 'package:feels_mobile/models/account.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constants/colors.dart';
import 'friend_tile.dart';

class FriendList extends ConsumerWidget {
  const FriendList({
    super.key,
    required this.accountsAsync,
    required this.searchQuery,
  });

  final AsyncValue<List<Account>> accountsAsync;
  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return accountsAsync.when(
      data: (friends) {
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

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) => FriendTile(friend: filtered[index]),
        );
      },
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
