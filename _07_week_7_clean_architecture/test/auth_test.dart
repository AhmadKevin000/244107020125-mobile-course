import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:_07_week_7_clean_architecture/core/failures.dart';
import 'package:_07_week_7_clean_architecture/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:_07_week_7_clean_architecture/infrastructure/network/api_error_mapper.dart';

void main() {
  group('AuthRepositoryImpl', () {
    final repo = AuthRepositoryImpl();

    test('authenticate berhasil mengembalikan access dan refresh token',
        () async {
      final result = await repo.authenticate(
        email: 'mahasiswa@kampus.ac.id',
        password: 'rahasia123',
      );
      expect(result.failure, isNull);
      expect(result.session, isNotNull);
      expect(result.session!.access, isNotEmpty);
      expect(result.session!.refresh, isNotEmpty);
    });

    test('authenticate gagal saat kredensial salah', () async {
      final result = await repo.authenticate(
        email: 'salah@kampus.ac.id',
        password: 'salah',
      );
      expect(result.failure, isA<AuthFailure>());
      expect(result.session, isNull);
    });

    test('refresh mengembalikan access token baru', () async {
      final result = await repo.refresh('mock-refresh');
      expect(result.failure, isNull);
      expect(result.access, startsWith('mock-access-renewed-'));
    });

    test('refresh menolak token kosong', () async {
      final result = await repo.refresh('');
      expect(result.failure, isNotNull);
      expect(result.access, isNull);
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

    test('Failure diteruskan apa adanya', () {
      expect(
        messageForError(const AuthFailure('Email atau kata sandi tidak valid')),
        'Email atau kata sandi tidak valid',
      );
    });
  });
}
