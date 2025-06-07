import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class AddPostState {
  final bool isLoading;
  final String? error;
  final bool success;

  AddPostState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  AddPostState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return AddPostState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

class AddPostNotifier extends StateNotifier<AddPostState> {
  AddPostNotifier() : super(AddPostState());

  Future<void> addPost({required String body, String? feelingName}) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      await ApiService().createPost(body: body, feelingName: feelingName);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = AddPostState();
  }
}

final addPostProvider =
StateNotifierProvider<AddPostNotifier, AddPostState>((ref) => AddPostNotifier());