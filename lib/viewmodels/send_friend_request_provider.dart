import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'feed_provider.dart';

final sendFriendRequestProvider =
    AsyncNotifierProvider<SendFriendRequestNotifier, void>(
      SendFriendRequestNotifier.new,
    );

class SendFriendRequestNotifier extends AsyncNotifier<void> {
  Future<void> send({required String receiverUid, String? message}) async {
    state = const AsyncLoading();
    final api = ref.read(apiServiceProvider);
    try {
      await api.sendFriendRequest(receiverUid: receiverUid, message: message);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  @override
  Future<void> build() async {}
}
