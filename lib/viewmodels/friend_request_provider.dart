import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/friend_request.dart';
import '../services/api_service.dart';
import 'feed_provider.dart';

final friendRequestsProvider = AsyncNotifierProvider<FriendRequestsNotifier, List<FriendRequest>>(
  FriendRequestsNotifier.new,
);

class FriendRequestsNotifier extends AsyncNotifier<List<FriendRequest>> {
  @override
  Future<List<FriendRequest>> build() async {
    final api = ref.watch(apiServiceProvider);
    // TODO: UWAGA PROWIZORKA !!!
    final token = 'hwDhdw7sjjhFhdXj-oYluwg75LKp3JLpJtuqUrTn9A4';
    return await api.getPendingFriendRequests(token);
  }
}