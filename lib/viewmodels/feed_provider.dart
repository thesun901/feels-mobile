import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/post.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final feedProvider = AsyncNotifierProvider<FeedNotifier, List<Post>>(
  FeedNotifier.new,
);

class FeedNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final api = ref.watch(apiServiceProvider);
    return await api.getPosts();
  }
}
