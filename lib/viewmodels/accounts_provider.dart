import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/account.dart';
import 'feed_provider.dart';

class AccountsFilterParams {
  final bool excludeFriends;
  final bool onlyFriends;

  const AccountsFilterParams({
    this.excludeFriends = false,
    this.onlyFriends = false,
  });
}

class AccountsNotifier extends FamilyAsyncNotifier<List<Account>, AccountsFilterParams> {
  @override
  Future<List<Account>> build(AccountsFilterParams params) async {
    final api = ref.watch(apiServiceProvider);
    return await api.getAccounts(
      excludeFriends: params.excludeFriends,
      onlyFriends: params.onlyFriends,
    );
  }
}

final accountsProvider = AsyncNotifierProviderFamily<AccountsNotifier, List<Account>, AccountsFilterParams>(
  AccountsNotifier.new,
);