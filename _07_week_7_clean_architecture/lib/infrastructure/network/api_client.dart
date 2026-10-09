import 'package:dio/dio.dart';

import '../../features/auth/domain/entities/auth_session.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/repositories/session_repository.dart';

/// Penanda request yang sudah lolos satu kali refresh, supaya 401 kedua tidak
/// memicu refresh tanpa henti.
const _retriedAfterRefresh = 'retried_after_refresh';

/// Dio client yang menyisipkan access token ke tiap request dan, saat kena 401,
/// refresh sekali lalu mengulang request aslinya.
///
/// Bergantung pada abstraksi domain ([SessionRepository] dan [AuthRepository]),
/// bukan pada implementasi konkret. [onSessionExpired] dipanggil ketika refresh
/// token ikut mati atau request ulangan masih 401; setelah itu sesi tidak bisa
/// dipulihkan, jadi pemanggil berkewajiban mengarahkan pengguna ke login.
Dio buildApiClient(
  SessionRepository session,
  AuthRepository auth, {
  Future<void> Function()? onSessionExpired,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example-campus-api.test'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await session.readAccess();
        if (access != null) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode != 401) {
          return handler.next(error);
        }
        if (error.requestOptions.extra[_retriedAfterRefresh] == true) {
          await session.clear();
          await onSessionExpired?.call();
          return handler.next(error);
        }
        final refresh = await session.readRefresh();
        if (refresh == null) {
          await onSessionExpired?.call();
          return handler.next(error);
        }

        final result = await auth.refresh(refresh);
        final renewed = result.access;
        if (result.failure != null || renewed == null) {
          // Refresh token ikut mati, satu-satunya jalan adalah login ulang.
          await session.clear();
          await onSessionExpired?.call();
          return handler.next(error);
        }

        await session.save(AuthSession(access: renewed, refresh: refresh));
        final retry = await dio.fetch(
          error.requestOptions
            ..headers['Authorization'] = 'Bearer $renewed'
            ..extra[_retriedAfterRefresh] = true,
        );
        return handler.resolve(retry);
      },
    ),
  );
  return dio;
}
