import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:feels_mobile/viewmodels/api_service_provider.dart';
import 'package:feels_mobile/models/message.dart';

final messagesProvider = FutureProvider.autoDispose.family<List<Message>, String>((ref, chatId) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getMessages(chatId);
});