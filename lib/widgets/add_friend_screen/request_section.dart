import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constants/colors.dart';
import '../../viewmodels/friend_request_provider.dart';
import 'request_tile.dart';

class RequestSection extends ConsumerWidget {
  const RequestSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(friendRequestsProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text(
            'Błąd: $err',
            style: const TextStyle(color: AppColors.angry),
          ),
          data: (requests) {
            final pending = requests
                .where((r) => r.status == 'pending')
                .toList();
            if (pending.isEmpty) return const SizedBox();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Requests',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pending.length,
                  itemBuilder: (context, i) => RequestTile(request: pending[i]),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        );
  }
}
