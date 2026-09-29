import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/paged_posts.dart';
import '../data/providers.dart';
import 'widgets/post_tile.dart';

class PagedPostPage extends ConsumerStatefulWidget {
  const PagedPostPage({super.key});

  @override
  ConsumerState<PagedPostPage> createState() =>
      _PagedPostPageState();
}

class _PagedPostPageState
    extends ConsumerState<PagedPostPage> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.position.pixels >=
          _controller.position.maxScrollExtent - 200) {
        ref.read(pagedPostsProvider.notifier).loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pagedPostsProvider);
    // Auto-load: jika seluruh konten masih muat dalam satu layar,
    // ScrollController tidak pernah terpanggil (maxScrollExtent == 0),
    // sehingga halaman berikutnya harus dimuat otomatis sampai layar penuh.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.hasClients) return;
      final pos = _controller.position;
      if (pos.maxScrollExtent <= 0 &&
          state.hasMore &&
          !state.isLoadingMore &&
          state.error == null &&
          state.items.isNotEmpty) {
        ref.read(pagedPostsProvider.notifier).loadNextPage();
      }
    });
    if (state.error != null && state.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Posts Paged')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(friendlyErrorMessage(state.error!)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref
                    .read(pagedPostsProvider.notifier)
                    .loadFirstPage(),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts Paged'),
        actions: [
          IconButton(
            icon: const Icon(Icons.view_list),
            tooltip: 'Mode penuh',
            onPressed: () => context.go('/posts'),
          ),
        ],
      ),
      body: ListView.builder(
        controller: _controller,
        itemCount: state.items.length + 1,
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            if (!state.hasMore) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child:
                    Center(child: Text('Semua data termuat.')),
              );
            }
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final post = state.items[index];
          return PostTile(
            post: post,
            onTap: () => context.go('/post/${post.id}'),
          );
        },
      ),
    );
  }
}
