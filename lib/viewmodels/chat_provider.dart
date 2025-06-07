import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:feels_mobile/models/chat.dart';
import 'package:feels_mobile/viewmodels/api_service_provider.dart';

final chatProvider = FutureProvider.autoDispose.family<Chat, String>((ref, chatId) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getChat(chatId);
});