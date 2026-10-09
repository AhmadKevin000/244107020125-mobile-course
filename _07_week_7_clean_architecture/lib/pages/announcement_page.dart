import 'package:flutter/material.dart';

import '../data/announcements.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final announcement = announcementById(id);
    if (announcement == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pengumuman')),
        body: const Center(child: Text('Pengumuman tidak ditemukan.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pengumuman')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              announcement.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(announcement.body),
          ],
        ),
      ),
    );
  }
}
