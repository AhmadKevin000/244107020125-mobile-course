# AI Challenge — Minggu 4: Networking & REST API

## 1. Prompt yang digunakan

Prompt dikirim ke AI coding assistant (Gemini via Antigravity):

```
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error ramah pengguna untuk timeout, connection error, 404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.
```

## 2. Output awal AI

AI menghasilkan 4 file:

- `lib/data/models/comment.dart` — model dengan `fromJson` aman null.
- `lib/data/repositories/comment_repository.dart` — repository + `fetchComments(postId)`.
- `lib/data/comment_providers.dart` — provider family + `commentFriendlyErrorMessage`.
- `test/comment_model_test.dart` dan `test/comment_error_and_repo_test.dart` — unit test.

AI mengklaim: `flutter test` 6 tests passed dan `flutter analyze` no issues.

## 3. Hasil verifikasi (AI Verification Checklist)

| Checklist | Hasil |
|---|---|
| UI memanggil Dio langsung? | Aman — tidak ada UI yang memanggil Dio; semua akses data lewat repository + provider. |
| fromJson aman null? | Aman — pola `as num? ?? 0` dan `as String? ?? ''` konsisten di semua field. |
| Semua DioExceptionType dipetakan? | Lengkap — timeout, connectionError, badResponse (404/500/kode lain), bahkan `cancel`. |
| baseUrl/timeout terpusat? | **Pelanggaran ditemukan.** AI menaruh `sendTimeout`/`receiveTimeout` per-request via `Options` di repository, padahal timeout 10 detik sudah terpusat di `api_client.dart` (BaseOptions). Ini melanggar prinsip "konfigurasi jaringan hidup di satu tempat". |
| Test menguji field hilang? | Ya, bukan happy path saja. Tapi checklist mewajibkan minimal 1 edge case tambahan buatan sendiri — belum ada dari AI. |
| flutter analyze bersih? | **Klaim tidak sepenuhnya benar.** Analyze scope terbatas file AI memang bersih, tetapi full-project analyze masih menemukan 1 warning (unused import di main.dart) dan 1 test bawaan `flutter create` (`widget_test.dart` counter app) yang gagal karena tidak lagi relevan. |

## 4. Perbaikan yang saya lakukan

1. **Timeout dipusatkan kembali.** Menghapus `Options(sendTimeout, receiveTimeout)` per-request di `comment_repository.dart` agar timeout diwarisi dari `BaseOptions` di `api_client.dart`. Alasan: kalau suatu saat timeout perlu diubah, cukup ubah satu tempat.
2. **Menambah 2 edge case test sendiri** di `test/comment_model_test.dart`:
   - Angka dikirim sebagai double (`42.0`) → harus tetap ter-parse jadi `int` (kasus nyata di API PHP/JS).
   - Tipe sama sekali salah (`'id': 'bukan-angka'`) → terbukti `fromJson` masih melempar `TypeError`; pola cast defensif hanya melindungi dari null/tipe numerik, bukan tipe arbitrary. Ini dokumentasi batas perlindungan model.
3. **Memperbaiki `widget_test.dart`** yang masih test counter app bawaan dan gagal — diganti smoke test yang sesuai aplikasi sekarang (AppBar "Posts API" tampil).
4. **Menghapus unused import** `post_list_page.dart` di `main.dart` (warning analyzer).
5. **Bug fix pagination** di `paged_post_page.dart`: saat list halaman pertama (10 item) masih muat dalam satu layar, `ScrollController` tidak pernah terpanggil sehingga `loadNextPage()` tidak pernah jalan dan list mentok di 10 item. Ditambahkan auto-load via `addPostFrameCallback` yang memuat halaman berikutnya selama konten belum memenuhi layar, dengan guard yang sama (`hasMore`, `isLoadingMore`) agar tidak terjadi request ganda.

## 5. Hasil testing

```
flutter test      → 9 tests lulus (model + edge case, error mapping, provider, smoke test UI)
flutter analyze   → 0 warning/error; tersisa 1 lint `info` package_names karena nama
                    folder tugas dari dosen (`_04_week_4_...`) diawali underscore —
                    sengaja tidak diubah agar sesuai struktur repo kursus.
```

## 6. Kesimpulan

Output AI layak dipakai sebagai fondasi tetapi tidak sempurna: ada pelanggaran kecil prinsip konfigurasi terpusat, klaim "no issues" yang hanya berlaku pada scope terbatas, dan test bawaan yang gagal tidak dilaporkan. Verifikasi manual (menjalankan test dan analyze sendiri, membaca setiap file) tetap wajib sebelum kode AI diterima.
