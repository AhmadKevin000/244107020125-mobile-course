import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/auth_api.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/session_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/usecases/login.dart';

/// DI terpusat untuk fitur auth. Inilah satu-satunya tempat wiring
/// implementasi data ke abstraksi domain. Widget tidak pernah membuat
/// repository sendiri.

// Data layer: penyimpanan sesi di perangkat (mudah diganti fake saat test).
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepositoryImpl();
});

// Data layer: backend auth (mock). Bergantung pada abstraksi, bukan concretion.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(const AuthApi());
});

// Domain layer: use case menggabungkan autentikasi + persistensi sesi.
final loginProvider = Provider<Login>((ref) {
  return Login(
    ref.watch(authRepositoryProvider),
    ref.watch(sessionRepositoryProvider),
  );
});

/// Status login diturunkan dari ada/tidaknya access token tersimpan.
final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token = await ref.watch(sessionRepositoryProvider).readAccess();
    return token != null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(loginProvider).call(
            email: email,
            password: password,
          );
      final failure = result.failure;
      if (failure != null) throw failure;
      return true;
    });
  }

  Future<void> logout() async {
    await ref.read(sessionRepositoryProvider).clear();
    ref.invalidateSelf();
  }
}
