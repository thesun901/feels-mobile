import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:feels_mobile/models/chat.dart';
import 'package:feels_mobile/viewmodels/api_service_provider.dart';

final chatsProvider = FutureProvider.autoDispose<List<Chat>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getChats();
});