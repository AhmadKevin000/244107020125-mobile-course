import '../entities/auth_session.dart';

/// Kontrak penyimpanan sesi di perangkat.
///
/// Domain hanya tahu "simpan sesi" dan "baca token", tanpa peduli apakah
/// implementasinya memakai secure storage, SharedPreferences, atau memori.
abstract class SessionRepository {
  Future<void> save(AuthSession session);
  Future<String?> readAccess();
  Future<String?> readRefresh();
  Future<void> clear();
}
