/// Satu pengumuman kampus.
///
/// Entity bisnis murni: tanpa import Flutter dan tanpa mapping
/// (`toMap`/`fromMap`/`toJson`). Mapping adalah urusan layer data.
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
