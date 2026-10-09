import '../../../../core/failures.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api.dart';

/// Implementasi [AuthRepository] di atas [AuthApi].
///
/// Seluruh exception diterjemahkan menjadi [Failure] di batas ini, sehingga
/// tidak ada exception mentah yang bocor ke presentation.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl([this._api = const AuthApi()]);

  final AuthApi _api;

  @override
  Future<({AuthSession? session, Failure? failure})> authenticate({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _api.login(email: email, password: password);
      return (session: session, failure: null);
    } on Failure catch (failure) {
      return (session: null, failure: failure);
    } catch (_) {
      return (
        session: null,
        failure: const NetworkFailure('Tidak dapat masuk. Coba lagi.'),
      );
    }
  }

  @override
  Future<({String? access, Failure? failure})> refresh(
    String refreshToken,
  ) async {
    try {
      final access = await _api.refresh(refreshToken);
      return (access: access, failure: null);
    } on Failure catch (failure) {
      return (access: null, failure: failure);
    } catch (_) {
      return (
        access: null,
        failure: const NetworkFailure('Gagal menyegarkan sesi.'),
      );
    }
  }
}
