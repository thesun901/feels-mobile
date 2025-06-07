import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../models/post.dart';

class StatsState {
  final bool loading;
  final bool refreshing;
  final String? error;
  final int readCount;
  final int feelingsCount;

  /// Map day → HEX color string derived z dominującego uczucia ("#FFAA33")
  final Map<DateTime, String> colorByDay;

  const StatsState({
    this.loading = false,
    this.refreshing = false,
    this.error,
    this.readCount = 0,
    this.feelingsCount = 0,
    this.colorByDay = const {},
  });

  StatsState copyWith({
    bool? loading,
    bool? refreshing,
    String? error,
    int? readCount,
    int? feelingsCount,
    Map<DateTime, String>? colorByDay,
  }) {
    return StatsState(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      error: error,
      readCount: readCount ?? this.readCount,
      feelingsCount: feelingsCount ?? this.feelingsCount,
      colorByDay: colorByDay ?? this.colorByDay,
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                  NOTIFIER                                  */
/* -------------------------------------------------------------------------- */

class StatsNotifier extends StateNotifier<StatsState> {
  final ApiService _api;
  StatsNotifier(this._api) : super(const StatsState());

  Future<void> _fetch({required bool refresh}) async {
    state = state.copyWith(loading: !refresh, refreshing: refresh, error: null);

    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');
      if (uid == null || uid.isEmpty) throw Exception('UID not saved');

      // 1. Wszystkie posty (żeby policzyć readCount)
      final allPosts = await _api.getPosts();
      final readCount = allPosts.length;

      // 2. Posty usera
      final userPosts = await _api.getUserPosts(uid);
      final feelingsCount = userPosts.length;

      // 3. Dominujący kolor na każdy dzień
      final Map<DateTime, String> colorByDay = {};
      final Map<DateTime, List<String>> bucket = {};
      for (final Post p in userPosts) {
        final d = DateTime(
          p.createdAt.year,
          p.createdAt.month,
          p.createdAt.day,
        );
        (bucket[d] ??= []).add(p.feeling.color); // hex string from API
      }

      bucket.forEach((day, list) {
        final dominantEntry = maxBy(
          list.groupListsBy((e) => e).entries,
          (e) => e.value.length,
        );
        final dominant = dominantEntry!.key;
        colorByDay[day] = dominant;
      });

      state = state.copyWith(
        loading: false,
        refreshing: false,
        readCount: readCount,
        feelingsCount: feelingsCount,
        colorByDay: colorByDay,
      );
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

final statsProvider =
    StateNotifierProvider.autoDispose<StatsNotifier, StatsState>(
      (ref) => StatsNotifier(ApiService()),
    );
