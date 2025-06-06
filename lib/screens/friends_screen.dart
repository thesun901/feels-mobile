import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../constants/colors.dart';
import '../models/account.dart';
import '../viewmodels/accounts_provider.dart';
import '../services/api_service.dart';
import '../viewmodels/feed_provider.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
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
    final accountsAsync = ref.watch(
      accountsProvider(const AccountsFilterParams(onlyFriends: true)),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Your Friends',
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
                    hintText: 'Search friends...',
                    hintStyle: const TextStyle(color: AppColors.textDim),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textDim,
                    ),
                    filled: true,
                    fillColor: _isSearchFocused
                        ? AppColors.cardBackground.withOpacity(0.5)
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
            Expanded(
              child: accountsAsync.when(
                data: (friends) {
                  final filtered = friends.where((a) =>
                  a.displayName.toLowerCase().contains(_searchQuery) ||
                      a.username.toLowerCase().contains(_searchQuery)
                  ).toList();

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
                    itemBuilder: (context, index) {
                      final friend = filtered[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.textDim,
                            child: Icon(
                              Icons.person,
                              color: AppColors.cardBackground,
                            ),
                          ),
                          title: Text(
                            friend.displayName,
                            style: const TextStyle(
                              color: AppColors.textLight,
                            ),
                          ),
                          subtitle: Text(
                            friend.username,
                            style: const TextStyle(
                              color: AppColors.textDim,
                              fontSize: 12,
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'unfriend') {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Unfriend'),
                                    content: Text('Are you sure you want to unfriend ${friend.displayName}?'),
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
                                  final api = ref.read(apiServiceProvider);
                                  // await api.unfriend(friend.uid);
                                  ref.invalidate(
                                    accountsProvider(const AccountsFilterParams(onlyFriends: true)),
                                  );
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
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    'Błąd: $e',
                    style: const TextStyle(color: AppColors.angry),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}