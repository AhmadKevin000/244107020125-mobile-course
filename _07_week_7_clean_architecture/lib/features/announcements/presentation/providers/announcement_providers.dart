import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/usecases/get_announcements.dart';

/// DI terpusat untuk fitur announcements. Widget hanya membaca state di
/// bawah, tidak pernah menyentuh repository atau data mock secara langsung.

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return const AnnouncementRepositoryImpl();
});

final getAnnouncementsProvider = Provider<GetAnnouncements>((ref) {
  return GetAnnouncements(ref.watch(announcementRepositoryProvider));
});

/// State daftar pengumuman untuk UI.
final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  final result = await ref.watch(getAnnouncementsProvider).call();
  if (result.failure != null) throw result.failure!;
  return result.announcements;
});

/// State satu pengumuman berdasarkan id (untuk halaman detail & deep link).
final announcementByIdProvider =
    FutureProvider.family<Announcement, String>((ref, id) async {
  final result = await ref.watch(announcementRepositoryProvider).fetchById(id);
  if (result.failure != null) throw result.failure!;
  return result.announcement!;
});
