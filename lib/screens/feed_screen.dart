import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:feels_mobile/viewmodels/feed_provider.dart';
import 'package:feels_mobile/widgets/feed_screen/post_card.dart';
import 'package:feels_mobile/constants/colors.dart';

class FeedScreen extends HookConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedProvider);

    return Scaffold(
      body: feedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: \$err')),
        data: (posts) => RefreshIndicator(
          onRefresh: () => ref.refresh(feedProvider.future),
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(post: post);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to add status screen, then refresh feed on return
          await Navigator.pushNamed(context, '/add_status');
          // ignore: unused_result
          await ref.refresh(feedProvider.future);
        },
        backgroundColor: AppColors.peaceful,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}
