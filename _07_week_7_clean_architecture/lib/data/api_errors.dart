import 'package:dio/dio.dart';

/// Menerjemahkan error menjadi kalimat yang aman ditampilkan ke pengguna.
///
/// `DioException` mentah bisa memuat detail teknis (URL, tipe socket) yang
/// membingungkan atau membocorkan info internal. Semua pemetaan kode status ke
/// pesan ada di satu tempat ini, bukan di masing-masing halaman.
String messageForError(Object error) {
  if (error is! DioException) {
    // Error dari repository (mis. kredensial salah) sudah berupa pesan ramah;
    // buang hanya prefix teknis "Exception: ".
    return error.toString().replaceFirst('Exception: ', '');
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return 'Koneksi lambat. Coba lagi.';
    case DioExceptionType.connectionError:
      return 'Tidak dapat terhubung ke server. Periksa jaringan Anda.';
    case DioExceptionType.badCertificate:
      return 'Sertifikat server tidak valid.';
    case DioExceptionType.cancel:
      return 'Permintaan dibatalkan.';
    case DioExceptionType.badResponse:
      final code = error.response?.statusCode;
      if (code == 401) return 'Sesi berakhir. Silakan masuk kembali.';
      if (code == 403) return 'Anda tidak punya akses ke data ini.';
      if (code == 404) return 'Data tidak ditemukan.';
      if (code != null && code >= 500) {
        return 'Server sedang bermasalah. Coba lagi nanti.';
      }
      return 'Permintaan gagal (kode $code).';
    case DioExceptionType.unknown:
      return 'Terjadi kesalahan tak terduga.';
  }
}
