import 'package:dio/dio.dart';
import '../models/comment.dart';

/// Repository untuk mengelola pengambilan data komentar dari API.
class CommentRepository {
  /// Menerima instance [Dio] melalui dependency injection.
  CommentRepository(this._dio);

  final Dio _dio;

  /// Mengambil daftar komentar berdasarkan [postId] dari endpoint `/comments?postId={id}`.
  ///
  /// Timeout (connect/receive 10 detik) tidak di-set di sini karena sudah
  /// terpusat di BaseOptions pada api_client.dart.
  Future<List<Comment>> fetchComments(int postId) async {
    // Melakukan HTTP GET ke /comments dengan query parameter postId
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
    );

    // Mengambil data response (fallback ke list kosong jika null)
    final data = response.data ?? [];

    // Filter elemen yang bertipe Map<String, dynamic> dan parsing ke List<Comment>
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}
