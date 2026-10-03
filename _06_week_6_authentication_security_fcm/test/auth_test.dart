import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:_06_week_6_authentication_security_fcm/data/api_errors.dart';
import 'package:_06_week_6_authentication_security_fcm/data/auth_repository.dart';

void main() {
  group('AuthRepository', () {
    final repo = AuthRepository();

    test('login berhasil mengembalikan access dan refresh token', () async {
      final session = await repo.login(
        email: 'mahasiswa@kampus.ac.id',
        password: 'rahasia123',
      );
      expect(session.access, isNotEmpty);
      expect(session.refresh, isNotEmpty);
    });

    test('login gagal saat kredensial salah', () {
      expect(
        () => repo.login(email: 'salah@kampus.ac.id', password: 'salah'),
        throwsA(isA<Exception>()),
      );
    });

    test('refresh mengembalikan access token baru', () async {
      final renewed = await repo.refresh('mock-refresh');
      expect(renewed, startsWith('mock-access-renewed-'));
    });

    test('refresh menolak token kosong', () {
      expect(() => repo.refresh(''), throwsA(isA<Exception>()));
    });
  });

  group('messageForError', () {
    DioException withStatus(int status) => DioException(
          requestOptions: RequestOptions(path: '/pengumuman'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/pengumuman'),
            statusCode: status,
          ),
        );

    test('401 menjadi pesan sesi berakhir', () {
      expect(messageForError(withStatus(401)), contains('Sesi berakhir'));
    });

    test('404 menjadi pesan data tidak ditemukan', () {
      expect(messageForError(withStatus(404)), contains('tidak ditemukan'));
    });

    test('5xx menjadi pesan server bermasalah', () {
      expect(messageForError(withStatus(503)), contains('Server'));
    });

    test('timeout menjadi pesan koneksi lambat', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(messageForError(error), contains('Koneksi lambat'));
    });

    test('connectionError menjadi pesan periksa jaringan', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionError,
      );
      expect(messageForError(error), contains('jaringan'));
    });

    test('Exception biasa tampil tanpa prefix teknis', () {
      expect(
        messageForError(Exception('Email atau kata sandi tidak valid')),
        'Email atau kata sandi tidak valid',
      );
    });
  });
}
