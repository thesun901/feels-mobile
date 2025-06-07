import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:feels_mobile/constants/colors.dart';
import 'package:feels_mobile/models/feeling.dart';
import 'package:feels_mobile/widgets/add_status_screen/emotion_map_builder.dart';

class EmotionSelector extends HookConsumerWidget {
  final ValueNotifier<String?> selectedEmotionKey;
  final Widget child;
  final List<Feeling> feelings;

  const EmotionSelector({
    super.key,
    required this.selectedEmotionKey,
    required this.child,
    required this.feelings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final emotions = buildEmotionsMap(feelings);

    return GestureDetector(
      onTap: () async {
        final emotionKey = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: AppColors.cardBackground,
          builder: (ctx) => Column(
            children: [
              SingleChildScrollView(
                child: SizedBox(
                  height: 500,
                  child: ListView(
                    shrinkWrap: true,
                    children: emotions.entries.map((entry) {
                      return ListTile(
                        onTap: () => Navigator.pop(ctx, entry.key),
                        title: Container(
                          decoration: BoxDecoration(
                            color: AppColors.tired.withValues(alpha: 0.5),
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
                                color: AppColors.textDim.withValues(alpha: 0.3),
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 0,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
        if (emotionKey != null) {
          selectedEmotionKey.value = emotionKey;
        }
      },
      child: child,
    );
  }
}
