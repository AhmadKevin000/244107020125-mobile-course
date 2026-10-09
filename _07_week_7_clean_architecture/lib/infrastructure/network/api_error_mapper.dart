import 'package:dio/dio.dart';

import '../../core/failures.dart';

/// Menerjemahkan error apa pun menjadi [Failure] yang ramah pengguna.
///
/// `DioException` mentah bisa memuat detail teknis (URL, tipe socket) yang
/// membingungkan atau membocorkan info internal. Semua pemetaan kode status ke
/// pesan ada di satu tempat ini, bukan di masing-masing halaman. Error yang
/// sudah berupa [Failure] diteruskan apa adanya.
Failure failureForError(Object error) {
  if (error is Failure) return error;
  if (error is! DioException) {
    // Error non-Dio (mis. dari repository) sudah berupa pesan ramah; buang
    // hanya prefix teknis "Exception: ".
    return LocalFailure(error.toString().replaceFirst('Exception: ', ''));
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const NetworkFailure('Koneksi lambat. Coba lagi.');
    case DioExceptionType.connectionError:
      return const NetworkFailure(
        'Tidak dapat terhubung ke server. Periksa jaringan Anda.',
      );
    case DioExceptionType.badCertificate:
      return const NetworkFailure('Sertifikat server tidak valid.');
    case DioExceptionType.cancel:
      return const NetworkFailure('Permintaan dibatalkan.');
    case DioExceptionType.badResponse:
      final code = error.response?.statusCode;
      if (code == 401) {
        return const NetworkFailure('Sesi berakhir. Silakan masuk kembali.');
      }
      if (code == 403) {
        return const NetworkFailure('Anda tidak punya akses ke data ini.');
      }
      if (code == 404) {
        return const NetworkFailure('Data tidak ditemukan.');
      }
      if (code != null && code >= 500) {
        return const NetworkFailure('Server sedang bermasalah. Coba lagi nanti.');
      }
      return NetworkFailure('Permintaan gagal (kode $code).');
    case DioExceptionType.unknown:
      return const NetworkFailure('Terjadi kesalahan tak terduga.');
  }
}

/// Pesan yang aman ditampilkan ke pengguna. UI hanya menerima `String`.
String messageForError(Object error) => failureForError(error).message;
