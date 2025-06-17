import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/post.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final feedProvider = AsyncNotifierProvider<FeedNotifier, List<Post>>(
  FeedNotifier.new,
);

class FeedNotifier extends AsyncNotifier<List<Post>> {
  Timer? _timer;

  @override
  Future<List<Post>> build() async {
    final api = ref.watch(apiServiceProvider);

    // Schedule automatic refresh every 120 seconds
    _timer = Timer.periodic(const Duration(seconds: 120), (_) {
      // Invalidate this provider so build() runs again
      ref.invalidateSelf();
    });
    // Cancel timer when provider is disposed
    ref.onDispose(() {
      _timer?.cancel();
    });

    // Initial data fetch
    final allPosts = await api.getPosts();

    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    final recentPosts = allPosts
        .where((post) => post.createdAt.isAfter(cutoff))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return recentPosts;
  }
}
