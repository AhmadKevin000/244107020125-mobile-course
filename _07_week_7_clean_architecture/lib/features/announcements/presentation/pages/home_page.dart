import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../infrastructure/messaging/push_provider.dart';
import '../../../../infrastructure/network/api_error_mapper.dart';
import '../../../../routes.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/announcement_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(fcmTokenProvider);
    final announcements = ref.watch(announcementsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Notify'),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Pengumuman', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          announcements.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Text(messageForError(error)),
            data: (items) => Column(
              children: [
                for (final item in items)
                  Card(
                    child: ListTile(
                      title: Text(item.title),
                      subtitle: Text(item.body),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          context.go(AppRoute.announcementOf(item.id)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Debug FCM', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Registration token (terpotong)'),
                  const SizedBox(height: 4),
                  Text(
                    _truncate(token),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _truncate(String? token) {
  if (token == null) return 'Belum tersedia';
  return token.length <= 12 ? token : '${token.substring(0, 12)}...';
}
