import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/friend_request.dart';
import 'feed_provider.dart';

final friendRequestsProvider = AsyncNotifierProvider<FriendRequestsNotifier, List<FriendRequest>>(
  FriendRequestsNotifier.new,
);

class FriendRequestsNotifier extends AsyncNotifier<List<FriendRequest>> {
  @override
  Future<List<FriendRequest>> build() async {
    final api = ref.watch(apiServiceProvider);
    // TODO: UWAGA PROWIZORKA !!!
    final token = 'dPyoEDWfT76E23qwt6wkvkSvjbyd8ick8ENfDGRvWUw';
    return await api.getPendingFriendRequests(token);
  }
}