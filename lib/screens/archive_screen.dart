import 'package:feels_mobile/widgets/feed_screen/post_card.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../viewmodels/archive_provider.dart';

class ArchiveScreen extends ConsumerStatefulWidget {
  const ArchiveScreen({super.key});

  @override
  ConsumerState<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ConsumerState<ArchiveScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(archiveProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(archiveProvider);
    final notifier = ref.read(archiveProvider.notifier);

    Widget body;
    if (state.loading && !state.refreshing) {
      body = const Center(child: CircularProgressIndicator());
    } else if (state.error != null) {
      body = Center(child: Text('Error: ${state.error}'));
    } else if (state.posts.isEmpty) {
      body = const Center(child: Text('No posts yet'));
    } else {
      body = RefreshIndicator(
        onRefresh: notifier.refresh,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: state.posts.length,
          itemBuilder: (context, index) => PostCard(post: state.posts[index]),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Archive'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: body,
    );
  }
}
