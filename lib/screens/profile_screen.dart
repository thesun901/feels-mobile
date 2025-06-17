import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:feels_mobile/constants/colors.dart';
import 'package:feels_mobile/viewmodels/account_provider.dart';
import 'package:feels_mobile/viewmodels/accounts_provider.dart';
import 'package:feels_mobile/viewmodels/edit_profile_provider.dart';
import 'package:feels_mobile/viewmodels/send_friend_request_provider.dart';
import 'package:feels_mobile/viewmodels/friend_request_provider.dart';

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
    final sendRequestNotifier = ref.read(sendFriendRequestProvider.notifier);
    final friendRequests = ref.watch(friendRequestsProvider);
    final editProfileNotifier = ref.read(editProfileProvider.notifier);

    final isEditing = useState(false);
    final bioController = useTextEditingController();

    return account.when(
      error: (err, stack) => Center(
        child: Text(
          'Error loading profile: $err',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      data: (accountData) {
        useEffect(() {
          bioController.text = accountData.bio;
          return null;
        }, [accountData.bio]);

        return Scaffold(
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
                    return friendRequests.when(
                      data: (requests) {
                        final pendingRequest = requests
                            .where(
                              (req) =>
                                  req.sender.uid == myUid.data &&
                                  req.receiver.uid == accountData.uid &&
                                  req.status == 'pending',
                            )
                            .firstOrNull;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: TextButton(
                            onPressed: isFriend
                                ? null
                                : pendingRequest != null
                                ? null
                                : () async {
                                    try {
                                      await sendRequestNotifier.send(
                                        receiverUid: accountData.uid,
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Friend request sent!'),
                                        ),
                                      );
                                      ref.invalidate(friendRequestsProvider);
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  },
                            style: TextButton.styleFrom(
                              foregroundColor: isFriend
                                  ? AppColors.textDim
                                  : pendingRequest != null
                                  ? AppColors.textDim
                                  : AppColors.peaceful,
                            ),
                            child: Text(
                              isFriend
                                  ? 'Friends'
                                  : pendingRequest != null
                                  ? 'Request Sent'
                                  : 'Add Friend',
                            ),
                          ),
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (err, stack) => Text('Error: $err'),
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
                      child: isEditing.value
                          ? TextField(
                              controller: bioController,
                              maxLines: 4,
                              autofocus: true,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter your bio',
                              ),
                            )
                          : Text(
                              accountData.bio.isNotEmpty
                                  ? accountData.bio
                                  : '(No bio yet.)',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    fontStyle: accountData.bio.isEmpty
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                  ),
                            ),
                    ),
                    if (myUid.hasData && myUid.data == accountData.uid)
                      isEditing.value
                          ? Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: AppColors.textDim,
                                  ),
                                  tooltip: 'Anuluj',
                                  onPressed: () {
                                    bioController.text = accountData.bio;
                                    isEditing.value = false;
                                  },
                                ),
                                Container(
                                  width: 1,
                                  height: 30,
                                  color: AppColors.textDim.withValues(alpha: 0.4),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.check,
                                    color: AppColors.peaceful,
                                  ),
                                  tooltip: 'Save',
                                  onPressed: () async {
                                    final newBio = bioController.text;
                                    if (newBio != accountData.bio) {
                                      try {
                                        await editProfileNotifier.editProfile(
                                          bio: newBio,
                                        );
                                        ref.invalidate(accountProvider(params));
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Bio updated!'),
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text('Error: $e')),
                                        );
                                      }
                                    }
                                    isEditing.value = false;
                                  },
                                ),
                              ],
                            )
                          : IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              tooltip: 'Edit bio',
                              onPressed: () {
                                isEditing.value = true;
                              },
                            ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
