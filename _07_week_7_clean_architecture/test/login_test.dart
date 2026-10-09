import 'package:flutter_test/flutter_test.dart';

import 'package:_07_week_7_clean_architecture/core/failures.dart';
import 'package:_07_week_7_clean_architecture/features/auth/domain/entities/auth_session.dart';
import 'package:_07_week_7_clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:_07_week_7_clean_architecture/features/auth/domain/repositories/session_repository.dart';
import 'package:_07_week_7_clean_architecture/features/auth/domain/usecases/login.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.fail = false});

  final bool fail;

  @override
  Future<({AuthSession? session, Failure? failure})> authenticate({
    required String email,
    required String password,
  }) async {
    if (fail) {
      return (
        session: null,
        failure: const AuthFailure('kredensial salah (simulasi)'),
      );
    }
    return (
      session: const AuthSession(access: 'access', refresh: 'refresh'),
      failure: null,
    );
  }

  @override
  Future<({String? access, Failure? failure})> refresh(String refreshToken) {
    throw UnimplementedError();
  }
}

class _FakeSessionRepository implements SessionRepository {
  AuthSession? saved;

  @override
  Future<void> save(AuthSession session) async => saved = session;

  @override
  Future<String?> readAccess() async => saved?.access;

  @override
  Future<String?> readRefresh() async => saved?.refresh;

  @override
  Future<void> clear() async => saved = null;
}

void main() {
  test('Login menyimpan sesi saat autentikasi berhasil', () async {
    final session = _FakeSessionRepository();

    final result = await Login(_FakeAuthRepository(), session).call(
      email: 'mahasiswa@kampus.ac.id',
      password: 'rahasia123',
    );

    expect(result.failure, isNull);
    expect(result.session, isNotNull);
    expect(session.saved, isNotNull, reason: 'sesi harus dipersistensikan');
  });

  test('Login tidak menyimpan sesi saat autentikasi gagal', () async {
    final session = _FakeSessionRepository();

    final result = await Login(_FakeAuthRepository(fail: true), session).call(
      email: 'salah@kampus.ac.id',
      password: 'salah',
    );

    expect(result.failure, isA<AuthFailure>());
    expect(result.session, isNull);
    expect(session.saved, isNull);
  });
}
