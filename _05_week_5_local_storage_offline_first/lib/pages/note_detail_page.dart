import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/note.dart';
import '../data/providers.dart';

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({super.key, required this.noteId});

  final int noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(noteByIdProvider(noteId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail catatan')),
      body: noteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Gagal memuat catatan: $error')),
        data: (note) => note == null
            ? const _NotFoundView()
            : _NoteDetail(note: note),
      ),
    );
  }
}

class _NoteDetail extends StatelessWidget {
  const _NoteDetail({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(note.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              note.dirty ? Icons.sync_problem : Icons.cloud_done_outlined,
              size: 16,
              color: note.dirty ? Colors.orange : theme.colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              note.dirty ? 'Belum tersinkron' : 'Tersinkron',
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(width: 12),
            Text(
              _formatDate(note.updatedAt),
              style: theme.textTheme.labelMedium,
            ),
          ],
        ),
        const Divider(height: 32),
        Text(
          note.body.isEmpty ? 'Tidak ada isi catatan.' : note.body,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  String _formatDate(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)}/${value.year} '
        '${two(value.hour)}:${two(value.minute)}';
  }
}

class _NotFoundView extends StatelessWidget {
  const _NotFoundView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Catatan tidak ditemukan.'));
  }
}
