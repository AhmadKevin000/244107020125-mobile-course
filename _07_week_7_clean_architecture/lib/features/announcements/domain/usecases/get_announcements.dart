import '../../../../core/failures.dart';
import '../entities/announcement.dart';
import '../repositories/announcement_repository.dart';

/// Satu operasi bisnis: mengambil seluruh daftar pengumuman.
///
/// Catatan: untuk saat ini use case ini hanya meneruskan panggilan ke
/// repository (passthrough satu baris). Ia tetap dipertahankan demi
/// konsistensi pola antar fitur dan sebagai tempat menaruh aturan bisnis
/// (mis. sorting atau filter) saat logikanya tumbuh.
class GetAnnouncements {
  const GetAnnouncements(this._repository);

  final AnnouncementRepository _repository;

  Future<({List<Announcement> announcements, Failure? failure})> call() {
    return _repository.fetchAnnouncements();
  }
}
