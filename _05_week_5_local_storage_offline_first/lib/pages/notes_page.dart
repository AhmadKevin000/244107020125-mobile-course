import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import 'widgets/note_tile.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan'),
        actions: [
          const DirtyBadge(),
          IconButton(
            icon: const Icon(Icons.cloud_sync_outlined),
            tooltip: 'Sinkronkan catatan',
            onPressed: () => _syncNow(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.article_outlined),
            tooltip: 'Postingan (cache-first)',
            onPressed: () => context.push('/posts'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Pengaturan',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(message: '$error'),
        data: (notes) => notes.isEmpty
            ? const _EmptyView()
            : ListView.separated(
                itemCount: notes.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return NoteTile(
                    note: note,
                    onTap: () => context.push('/note/${note.id}'),
                    onDelete: () =>
                        ref.read(notesProvider.notifier).remove(note.id!),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _promptAddNote(context, ref),
        tooltip: 'Tambah catatan',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DirtyBadge extends ConsumerWidget {
  const DirtyBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dirty = ref.watch(dirtyCountProvider).value ?? 0;
    if (dirty == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Badge.count(
        count: dirty,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.cloud_upload_outlined),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.note_alt_outlined, size: 48),
          SizedBox(height: 12),
          Text('Belum ada catatan. Tekan + untuk menambah.'),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text('Gagal memuat catatan:\n$message', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

Future<void> _promptAddNote(BuildContext context, WidgetRef ref) async {
  final controller = TextEditingController();
  final title = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Catatan baru'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Judul catatan'),
        onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(controller.text),
          child: const Text('Simpan'),
        ),
      ],
    ),
  );

  final trimmed = title?.trim() ?? '';
  if (trimmed.isEmpty) return;
  await ref.read(notesProvider.notifier).add(title: trimmed);
}

Future<void> _syncNow(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);

  if (ref.read(forceOfflineProvider)) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Mode offline aktif — sync dilewati.')),
    );
    return;
  }

  final synced = await ref
      .read(syncServiceProvider)
      .syncNotes(ref.read(noteRepositoryProvider));
  ref.invalidate(notesProvider);
  ref.invalidate(dirtyCountProvider);

  messenger.showSnackBar(
    SnackBar(
      content: Text(
        synced == 0
            ? 'Tidak ada catatan yang perlu disinkronkan.'
            : '$synced catatan tersinkron.',
      ),
    ),
  );
}
