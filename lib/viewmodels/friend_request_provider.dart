import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/friend_request.dart';
import 'feed_provider.dart';

final friendRequestsProvider =
    AsyncNotifierProvider.autoDispose<
      FriendRequestsNotifier,
      List<FriendRequest>
    >(FriendRequestsNotifier.new);

class FriendRequestsNotifier
    extends AutoDisposeAsyncNotifier<List<FriendRequest>> {
  @override
  Future<List<FriendRequest>> build() async {
    final api = ref.watch(apiServiceProvider);
    return await api.getPendingFriendRequests();
  }
}
