import 'package:feels_mobile/widgets/friends_screen/friend_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../viewmodels/accounts_provider.dart';
import '../widgets/friends_screen/friend_list.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool get _isSearchFocused => _searchFocusNode.hasFocus;
  String get _searchQuery => _searchController.text.trim().toLowerCase();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() => setState(() {}));
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(
      accountsProvider(const AccountsFilterParams(onlyFriends: true)),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          FriendsSearchBar(
            controller: _searchController,
            focusNode: _searchFocusNode,
            isFocused: _isSearchFocused,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: FriendList(
              accountsAsync: accountsAsync,
              searchQuery: _searchQuery,
            ),
          ),
        ],
      ),
    );
  }
}
