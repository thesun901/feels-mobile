import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../viewmodels/stats_provider.dart';
import '../constants/colors.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});
  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(statsProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statsProvider);
    final notifier = ref.read(statsProvider.notifier);

    Widget buildHeatmap() {
      final now = DateTime.now();
      DateTime start = DateTime(now.year, 1, 1);
      while (start.weekday != DateTime.monday) {
        start = start.subtract(const Duration(days: 1));
      }

      final weeks = (now.difference(start).inDays / 7).ceil() + 1;
      const square = 12.0;
      const gap = 2.0;

      return SizedBox(
        height: (square + gap) * 7,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: weeks,
          itemBuilder: (context, col) {
            return Column(
              children: List.generate(7, (row) {
                final day = start.add(Duration(days: col * 7 + row));
                final hex = state.colorByDay[day];
                Color c;
                if (hex != null) {
                  final cleaned = hex.replaceFirst('#', '');
                  final full = cleaned.length == 3
                      ? cleaned.split('').map((e) => '$e$e').join('')
                      : cleaned;
                  c = Color(int.parse('0xff$full'));
                } else {
                  c = Colors.grey.withAlpha(50);
                }
                return Container(
                  width: square,
                  height: square,
                  margin: const EdgeInsets.all(gap / 2),
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            );
          },
        ),
      );
    }

    if (state.loading && !state.refreshing) {
      return const Center(child: CircularProgressIndicator());
    }

    Widget _statInfoCard({required String emoji, required String text}) {
      return SizedBox(
        width: double.infinity,
        child: Card(
          color: AppColors.cardBackground,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(text, style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECTION 1
            Text(
              "Your friends are grateful to have you!",
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade400),
            ),
            const SizedBox(height: 6),
            _statInfoCard(
              emoji: "🌼",
              text: "You've read ${state.readCount} statuses of your friends!",
            ),

            const SizedBox(height: 24),

            // SECTION 2
            Text(
              "Your feelings matter!",
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade400),
            ),
            const SizedBox(height: 6),
            _statInfoCard(
              emoji: "😯",
              text: "You posted your feelings... ${state.feelingsCount} times!",
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Card(
                color: AppColors.cardBackground,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Timeline overview',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      buildHeatmap(),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "Do you want to remind yourself some moments?\nCheck your archive!",
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade400),
              ),
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.feelingsCeladon,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed("/archive");
                },
                icon: const Icon(Icons.archive),
                label: const Text(
                  "Navigate to your Archive",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
