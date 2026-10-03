import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'local/note.dart';
import 'models/post.dart';
import 'prefs.dart';
import 'repositories/note_repository.dart';
import 'repositories/post_repository.dart';
import 'sync.dart';

final prefsRepositoryProvider = Provider((ref) => PrefsRepository());

final noteRepositoryProvider = Provider((ref) => NoteRepository());

final syncServiceProvider = Provider((ref) => SyncService());

final dioProvider = Provider<Dio>((ref) => createDio());

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(ref.watch(dioProvider)),
);

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

final lastOpenedProvider = FutureProvider<String?>((ref) {
  return ref.watch(prefsRepositoryProvider).getLastOpened();
});

final forceOfflineProvider =
    NotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);

class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;

  void toggle() => state = !state;
}

final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() {
    return ref.watch(noteRepositoryProvider).fetchNotes();
  }

  Future<void> add({required String title, String body = ''}) async {
    await ref.read(noteRepositoryProvider).addNote(title: title, body: body);
    ref.invalidateSelf();
    ref.invalidate(dirtyCountProvider);
  }

  Future<void> remove(int id) async {
    await ref.read(noteRepositoryProvider).deleteNote(id);
    ref.invalidateSelf();
    ref.invalidate(dirtyCountProvider);
  }
}

final dirtyCountProvider = FutureProvider<int>((ref) {
  return ref.watch(noteRepositoryProvider).countDirty();
});

final noteByIdProvider = FutureProvider.family<Note?, int>((ref, id) {
  return ref.watch(noteRepositoryProvider).getNoteById(id);
});

final postsProvider =
    AsyncNotifierProvider<PostsNotifier, List<Post>>(PostsNotifier.new);

class PostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final sync = ref.watch(syncServiceProvider);
    // 1. Segera kembalikan cache agar UI tidak blank saat offline.
    final cached = await sync.readCachedPosts();
    // 2. Di background: fetch Dio -> simpan ke cached_posts -> refresh state.
    unawaited(_refreshInBackground(sync));
    return cached;
  }

  Future<void> _refreshInBackground(SyncService sync) async {
    if (ref.read(forceOfflineProvider)) return;
    try {
      final posts = await ref.read(postRepositoryProvider).fetchPosts();
      await sync.cachePosts(posts);
      if (!ref.mounted) return;
      state = AsyncData(posts);
    } catch (_) {
      // Jaringan gagal: pertahankan cache yang sudah ditampilkan.
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final posts = await ref.read(postRepositoryProvider).fetchPosts();
      await ref.read(syncServiceProvider).cachePosts(posts);
      return posts;
    });
  }
}
