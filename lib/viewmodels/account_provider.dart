import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/account.dart';
import 'feed_provider.dart';

class AccountParams {
  final String? uid;
  final String? username;

  const AccountParams(
    this.uid,
    this.username,
  );
}

class AccountNotifier extends FamilyAsyncNotifier<Account, AccountParams> {
  @override
  Future<Account> build(AccountParams params) async {
    final api = ref.watch(apiServiceProvider);
    var account = await api.getAccount(
      accountUid: params.uid,
      accountUsername: params.username,
    );
    return account;
  }
}

final accountProvider = AsyncNotifierProviderFamily<AccountNotifier, Account, AccountParams>(
  AccountNotifier.new,
);