# Dokumentasi Verifikasi Hasil AI

Praktikum minggu 3 — Navigation & State Management (Riverpod + GoRouter)

## Apa yang dikerjakan

1. **Memisahkan widget bar ToDo** menjadi `TodoTile` (`lib/widgets/todo_tile.dart`) supaya kode `TodoPage` lebih pendek dan gampang dites.
2. **Membuat provider turunan** `uncompletedTodosProvider` di `lib/providers/todo_provider.dart`. Provider ini tidak menyimpan data sendiri, cuma "membaca" `todoListProvider` lalu menyaring tugas yang belum selesai. Dipakai untuk teks "Belum selesai: X dari Y".
3. **Menghubungkan aplikasi ke GoRouter** di `lib/main.dart`:
   - `/` → halaman ToDo
   - `/stats` → halaman Statistik
   - Keduanya dibungkus `StatefulShellRoute` + `NavigationBar` (2 tab di bawah, mirip bottom-nav aplikasi umum).
   - Rute `/home/detail/:id` tetap ada supaya navigasi detail bisa diakses langsung dari URL.

## Pemeriksaan hasil kode AI

| Yang dicek | Hasil |
|---|---|
| State diubah secara immutable (tanpa `state.add()` / mutasi list) | Aman — semua perubahan membuat list baru seperti `[...state, item]` |
| `ref.watch` hanya di dalam `build`, `ref.read` di callback | Aman — dicek lewat pencarian di seluruh folder `lib` |
| UI menangani loading, error, dan success | Aman — `StatsPage` dan `ProductPage` memakai `when()` lengkap |
| Provider bertipe eksplisit dan tidak duplikat | Aman — semua provider unik dan bertipe jelas |
| Tidak memakai API Riverpod lama (`StateProvider`, `StateNotifierProvider`, `setState`) | Aman — semuanya pakai pola `Notifier` / `AsyncNotifier` + `ConsumerWidget` |

**Catatan unik:** saat testing, ketemu fitur Riverpod 3 yang otomatis mencoba ulang request yang gagal (auto-retry). Akibatnya state error tidak langsung muncul. Solusinya auto-retry dimatikan lewat `retry: (_, _) => null` di `statsProvider` supaya state error benar-benar tampil di UI.

## Hasil flutter analyze dan flutter test

```
flutter analyze
→ Hanya 1 info soal nama package (karena nama folder mata kuliah
  mengandung angka). Tidak ada warning/error.

flutter test
→ 00:00 +7: All tests passed!
```

7 test tersebut terdiri dari:
- 4 unit test provider statistik: state awal loading, berhasil dapat 3 data, gagal jadi AsyncError, dan retry pulih ke success (simulasi gagal/sukses dibuat pasti lewat override, bukan acak beneran).
- 3 widget test: menambah tugas lewat dialog, pindah tab Stats lalu kembali (data ToDo tidak hilang), dan teks "Belum selesai" berubah saat tugas dicentang.

## Checklist verifikasi mandiri

- [x] Navigasi GoRouter bekerja: pindah tab lewat NavigationBar, dan path detail bisa diakses langsung.
- [x] `ProviderScope` membungkus root aplikasi; state ToDo tetap ada saat pindah tab.
- [x] UI AsyncValue menangani loading, error, dan success — bukan cuma success.
- [x] `flutter analyze` tanpa issue dari kode, semua test lulus.
- [x] Hasil AI sudah diperiksa dan didokumentasikan di file ini.

## Cara uji manual

1. Jalankan `flutter run`.
2. Tab **ToDo**: tambah tugas lewat tombol +, centang, hapus. Perhatikan teks "Belum selesai" ikut berubah.
3. Pindah ke tab **Stats** lalu balik lagi: daftar tugas tidak hilang.
4. Tab **Stats**: kadang loading, kadang error (ada tombol Coba lagi), kadang langsung berhasil — ini sesuai simulasi gagal 30%.
5. Buka path `/home/detail/5` langsung di browser/emulator untuk membuktikan navigasi detail bekerja.
