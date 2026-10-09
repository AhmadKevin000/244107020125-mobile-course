/// Satu pengumuman kampus.
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
  });

  final String id;
  final String title;
  final String body;
}

/// Data mock pengumuman. Dipakai Home untuk daftar dan AnnouncementPage untuk
/// isi, supaya id dari daftar maupun deep link FCM menunjuk ke konten yang sama.
const announcements = <Announcement>[
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

Announcement? announcementById(String id) {
  for (final item in announcements) {
    if (item.id == id) return item;
  }
  return null;
}
