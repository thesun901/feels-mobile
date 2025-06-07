import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../services/api_service.dart';

class FeelingsState {
  final List<Map<String, dynamic>> feelings;
  final bool isLoading;
  final String? error;

  FeelingsState({this.feelings = const [], this.isLoading = false, this.error});

  FeelingsState copyWith({
    List<Map<String, dynamic>>? feelings,
    bool? isLoading,
    String? error,
  }) {
    return FeelingsState(
      feelings: feelings ?? this.feelings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FeelingsNotifier extends StateNotifier<FeelingsState> {
  FeelingsNotifier() : super(FeelingsState());

  Future<void> loadFeelings() async {
    print('loadFeelings wywołane'); // <-- dodaj to
    state = state.copyWith(isLoading: true, error: null);
    try {
      final feelings = await ApiService().fetchFeelings();
      state = state.copyWith(feelings: feelings, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final feelingsProvider = StateNotifierProvider<FeelingsNotifier, FeelingsState>(
      (ref) => FeelingsNotifier(),
);