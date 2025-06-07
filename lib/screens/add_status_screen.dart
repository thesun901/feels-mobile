import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:feels_mobile/constants/colors.dart';
import 'package:feels_mobile/models/feeling.dart';
import 'package:feels_mobile/viewmodels/add_post_provider.dart';
import 'package:feels_mobile/viewmodels/feelings_provider.dart';
import 'package:feels_mobile/widgets/add_status_screen/emotion_map_builder.dart';
import 'package:feels_mobile/widgets/emotion_selector.dart';

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
              EmotionSelector(
                feelings: feelingsState.feelings.map(Feeling.fromJson).toList(),
                selectedEmotionKey: selectedEmotionKey,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.textDim),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      selectedEmotionKey.value != null &&
                              emotions[selectedEmotionKey.value!] != null
                          ? Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color:
                                        emotions[selectedEmotionKey
                                                .value!]!['color']
                                            as Color,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  emotions[selectedEmotionKey.value!]!['emoji']
                                      as String,
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
                fillColor: AppColors.cardBackground.withValues(alpha: 0.8),
                hintText: 'How are you today?',
                hintStyle: const TextStyle(color: AppColors.textDim),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
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
                onPressed:
                    (selectedEmotionKey.value != null &&
                        !addPostState.isLoading)
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
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Add status'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
