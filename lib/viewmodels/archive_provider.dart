import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/post.dart';

/// State holding the user's own posts
class ArchiveState {
  final bool loading;
  final bool refreshing;
  final String? error;
  final List<Post> posts;

  const ArchiveState({
    this.loading = false,
    this.refreshing = false,
    this.error,
    this.posts = const [],
  });

  ArchiveState copyWith({
    bool? loading,
    bool? refreshing,
    String? error,
    List<Post>? posts,
  }) {
    return ArchiveState(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      error: error,
      posts: posts ?? this.posts,
    );
  }
}

class ArchiveNotifier extends StateNotifier<ArchiveState> {
  final ApiService _api;
  ArchiveNotifier(this._api) : super(const ArchiveState());

  Future<void> _fetch({required bool refresh}) async {
    state = state.copyWith(loading: !refresh, refreshing: refresh, error: null);
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');
      if (uid == null || uid.isEmpty) throw Exception('UID not found');

      final posts = await _api.getUserPosts(uid);
      state = state.copyWith(loading: false, refreshing: false, posts: posts);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        refreshing: false,
        error: e.toString(),
      );
    }
  }

  Future<void> load() => _fetch(refresh: false);
  Future<void> refresh() => _fetch(refresh: true);
}

final archiveProvider =
    StateNotifierProvider.autoDispose<ArchiveNotifier, ArchiveState>(
      (ref) => ArchiveNotifier(ApiService()),
    );
