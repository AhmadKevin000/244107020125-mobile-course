import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/post.dart';
import '../data/providers.dart';

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key, required this.postId});

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postDetailProvider(postId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Post')),
      body: postAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('$err', textAlign: TextAlign.center),
          ),
        ),
        data: (post) {
          if (post == null) {
            return const Center(child: Text('Post tidak ditemukan.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Post #${post.id} (user ${post.userId})',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 8),
              Text(
                post.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(
                post.body,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Provider keluarga (family): hasil dicari dari list yang sudah dimuat
/// lebih dulu, hanya memanggil API bila halaman detail dibuka langsung
/// (post belum ada di memori).
final postDetailProvider =
    FutureProvider.family<Post?, int>((ref, id) {
  return getPostById(ref, id);
});
