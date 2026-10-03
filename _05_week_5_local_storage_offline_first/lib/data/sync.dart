import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'local/db.dart';
import 'models/post.dart';
import 'repositories/note_repository.dart';

/// Logika sinkronisasi dan cache yang sengaja dipisah dari repository,
/// agar [NoteRepository] dan [PostRepository] tetap fokus pada CRUD.
class SyncService {
  SyncService({Future<Database> Function()? openDb})
      : _openDb = openDb ?? openNotesDb;

  final Future<Database> Function() _openDb;

  Future<List<Post>> readCachedPosts() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts', orderBy: 'id ASC');
    return rows.map((row) {
      final payload = row['payload'] as String? ?? '{}';
      return Post.fromJson(jsonDecode(payload) as Map<String, dynamic>);
    }).toList();
  }

  Future<void> cachePosts(List<Post> posts) async {
    final db = await _openDb();
    final batch = db.batch();
    final cachedAt = DateTime.now().toIso8601String();
    for (final post in posts) {
      batch.insert(
        'cached_posts',
        {
          'id': post.id,
          'payload': jsonEncode(post.toJson()),
          'cached_at': cachedAt,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Simulasi antrean sync: pada project nyata, tiap catatan dirty dikirim
  /// ke REST API di sini, lalu ditandai bersih hanya bila server menjawab 2xx.
  /// Aturan konflik: last-write-wins berdasarkan `updated_at`.
  Future<int> syncNotes(NoteRepository repo) async {
    final dirtyCount = await repo.countDirty();
    if (dirtyCount == 0) return 0;
    await Future.delayed(const Duration(seconds: 1));
    await repo.markAllSynced();
    return dirtyCount;
  }
}
