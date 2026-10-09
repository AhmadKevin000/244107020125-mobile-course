import '../../../../core/failures.dart';
import '../../domain/entities/auth_session.dart';

/// Backend auth tiruan yang meniru kontrak token server asli.
///
/// Ganti isi [login] dengan `FirebaseAuth.instance.signInWithEmailAndPassword`
/// atau panggilan Dio saat backend siap. Karena pemanggil hanya bergantung pada
/// [AuthSession], bagian lain tidak perlu ikut berubah.
class AuthApi {
  const AuthApi();

  static const _validEmail = 'mahasiswa@kampus.ac.id';
  static const _validPassword = 'rahasia123';

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (email != _validEmail || password != _validPassword) {
      throw const AuthFailure('Email atau kata sandi tidak valid');
    }
    return AuthSession(
      access: 'mock-access-for-$email',
      refresh: 'mock-refresh-for-$email',
    );
  }

  /// Menukar refresh token yang masih hidup dengan access token baru.
  /// Refresh token mati berarti user harus login ulang.
  Future<String> refresh(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isEmpty) throw const NetworkFailure('Refresh token hilang');
    return 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }
}
