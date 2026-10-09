# AI Challenge — Week 7

Dokumentasi AI Challenge untuk refactor `campus_notify` menjadi Clean
Architecture feature-first: prompt, usulan AI, keputusan final, checklist
verifikasi, dan hasil tiga grep sterilitas.

## Prompt

> Project Flutter saya: campus_notify (auth + FCM + daftar pengumuman).
> Kondisi kini: folder `lib/{data, providers, pages, messaging}`, repository
> tercampur dengan implementasi, widget memanggil Dio langsung.
>
> Tugas:
> 1. Usulkan struktur feature-first Clean Architecture
>    (presentation/domain/data) untuk fitur auth + announcements.
> 2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).
> 3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana,
>    dan kapan use case benar-benar dibutuhkan vs repository langsung.
> 4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).
> Jelaskan trade-off setiap keputusan.

## Output awal AI

Draf awal mengusulkan struktur feature-first dengan `core/`, dan menaruh
seluruh adapter framework (Dio, secure storage, FCM) di dalam `core/`. Potongan
intinya:

```
lib/
├── core/
│   ├── failures.dart
│   ├── network/api_client.dart      # buildApiClient (Dio)
│   └── storage/token_store.dart     # FlutterSecureStorage
├── features/
│   ├── auth/{domain,data,presentation}
│   └── announcements/{domain,data,presentation}
```

Draf juga mengusulkan **use case untuk setiap operasi**, termasuk passthrough
CRUD satu-baris, dan menyarankan **Model** terpisah untuk setiap entity.

## Usulan AI vs keputusan final

| # | Usulan AI | Keputusan final | Alasan |
|---|---|---|---|
| 1 | Struktur feature-first `{domain,data,presentation}` | **Diterima** | Sesuai codelab; satu fitur bisa dipahami/dihapus tanpa menyentuh fitur lain. |
| 2 | Adapter framework (Dio/storage/FCM) di dalam `core/` | **Diubah** → `lib/infrastructure/` | Grep sterilitas domain memeriksa `lib/core` juga. `import 'package:flutter_secure_storage'` cocok dengan pola `import 'package:flutter`, jadi menaruh adapter di `core` membuat grep berisi hasil. `core` dijaga murni Dart. |
| 3 | Use case untuk **setiap** operasi (termasuk CRUD satu-baris) | **Diterima sebagian** | `Login` (menggabungkan autentikasi + simpan sesi) memang butuh use case. `GetAnnouncements` yang passthrough tetap dibuat **tetapi dicatat sebagai pilihan konsistensi**, bukan kebutuhan. |
| 4 | `Model` terpisah (`AnnouncementModel`, dst) | **Ditolak** | Data mock in-memory tanpa serialisasi JSON/SQLite; model hanya jadi kelas passthrough kosong = over-engineering. Entity dipakai langsung. |
| 5 | Interface repository di domain, impl di data | **Diterima** | Aturan Dependency Inversion; domain tidak bergantung ke data. |
| 6 | Wiring DI lewat Riverpod provider | **Diterima** | Tanpa package DI tambahan; widget tidak membuat repository sendiri. |
| 7 | Penyimpanan token di dalam `AuthRepository` | **Diubah** → port `SessionRepository` terpisah | Agar use case `Login` dapat mengoordinasikan autentikasi dan persistensi tanpa domain menyentuh secure storage. |

## Checklist verifikasi

| # | Item | Temuan |
|---|---|---|
| 1 | Interface repository tinggal di domain, implementasi di data? | ✅ `features/*/domain/repositories/*.dart` berisi `abstract class`; `features/*/data/repositories/*_impl.dart` berisi implementasi. Tidak ada yang digabung dalam satu file. |
| 2 | Domain bebas import Flutter/Dio/SQLite/Firebase? | ✅ Diverifikasi dengan grep (bukan baca sekilas) — lihat bagian "Hasil tiga grep". |
| 3 | AI membuat use case untuk tiap CRUD satu-baris? | ⚠️ Draf ya. Dikoreksi: `Login` dipertahankan (butuh), `GetAnnouncements` dipertahankan dengan alasan konsistensi yang ditulis eksplisit. Tidak menambah use case palsu untuk operasi lain. |
| 4 | Entity bebas mapping (`toMap`/`fromMap`/`toJson` hanya di model)? | ✅ `Announcement` dan `AuthSession` murni tanpa mapping. Karena tidak ada serialisasi, tidak ada model — entity langsung dipakai. |
| 5 | Wiring DI terpusat di provider, widget tidak `new Repository()`? | ✅ Semua wiring di `*_presentation/providers/*.dart` dan `infrastructure/network/api_providers.dart`. Widget hanya `ref.watch`/`ref.read`. |

## Hasil tiga grep sterilitas

```bash
# 1. Presentation steril dari data mentah (harus NOL hasil)
rg "Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode" lib/features/*/presentation

# 2. Domain steril dari framework & package (harus NOL hasil)
rg "import 'package:flutter|import 'package:dio|import 'package:sqflite|import 'package:firebase" lib/features/*/domain lib/core

# 3. Instansiasi manual (DI bocor) di presentation (harus NOL hasil)
rg "Repository\(|Dio\(BaseOptions|TokenStore\(" lib/features/*/presentation
```

| Grep | Hasil |
|---|---|
| 1. Presentation steril | **0 hasil** ✅ |
| 2. Domain + core steril | **0 hasil** ✅ |
| 3. DI bocor di presentation | **0 hasil** ✅ (bukti: `01-struktur-before.png` menunjukkan kondisi awal masih ada 2 temuan di `providers/`; setelah refactor hilang) |

## Keputusan final (alasan teknis)

1. **`core` murni, adapter di `infrastructure`.** Bukan sekadar selera: grep
   sterilitas domain codelab juga memeriksa `lib/core`, sehingga adapter
   framework wajib berada di luar `core` agar aturan dependensi benar-benar
   terbukti oleh alat, bukan hanya diklaim.
2. **Use case `Login` dipertahankan, `GetAnnouncements` dicatat sebagai
   konsistensi.** Menghindari over-engineering sekaligus tetap punya contoh
   use case yang benar-benar beralasan.
3. **Tanpa Model.** Sesuai prinsip codelab sendiri: model hanya bernilai bila
   ada batas serialisasi. Di sini tidak ada, jadi entity dipakai langsung.
4. **`SessionRepository` sebagai port terpisah.** Memungkinkan `Login`
   mengoordinasikan dua sumber tanpa mencampur domain dengan secure storage,
   dan memudahkan pengujian use case dengan fake.

## Tanggung jawab teknis

Saat demo, arah panah dependensi dapat digambar tanpa catatan:

```
presentation ──▶ domain ◀── data
   (UI, provider)   (entity, interface,    (impl, datasource,
                     use case, Failure)      Dio, secure storage)

core (failures) ── murni Dart, dipakai semua layer
infrastructure ── adapter framework lintas-fitur
```
