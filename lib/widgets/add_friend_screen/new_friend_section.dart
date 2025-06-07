import 'package:feels_mobile/models/account.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constants/colors.dart';
import '../../viewmodels/send_friend_request_provider.dart';
import 'add_friend_tile.dart';

class NewFriendSection extends StatelessWidget {
  const NewFriendSection({
    Key? key,
    required this.searchQuery,
    required this.accountsAsync,
    required this.sendRequest,
    required this.sendRequestNotifier,
  }) : super(key: key);

  final String searchQuery;
  final AsyncValue<List<Account>> accountsAsync;
  final AsyncValue<void> sendRequest;
  final SendFriendRequestNotifier sendRequestNotifier;

  @override
  Widget build(BuildContext context) {
    return accountsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) =>
          Text('Błąd: $err', style: const TextStyle(color: AppColors.angry)),
      data: (accounts) {
        final filtered = accounts.where((acc) {
          if (searchQuery.isEmpty) return false;
          return acc.username.toLowerCase().contains(searchQuery) ||
              acc.displayName.toLowerCase().contains(searchQuery);
        }).toList();

        if (filtered.isEmpty) {
          return const Center(
            child: Text(
              'No users found.',
              style: TextStyle(color: AppColors.textDim),
            ),
          );
        }

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, i) => AddFriendTile(
            user: filtered[i],
            sendRequest: sendRequest,
            sendRequestNotifier: sendRequestNotifier,
          ),
        );
      },
    );
  }
}
