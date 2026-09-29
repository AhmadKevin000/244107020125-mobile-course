import 'package:flutter_test/flutter_test.dart';
import 'package:_04_week_4_networking_rest_api/data/models/comment.dart';

void main() {
  group('Comment Model Test', () {
    // Unit test utama sesuai requirement:
    // Menguji parsing fromJson saat menerima Map JSON dengan field yang hilang (missing fields) atau bernilai null.
    test('Comment.fromJson mengembalikan default value aman ketika field hilang atau bernilai null', () {
      // 1. Arrange: Siapkan map JSON kosong (semua field hilang)
      // dan map dengan beberapa field bernilai null secara eksplisit.
      final Map<String, dynamic> emptyJson = {};
      final Map<String, dynamic> nullFieldsJson = {
        'postId': null,
        'id': null,
        'name': null,
        'email': null,
        'body': null,
      };

      // 2. Act: Lakukan deserialisasi menggunakan factory Comment.fromJson
      final commentFromEmpty = Comment.fromJson(emptyJson);
      final commentFromNulls = Comment.fromJson(nullFieldsJson);

      // 3. Assert: Pastikan tidak ada exception yang terlempar dan seluruh field
      // terisi dengan nilai fallback default yang aman (null-safe)
      expect(commentFromEmpty.postId, equals(0), reason: 'postId harus 0 jika field hilang');
      expect(commentFromEmpty.id, equals(0), reason: 'id harus 0 jika field hilang');
      expect(commentFromEmpty.name, equals(''), reason: 'name harus string kosong jika field hilang');
      expect(commentFromEmpty.email, equals(''), reason: 'email harus string kosong jika field hilang');
      expect(commentFromEmpty.body, equals(''), reason: 'body harus string kosong jika field hilang');

      // Validasi untuk map dengan field null eksplisit
      expect(commentFromNulls.postId, equals(0));
      expect(commentFromNulls.id, equals(0));
      expect(commentFromNulls.name, equals(''));
      expect(commentFromNulls.email, equals(''));
      expect(commentFromNulls.body, equals(''));
    });

    // Test pelengkap: Menguji fromJson ketika data JSON terisi lengkap
    test('Comment.fromJson berhasil memetakan seluruh field dengan data yang valid', () {
      final Map<String, dynamic> fullJson = {
        'postId': 1,
        'id': 42,
        'name': 'Budi Santoso',
        'email': 'budi@example.com',
        'body': 'Komentar penjelasan pengujian.',
      };

      final comment = Comment.fromJson(fullJson);

      expect(comment.postId, equals(1));
      expect(comment.id, equals(42));
      expect(comment.name, equals('Budi Santoso'));
      expect(comment.email, equals('budi@example.com'));
      expect(comment.body, equals('Komentar penjelasan pengujian.'));
    });

    // Edge case tambahan (hasil verifikasi sendiri atas output AI):
    // API nyata kadang mengirim angka sebagai double (mis. 42.0) atau
    // mengirim tipe yang sama sekali salah (mis. String untuk id).
    // Pola "as num?" aman untuk double, tetapi tipe yang sama sekali
    // berbeda akan menyebabkan TypeError saat cast — ini batas perlindungan
    // fromJson yang perlu diketahui.
    test('Comment.fromJson menerima angka double dari API', () {
      final comment = Comment.fromJson({
        'postId': 1.0,
        'id': 42.0,
        'name': 'Susi',
        'email': 'susi@example.com',
        'body': 'Isi.',
      });
      expect(comment.postId, equals(1));
      expect(comment.id, equals(42));
    });

    test('Comment.fromJson melempar TypeError ketika tipe field tidak kompatibel', () {
      expect(
        () => Comment.fromJson({'id': 'bukan-angka'}),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
