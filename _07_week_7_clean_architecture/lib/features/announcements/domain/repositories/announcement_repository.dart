import '../../../../core/failures.dart';
import '../entities/announcement.dart';

/// Kontrak yang dibutuhkan domain untuk membaca pengumuman.
///
/// Interface tinggal di domain; implementasi (mock, HTTP, SQLite) tinggal di
/// layer data. Domain tidak tahu dari mana datanya berasal.
abstract class AnnouncementRepository {
  Future<({List<Announcement> announcements, Failure? failure})>
      fetchAnnouncements();

  Future<({Announcement? announcement, Failure? failure})> fetchById(String id);
}
