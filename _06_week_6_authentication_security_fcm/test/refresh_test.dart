import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:_06_week_6_authentication_security_fcm/data/api_client.dart';
import 'package:_06_week_6_authentication_security_fcm/data/auth_repository.dart';
import 'package:_06_week_6_authentication_security_fcm/data/token_store.dart';

/// Adapter Dio tiruan supaya test tidak menyentuh jaringan sungguhan.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    calls++;
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int status, String body) => ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('401 di-refresh sekali lalu request diulang dan berhasil', () async {
    final store = TokenStore();
    await store.save(access: 'access-lama', refresh: 'refresh-hidup');

    final adapter = _FakeAdapter((options) {
      final auth = options.headers['Authorization'];
      if (auth == 'Bearer access-lama') return Future.value(_json(401, '{}'));
      return Future.value(_json(200, '{"ok":true}'));
    });
    final dio = buildApiClient(store, AuthRepository())..httpClientAdapter = adapter;

    final res = await dio.get<dynamic>('/pengumuman');

    expect(res.statusCode, 200);
    expect(adapter.calls, 2, reason: 'satu percobaan awal + satu ulangan');
  });

  test('refresh mati memanggil onSessionExpired dan membersihkan sesi',
      () async {
    final store = TokenStore();
    // Refresh token kosong -> AuthRepository.refresh melempar.
    await store.save(access: 'access-lama', refresh: '');

    var expired = false;
    final adapter = _FakeAdapter((_) => Future.value(_json(401, '{}')));
    final dio = buildApiClient(
      store,
      AuthRepository(),
      onSessionExpired: () async => expired = true,
    )..httpClientAdapter = adapter;

    await expectLater(
      dio.get<dynamic>('/pengumuman'),
      throwsA(isA<DioException>()),
    );

    expect(expired, isTrue);
    expect(await store.readAccess(), isNull, reason: 'sesi harus dibersihkan');
  });

  test('401 berulang tidak loop dan memanggil onSessionExpired', () async {
    final store = TokenStore();
    await store.save(access: 'access-lama', refresh: 'refresh-hidup');

    var expired = false;
    final adapter = _FakeAdapter((_) => Future.value(_json(401, '{}')));
    final dio = buildApiClient(
      store,
      AuthRepository(),
      onSessionExpired: () async => expired = true,
    )..httpClientAdapter = adapter;

    await expectLater(
      dio.get<dynamic>('/pengumuman'),
      throwsA(isA<DioException>()),
    );

    expect(expired, isTrue);
    expect(adapter.calls, 2, reason: 'tidak boleh refresh tanpa henti');
  });
}
