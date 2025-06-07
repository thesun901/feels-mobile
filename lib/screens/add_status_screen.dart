import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../constants/colors.dart';
import '../models/feeling.dart';
import '../constants/feeling_emojis.dart';
import '../viewmodels/add_post_provider.dart';
import '../viewmodels/feelings_provider.dart';

Map<String, Map<String, dynamic>> buildEmotionsMap(List<Feeling> feelings) {
  final Map<String, Map<String, dynamic>> emotions = {};
  for (final feeling in feelings) {
    emotions[feeling.name] = {
      'emoji': feelingEmojis[feeling.name] ?? '',
      'color': _hexToColor(feeling.color),
    };
  }
  return emotions;
}

Color _hexToColor(String hex) {
  hex = hex.replaceFirst('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  return Color(int.parse(hex, radix: 16));
}

class AddStatusScreen extends HookConsumerWidget {
  const AddStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final selectedEmotionKey = useState<String?>(null);

    final feelingsState = ref.watch(feelingsProvider);
    final addPostState = ref.watch(addPostProvider);
    final addPostNotifier = ref.read(addPostProvider.notifier);

    useEffect(() {
      Future.microtask(() {
        ref.read(feelingsProvider.notifier).loadFeelings();
      });
      return null;
    }, const []);

    // Obsługa sukcesu - zamknięcie ekranu po dodaniu statusu
    useEffect(() {
      if (addPostState.success) {
        Future.microtask(() {
          Navigator.of(context).pop();
          addPostNotifier.reset();
        });
      }
      return null;
    }, [addPostState.success]);

    final emotions = buildEmotionsMap(
      feelingsState.feelings.map(Feeling.fromJson).toList(),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Add status'),
        centerTitle: true,
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.textLight,
        elevation: 0,
      ),
      backgroundColor: AppColors.darkBackground,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'How are we feeling?',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (feelingsState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (feelingsState.error != null)
              Text(
                'Błąd: ${feelingsState.error}',
                style: const TextStyle(color: Colors.red),
              )
            else
              GestureDetector(
                onTap: () async {
                  final emotionKey = await showModalBottomSheet<String>(
                    context: context,
                    backgroundColor: AppColors.cardBackground,
                    builder: (ctx) => ListView(
                      shrinkWrap: true,
                      children: emotions.entries.map((entry) {
                        return ListTile(
                          onTap: () => Navigator.pop(ctx, entry.key),
                          title: Container(
                            decoration: BoxDecoration(
                              color: AppColors.tired.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.zero,
                            child: Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: entry.value['color'] as Color,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  entry.value['emoji'] as String,
                                  style: const TextStyle(fontSize: 22),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 2,
                                  height: 28,
                                  color: AppColors.textDim.withOpacity(0.3),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        );
                      }).toList(),
                    ),
                  );
                  if (emotionKey != null) {
                    selectedEmotionKey.value = emotionKey;
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.textDim,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      selectedEmotionKey.value != null && emotions[selectedEmotionKey.value!] != null
                          ? Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: emotions[selectedEmotionKey.value!]!['color'] as Color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            emotions[selectedEmotionKey.value!]!['emoji'] as String,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            selectedEmotionKey.value!,
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                          : const Text(
                        'Select emotion',
                        style: TextStyle(
                          color: AppColors.textDim,
                          fontSize: 16,
                        ),
                      ),
                      const Icon(Icons.expand_more, color: AppColors.textDim),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              maxLines: 4,
              style: const TextStyle(color: AppColors.textLight),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.cardBackground.withOpacity(0.8),
                hintText: 'How are you today?',
                hintStyle: const TextStyle(color: AppColors.textDim),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
            ),
            if (addPostState.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Błąd: ${addPostState.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (addPostState.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Center(child: CircularProgressIndicator()),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (selectedEmotionKey.value != null && !addPostState.isLoading)
                    ? () async {
                  await addPostNotifier.addPost(
                    body: controller.text,
                    feelingName: selectedEmotionKey.value,
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.peaceful,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('Add status'),
              )
            ),
          ],
        ),
      ),
    );
  }
}