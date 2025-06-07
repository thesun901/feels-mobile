import 'package:feels_mobile/widgets/profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../constants/colors.dart';
import '../viewmodels/friend_request_provider.dart';
import '../viewmodels/accounts_provider.dart';
import '../viewmodels/respond_to_friend_request_provider.dart';
import '../viewmodels/send_friend_request_provider.dart';

class AddFriendScreen extends ConsumerStatefulWidget {
  const AddFriendScreen({super.key});

  @override
  ConsumerState<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends ConsumerState<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final friendRequests = ref.watch(friendRequestsProvider);
    final accountsAsync = ref.watch(
      accountsProvider(const AccountsFilterParams(excludeFriends: true)),
    );
    final sendRequest = ref.watch(sendFriendRequestProvider);
    final sendRequestNotifier = ref.read(sendFriendRequestProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Add friend',
          style: TextStyle(color: AppColors.textLight),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textLight),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 400,
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: const TextStyle(color: AppColors.textLight),
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    hintStyle: const TextStyle(color: AppColors.textDim),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textDim,
                    ),
                    filled: true,
                    fillColor: _isSearchFocused
                        ? AppColors.cardBackground.withValues(alpha: 0.5)
                        : AppColors.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            friendRequests.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text(
                'Błąd: $err',
                style: const TextStyle(color: AppColors.angry),
              ),
              data: (requests) {
                final pendingRequests = requests
                    .where((req) => req.status == 'pending')
                    .toList();
                return pendingRequests.isNotEmpty
                    ? Column(
                        children: [
                          Row(
                            children: const [
                              Text(
                                'Requests',
                                style: TextStyle(
                                  color: AppColors.textLight,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...pendingRequests.map(
                            (req) => Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                leading: ProfilePicture(uid: req.uid),
                                title: Text(
                                  req.sender.username,
                                  style: const TextStyle(
                                    color: AppColors.textLight,
                                  ),
                                ),
                                subtitle: Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 0,
                                    vertical: 2,
                                  ),
                                  child: const Text(
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
                                      icon: const Icon(
                                        Icons.close,
                                        color: AppColors.textDim,
                                      ),
                                      onPressed: () async {
                                        try {
                                          await ref.read(
                                            respondToFriendRequestProvider(
                                              RespondToFriendRequestParams(
                                                requestId: req.uid,
                                                action: 'reject',
                                              ),
                                            ).future,
                                          );
                                          ref.invalidate(
                                            friendRequestsProvider,
                                          );
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Invitation rejected',
                                                ),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text('Błąd: $e'),
                                              ),
                                            );
                                          }
                                        }
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
                                      onPressed: () async {
                                        try {
                                          await ref.read(
                                            respondToFriendRequestProvider(
                                              RespondToFriendRequestParams(
                                                requestId: req.uid,
                                                action: 'accept',
                                              ),
                                            ).future,
                                          );
                                          ref.invalidate(
                                            friendRequestsProvider,
                                          );
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Invitation accepted',
                                                ),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text('Błąd: $e'),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      )
                    : const SizedBox();
              },
            ),
            Divider(
              color: AppColors.textDim.withValues(alpha: 0.2),
              thickness: 1,
              height: 10,
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Text(
                  'Add new friend',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: accountsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text(
                  'Błąd: $err',
                  style: const TextStyle(color: AppColors.angry),
                ),
                data: (accounts) {
                  final filtered = accounts.where((acc) {
                    if (_searchQuery.isEmpty) return false;
                    return acc.username.toLowerCase().contains(_searchQuery) ||
                        acc.displayName.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No users found.',
                        style: TextStyle(color: AppColors.textDim),
                      ),
                    );
                  }

                  return ListView(
                    children: filtered
                        .map(
                          (user) => Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              leading: ProfilePicture(uid: user.uid),
                              title: Text(
                                user.username,
                                style: const TextStyle(
                                  color: AppColors.textLight,
                                ),
                              ),
                              subtitle: Text(
                                user.displayName,
                                style: const TextStyle(
                                  color: AppColors.textDim,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.add_circle,
                                  color: AppColors.peaceful,
                                ),
                                onPressed: sendRequest.isLoading
                                    ? null
                                    : () async {
                                        try {
                                          await sendRequestNotifier.send(
                                            receiverUid: user.uid,
                                          );
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Invitation sent!',
                                                ),
                                              ),
                                            );
                                          }
                                          return;
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text('Błąd: $e'),
                                              ),
                                            );
                                          }
                                        }
                                      },
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
