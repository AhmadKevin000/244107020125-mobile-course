/// Pasangan token yang dikeluarkan backend auth.
class AuthSession {
  const AuthSession({required this.access, required this.refresh});

  final String access;
  final String refresh;
}

/// Auth mock yang meniru kontrak token backend asli.
///
/// Ganti [login] dengan `FirebaseAuth.instance.signInWithEmailAndPassword`
/// atau Google Sign-In saat backend siap. Karena pemanggil hanya bergantung
/// pada [AuthSession], bagian app lain tidak perlu ikut berubah.
class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    const validEmail = 'mahasiswa@kampus.ac.id';
    const validPassword = 'rahasia123';
    if (email != validEmail || password != validPassword) {
      throw Exception('Email atau kata sandi tidak valid');
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
    if (refreshToken.isEmpty) throw Exception('Refresh token hilang');
    return 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }
}
