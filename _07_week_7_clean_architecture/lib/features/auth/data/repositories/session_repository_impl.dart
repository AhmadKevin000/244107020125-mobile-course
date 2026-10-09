import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/session_repository.dart';

/// Menyimpan sesi di keystore perangkat (Keychain di iOS, Keystore di Android),
/// bukan di SharedPreferences. Semua token keluar-masuk lewat kelas ini.
///
/// Implementasi dari port domain [SessionRepository]; rincian penyimpanan
/// (secure storage) sengaja tidak diketahui domain.
class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  @override
  Future<void> save(AuthSession session) async {
    await _storage.write(key: _accessKey, value: session.access);
    await _storage.write(key: _refreshKey, value: session.refresh);
  }

  @override
  Future<String?> readAccess() => _storage.read(key: _accessKey);

  @override
  Future<String?> readRefresh() => _storage.read(key: _refreshKey);

  @override
  Future<void> clear() => _storage.deleteAll();
}
