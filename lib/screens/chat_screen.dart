import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final chatProvider = FutureProvider.autoDispose.family<Chat, String>((ref, chatId) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getChat(chatId);
});

final messagesProvider = FutureProvider.autoDispose.family<List<Message>, String>((ref, chatId) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getMessages(chatId);
});

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class ChatScreen extends HookConsumerWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Set up periodic refresh every 10 seconds
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 10), (timer) {
        ref.invalidate(chatProvider(chatId));
        ref.invalidate(messagesProvider(chatId));
      });
      return () => timer.cancel();
    }, []);

    final chatAsync = ref.watch(chatProvider(chatId));
    final messagesAsync = ref.watch(messagesProvider(chatId));

    final textController = useTextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: chatAsync.when(
          loading: () => const Text('Loading...'),
          error: (error, stack) => Text('Error: ${error.toString()}'),
          data: (chat) => Text(chat.participantUsernames.join(', ')),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: ${error.toString()}')),
              data: (messages) => ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[messages.length - 1 - index];
                  return MessageBubble(
                    message: message,
                    isMe: message.sender['uid'] == ref.read(currentUserIdProvider).value,
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (textController.text.trim().isEmpty) return;

                    try {
                       await ref.read(apiServiceProvider).sendMessage(
                        chatId: chatId,
                        text: textController.text.trim(),
                      );
                      textController.clear();
                      // Refresh messages after sending
                      ref.invalidate(messagesProvider(chatId));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to send message: $e')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).primaryColor.withValues(alpha: 0.8)
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message.sender['username'] ?? 'Unknown',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            Text(
              message.text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey[600],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

// You'll need to add this provider to get the current user's ID
final currentUserIdProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('uid') ?? '';
});