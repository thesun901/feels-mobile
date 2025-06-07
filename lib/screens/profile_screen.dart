import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import '../viewmodels/account_provider.dart';
import '../viewmodels/accounts_provider.dart';

class ProfileScreen extends HookConsumerWidget {
  final String? accountUid;
  final String? username;

  const ProfileScreen({super.key, this.accountUid, this.username});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = useMemoized(() => AccountParams(accountUid, username), [
      accountUid,
      username,
    ]);
    final account = ref.watch(accountProvider(params));

    final friends = ref.watch(
      accountsProvider(const AccountsFilterParams(onlyFriends: true)),
    );

    final prefs = SharedPreferences.getInstance();

    final myUid = useFuture(prefs.then((prefs) => prefs.getString('uid')));

    return account.when(
      error: (err, stack) => Center(
        child: Text(
          'Error loading profile: $err',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      data: (accountData) => Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
          actions: [
            if (myUid.hasData && myUid.data != accountData.uid) ...[
              friends.when(
                data: (friendsList) {
                  final isFriend = friendsList.any(
                    (f) => f.uid == accountData.uid,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextButton(
                      onPressed: isFriend ? null : null,
                      // TODO: Implement add/remove friend functionality
                      child: Text(isFriend ? 'Remove friend' : 'Add Friend'),
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text('Error loading friends: $err'),
              ),
            ],
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.textDim,
                child: Icon(
                  Icons.person,
                  color: AppColors.cardBackground,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                accountData.displayName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '@${accountData.username}',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
              if (accountData.createdAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Joined on ${DateFormat('yMMMd').format(accountData.createdAt!)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textDim),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      accountData.bio.isNotEmpty
                          ? accountData.bio
                          : '(No bio yet.)',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontStyle: accountData.bio.isEmpty
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                  ),
                  if (myUid.hasData && myUid.data == accountData.uid)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'Edit bio',
                      onPressed: () =>
                          {}, // TODO: Implement edit bio functionality
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
