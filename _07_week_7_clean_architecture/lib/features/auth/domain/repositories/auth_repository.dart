import '../../../../core/failures.dart';
import '../entities/auth_session.dart';

/// Kontrak autentikasi terhadap backend.
///
/// Hanya berisi operasi yang berhubungan dengan server (masuk dan menyegarkan
/// token). Penyimpanan token lokal adalah kontrak terpisah
/// ([SessionRepository]) supaya use case bisa mengoordinasikan keduanya.
abstract class AuthRepository {
  Future<({AuthSession? session, Failure? failure})> authenticate({
    required String email,
    required String password,
  });

  Future<({String? access, Failure? failure})> refresh(String refreshToken);
}
