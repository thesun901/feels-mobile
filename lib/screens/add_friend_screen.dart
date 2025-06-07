import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../constants/colors.dart';
import '../viewmodels/accounts_provider.dart';
import '../viewmodels/send_friend_request_provider.dart';
import '../widgets/friends_screen/friend_search_bar.dart';
import '../widgets/add_friend_screen/request_section.dart';
import '../widgets/add_friend_screen/new_friend_section.dart';

class AddFriendScreen extends ConsumerStatefulWidget {
  const AddFriendScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends ConsumerState<AddFriendScreen> {
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
            FriendsSearchBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              isFocused: _isSearchFocused,
            ),
            const SizedBox(height: 24),
            const RequestSection(),
            Divider(
              color: AppColors.textDim.withValues(alpha: 0.2),
              thickness: 1,
              height: 10,
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Add new friend',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: NewFriendSection(
                searchQuery: _searchQuery,
                accountsAsync: accountsAsync,
                sendRequest: sendRequest,
                sendRequestNotifier: sendRequestNotifier,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
