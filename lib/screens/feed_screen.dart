import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../constants/colors.dart';
import '../viewmodels/feed_provider.dart';
import '../widgets/post_card.dart';
import 'add_friend_screen.dart';

class FeedScreen extends HookConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        iconTheme: const IconThemeData(color: AppColors.textLight),
        title: const Text(
          'Feels',
          style: TextStyle(color: AppColors.textLight),
        ),
        elevation: 0,
      ),
      drawer: Drawer(
        backgroundColor: AppColors.cardBackground,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              leading: const Icon(Icons.person, color: AppColors.textLight),
              title: const Text('My profile', style: TextStyle(color: AppColors.textLight)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.person_add, color: AppColors.textLight),
              title: const Text('Add friend', style: TextStyle(color: AppColors.textLight)),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddFriendScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.group, color: AppColors.textLight),
              title: const Text('Friends', style: TextStyle(color: AppColors.textLight)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: AppColors.textLight),
              title: const Text('Settings', style: TextStyle(color: AppColors.textLight)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.info, color: AppColors.textLight),
              title: const Text('About', style: TextStyle(color: AppColors.textLight)),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: feed.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (posts) => ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                PostCard(post: post),
              ],
            );
          },
        ),
      ),
    );
  }
}