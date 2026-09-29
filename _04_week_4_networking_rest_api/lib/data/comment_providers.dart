import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/comment.dart';
import 'providers.dart' show dioProvider;
import 'repositories/comment_repository.dart';

/// Provider untuk instance [CommentRepository].
/// Mengambil instance [Dio] dari [dioProvider].
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

/// [AsyncNotifier] untuk mengelola state daftar komentar dari suatu postingan.
///
/// Menerima parameter [postId] pada konstruktornya.
/// Di Riverpod, setiap exception yang tidak tertangkap (uncaught exception) pada method [build]
/// secara otomatis dikonversi menjadi state [AsyncError], sehingga UI dapat
/// menangani status error secara deklaratif.
class CommentListNotifier extends AsyncNotifier<List<Comment>> {
  /// Konstruktor dengan parameter [postId].
  CommentListNotifier(this.postId);

  /// ID dari postingan yang komentarnya ingin diambil.
  final int postId;

  @override
  Future<List<Comment>> build() async {
    // Exception dari repository (seperti DioException) otomatis menjadi AsyncError.
    final repository = ref.watch(commentRepositoryProvider);
    return repository.fetchComments(postId);
  }

  /// Memuat ulang (refresh) data komentar secara manual.
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(commentRepositoryProvider);
      state = AsyncData(await repository.fetchComments(postId));
    } catch (e, st) {
      // Menangkap error dan menyimpannya ke state sebagai AsyncError
      state = AsyncError(e, st);
    }
  }
}

/// [AsyncNotifierProvider.family] untuk menyediakan [CommentListNotifier] berdasarkan [postId].
///
/// Penggunaan `family` memungkinkan kita memanggil provider dengan parameter `postId`,
/// contoh: `ref.watch(commentListProvider(1))`.
///
/// Pengaturan `retry: (retryCount, error) => null` menonaktifkan retry otomatis default Riverpod 3
/// sehingga error langsung tertangkap (memudahkan testing dan penanganan UI langsung).
final commentListProvider =
    AsyncNotifierProvider.family<CommentListNotifier, List<Comment>, int>(
  CommentListNotifier.new,
  retry: (retryCount, error) => null,
);

/// Fungsi pesan error ramah pengguna (User-Friendly Error Message).
///
/// Mengonversi error (khususnya [DioException]) menjadi pesan bahasa Indonesia yang mudah dipahami pengguna:
/// - Timeout (Koneksi, Pengiriman data, atau Penerimaan data)
/// - Connection Error (Tidak ada jaringan / Host tidak dapat dihubungi)
/// - HTTP 404 (Data komentar tidak ditemukan)
/// - HTTP 500 (Terjadi gangguan internal pada server)
String commentFriendlyErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      // 1. Kasus Timeout
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Waktu koneksi habis (timeout). Silakan periksa jaringan internet Anda dan coba lagi.';

      // 2. Kasus Connection Error
      case DioExceptionType.connectionError:
        return 'Gagal terhubung ke server. Pastikan perangkat Anda terhubung ke internet.';

      // 3 & 4. Kasus Response HTTP Error (404 dan 500)
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return 'Komentar tidak ditemukan (404).';
        } else if (statusCode == 500) {
          return 'Terjadi gangguan pada server (500). Silakan coba lagi nanti.';
        }
        return 'Terjadi kesalahan pada respon server ($statusCode).';

      // Kasus Pembatalan Request
      case DioExceptionType.cancel:
        return 'Permintaan data komentar telah dibatalkan.';

      // Kasus error Dio lainnya
      default:
        return 'Terjadi kendala pada jaringan. Silakan coba lagi.';
    }
  }

  // Fallback untuk exception/error umum di luar DioException
  return 'Terjadi kesalahan tidak terduga: $error';
}
