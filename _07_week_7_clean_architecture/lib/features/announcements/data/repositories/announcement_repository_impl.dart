import '../../../../core/failures.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';

/// Implementasi [AnnouncementRepository] dengan data mock in-memory.
///
/// Karena belum ada serialisasi (JSON/SQLite), entity dipakai langsung tanpa
/// model perantara — menambah model passthrough kosong hanya akan menjadi
/// over-engineering.
class AnnouncementRepositoryImpl implements AnnouncementRepository {
  const AnnouncementRepositoryImpl();

  static const _items = <Announcement>[
    Announcement(
      id: '1',
      title: 'Pembayaran UKT dibuka',
      body: 'Batas pembayaran 30 Oktober 2026.',
    ),
    Announcement(
      id: '2',
      title: 'Beasiswa prestasi',
      body: 'Pendaftaran dibuka sampai 15 November.',
    ),
    Announcement(
      id: '3',
      title: 'Jadwal kuliah berubah',
      body: 'Kelas Mobile pindah ke Ruang A2 jam 13.00.',
    ),
  ];

  @override
  Future<({List<Announcement> announcements, Failure? failure})>
      fetchAnnouncements() async {
    return (announcements: _items, failure: null);
  }

  @override
  Future<({Announcement? announcement, Failure? failure})> fetchById(
    String id,
  ) async {
    for (final item in _items) {
      if (item.id == id) return (announcement: item, failure: null);
    }
    return (
      announcement: null,
      failure: const LocalFailure('Pengumuman tidak ditemukan.'),
    );
  }
}
