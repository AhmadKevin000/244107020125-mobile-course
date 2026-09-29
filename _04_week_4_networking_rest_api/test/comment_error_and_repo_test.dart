import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:_04_week_4_networking_rest_api/data/comment_providers.dart';

void main() {
  group('commentFriendlyErrorMessage Tests', () {
    // 1. Uji pesan ramah untuk timeout
    test('menghasilkan pesan timeout ramah pengguna', () {
      final requestOptions = RequestOptions(path: '/comments');
      
      final timeoutException = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionTimeout,
      );

      final message = commentFriendlyErrorMessage(timeoutException);
      expect(message, contains('Waktu koneksi habis (timeout)'));
    });

    // 2. Uji pesan ramah untuk connection error
    test('menghasilkan pesan koneksi terputus untuk connectionError', () {
      final requestOptions = RequestOptions(path: '/comments');
      
      final connErrorException = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionError,
      );

      final message = commentFriendlyErrorMessage(connErrorException);
      expect(message, contains('Gagal terhubung ke server'));
    });

    // 3. Uji pesan ramah untuk HTTP 404
    test('menghasilkan pesan data tidak ditemukan untuk HTTP 404', () {
      final requestOptions = RequestOptions(path: '/comments');
      
      final notFoundException = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 404,
        ),
      );

      final message = commentFriendlyErrorMessage(notFoundException);
      expect(message, equals('Komentar tidak ditemukan (404).'));
    });

    // 4. Uji pesan ramah untuk HTTP 500
    test('menghasilkan pesan server bermasalah untuk HTTP 500', () {
      final requestOptions = RequestOptions(path: '/comments');
      
      final serverErrorException = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 500,
        ),
      );

      final message = commentFriendlyErrorMessage(serverErrorException);
      expect(message, equals('Terjadi gangguan pada server (500). Silakan coba lagi nanti.'));
    });
  });
}
