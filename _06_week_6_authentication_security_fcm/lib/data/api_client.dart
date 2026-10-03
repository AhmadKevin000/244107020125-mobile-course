import 'package:dio/dio.dart';

import 'auth_repository.dart';
import 'token_store.dart';

/// Penanda request yang sudah lolos satu kali refresh, supaya 401 kedua tidak
/// memicu refresh tanpa henti.
const _retriedAfterRefresh = 'retried_after_refresh';

/// Dio client yang menyisipkan access token ke tiap request dan, saat kena 401,
/// refresh sekali lalu mengulang request aslinya.
///
/// [onSessionExpired] dipanggil ketika refresh token ikut mati atau request
/// ulangan masih 401. Setelah itu sesi tidak bisa dipulihkan, jadi pemanggil
/// (provider) berkewajiban mengarahkan pengguna kembali ke login.
Dio buildApiClient(
  TokenStore store,
  AuthRepository auth, {
  Future<void> Function()? onSessionExpired,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example-campus-api.test'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await store.readAccess();
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
          await store.clear();
          await onSessionExpired?.call();
          return handler.next(error);
        }
        final refresh = await store.readRefresh();
        if (refresh == null) {
          await onSessionExpired?.call();
          return handler.next(error);
        }

        try {
          final renewed = await auth.refresh(refresh);
          await store.save(access: renewed, refresh: refresh);
          final retry = await dio.fetch(
            error.requestOptions
              ..headers['Authorization'] = 'Bearer $renewed'
              ..extra[_retriedAfterRefresh] = true,
          );
          return handler.resolve(retry);
        } catch (_) {
          // Refresh token ikut mati, satu-satunya jalan adalah login ulang.
          await store.clear();
          await onSessionExpired?.call();
          handler.next(error);
        }
      },
    ),
  );
  return dio;
}
