import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'feed_provider.dart';

final respondToFriendRequestProvider = AsyncNotifierProvider.autoDispose
    .family<RespondToFriendRequestNotifier, void, RespondToFriendRequestParams>(
  RespondToFriendRequestNotifier.new,
);

class RespondToFriendRequestParams {
  final String requestId;
  final String action; // 'accept' lub 'reject'

  RespondToFriendRequestParams({required this.requestId, required this.action});
}

class RespondToFriendRequestNotifier
    extends AutoDisposeFamilyAsyncNotifier<void, RespondToFriendRequestParams> {
  @override
  Future<void> build(RespondToFriendRequestParams params) async {
    final api = ref.watch(apiServiceProvider);
    await api.respondToFriendRequest(
      requestId: params.requestId,
      action: params.action,
    );
  }
}