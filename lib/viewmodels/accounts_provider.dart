// lib/viewmodels/accounts_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/account.dart';
import '../services/api_service.dart';
import 'feed_provider.dart';

final accountsProvider = AsyncNotifierProvider<AccountsNotifier, List<Account>>(
  AccountsNotifier.new,
);

class AccountsNotifier extends AsyncNotifier<List<Account>> {
  @override
  Future<List<Account>> build() async {
    final api = ref.watch(apiServiceProvider);
    return await api.getAccounts();
  }
}