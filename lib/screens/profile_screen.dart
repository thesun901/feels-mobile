import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../constants/colors.dart';
import '../viewmodels/account_provider.dart';

class ProfileScreen extends HookConsumerWidget {
  final String? accountUid;
  final String? username;
  final bool isOwnProfile;

  const ProfileScreen({
    super.key,
    this.accountUid,
    this.username,
    this.isOwnProfile = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = useMemoized(() => AccountParams(accountUid, username), [accountUid, username]);

    final account = ref.watch(accountProvider(params));
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: account.when(
          error: (err, stack) => Center(
            child: Text(
              'Error loading profile: $err',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          data: (accountData) => Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.textDim,
                child: Icon(Icons.person, color: AppColors.cardBackground, size: 48),
              ),
              const SizedBox(height: 20),
              Text(
                accountData.displayName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '@${accountData.username}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      accountData.bio.isNotEmpty ? accountData.bio : 'No bio yet.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  if (isOwnProfile)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'Edit bio',
                      onPressed: () => {} // TODO: Implement edit bio functionality
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
