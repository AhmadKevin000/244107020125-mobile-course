import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/network/api_error_mapper.dart';
import '../providers/announcement_providers.dart';

class AnnouncementPage extends ConsumerWidget {
  const AnnouncementPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcement = ref.watch(announcementByIdProvider(id));
    return Scaffold(
      appBar: AppBar(title: const Text('Pengumuman')),
      body: announcement.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(messageForError(error))),
        data: (item) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(item.body),
            ],
          ),
        ),
      ),
    );
  }
}
