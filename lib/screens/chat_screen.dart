import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:feels_mobile/viewmodels/current_user_provider.dart';
import 'package:feels_mobile/viewmodels/chat_provider.dart';
import 'package:feels_mobile/viewmodels/messages_provider.dart';
import 'package:feels_mobile/viewmodels/api_service_provider.dart';
import 'package:feels_mobile/viewmodels/feelings_provider.dart';
import 'package:feels_mobile/constants/colors.dart';
import 'package:feels_mobile/models/feeling.dart';
import 'package:feels_mobile/widgets/emotion_selector.dart';
import 'package:feels_mobile/widgets/chat_screen/chat_bubble.dart';
import 'package:feels_mobile/widgets/add_status_screen/emotion_map_builder.dart';

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

    final selectedEmotionKey = useState<String?>(null);
    final feelingsState = ref.watch(feelingsProvider);

    useEffect(() {
      Future.microtask(() {
        ref.read(feelingsProvider.notifier).loadFeelings();
      });
      return null;
    }, const []);

    var feelings = feelingsState.feelings.map(Feeling.fromJson).toList();

    feelings.insert(0, Feeling(name: "None", color: "#FFFFFF"));

    final emotions = buildEmotionsMap(feelings);

    final currentUser = ref.read(currentUserIdProvider).value;

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
              error: (error, stack) =>
                  Center(child: Text('Error: ${error.toString()}')),
              data: (messages) => ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[messages.length - 1 - index];
                  return MessageBubble(
                    message: message,
                    isMe: message.sender['uid'] == currentUser,
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 250,
                            child: TextField(
                              controller: textController,
                              decoration: const InputDecoration(
                                hintText: 'Type a message...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          EmotionSelector(
                            selectedEmotionKey: selectedEmotionKey,
                            feelings: feelings,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.textDim.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child:
                                  selectedEmotionKey.value != null &&
                                      emotions[selectedEmotionKey
                                              .value]?['emoji'] !=
                                          ''
                                  ? Text(
                                      emotions[selectedEmotionKey
                                              .value!]!['emoji'] ??
                                          '',
                                      style: const TextStyle(fontSize: 22),
                                    )
                                  : Icon(
                                      Icons.sentiment_neutral,
                                      color: AppColors.textDim,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (textController.text.trim().isEmpty) return;

                    try {
                      String? feeling;
                      if (selectedEmotionKey.value != null &&
                          emotions[selectedEmotionKey.value!] != null) {
                        if (selectedEmotionKey.value != 'None') {
                          feeling = selectedEmotionKey.value;
                        }
                      }

                      await ref
                          .read(apiServiceProvider)
                          .sendMessage(
                            chatId: chatId,
                            text: textController.text.trim(),
                            feelingName: feeling,
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
