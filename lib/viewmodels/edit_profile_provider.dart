import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/api_service.dart';
import 'feed_provider.dart';

final editProfileProvider =
AsyncNotifierProvider<EditProfileNotifier, void>(
  EditProfileNotifier.new,
);

class EditProfileNotifier extends AsyncNotifier<void> {
  Future<void> editProfile({
    String? displayName,
    String? bio,
    String? email,
  }) async {
    state = const AsyncLoading();
    final api = ref.read(apiServiceProvider);
    try {
      await api.updateProfile(
        displayName: displayName,
        bio: bio,
        email: email,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  @override
  Future<void> build() async {}
}