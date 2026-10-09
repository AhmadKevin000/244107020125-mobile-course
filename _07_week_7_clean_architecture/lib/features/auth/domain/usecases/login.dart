import '../../../../core/failures.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';
import '../repositories/session_repository.dart';

/// Satu operasi bisnis: masuk ke aplikasi.
///
/// Use case ini menggabungkan dua repository — autentikasi ke server
/// ([AuthRepository]) lalu menyimpan sesi di perangkat ([SessionRepository]).
/// Karena menggabungkan lebih dari satu langkah, use case di sini benar-benar
/// dibutuhkan (bukan sekadar passthrough).
class Login {
  const Login(this._auth, this._session);

  final AuthRepository _auth;
  final SessionRepository _session;

  Future<({AuthSession? session, Failure? failure})> call({
    required String email,
    required String password,
  }) async {
    final result = await _auth.authenticate(email: email, password: password);
    final session = result.session;
    if (result.failure != null || session == null) {
      return (
        session: null,
        failure: result.failure ?? const AuthFailure('Login gagal.'),
      );
    }

    try {
      await _session.save(session);
    } on Failure catch (failure) {
      return (session: null, failure: failure);
    } catch (_) {
      return (
        session: null,
        failure: const LocalFailure('Gagal menyimpan sesi.'),
      );
    }

    return (session: session, failure: null);
  }
}
