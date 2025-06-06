import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'feed_provider.dart';

final unfriendProvider = FutureProvider.family<void, String>((ref, friendUid) async {
  final api = ref.read(apiServiceProvider);
  await api.unfriend(friendUid);
});