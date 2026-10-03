# Week 6 — Authentication, Security & FCM (Flutter)

Laporan praktikum minggu 6 mata kuliah Mobile Programming.

Nama: Ahmad Kevin Malik
NIM: 244107020125

---

## Tujuan

- Menyimpan token autentikasi dengan aman di penyimpanan terenkripsi perangkat,
  bukan di SharedPreferences biasa.
- Menerapkan alur login + refresh token otomatis saat backend membalas `401`.
- Melindungi halaman dengan guard rute sehingga halaman privat tidak bisa
  dibuka tanpa sesi yang sah.
- Mengintegrasikan Firebase Cloud Messaging (FCM) untuk menerima notifikasi
  pengumuman kampus.
- Menangani notifikasi di tiga kondisi aplikasi: foreground, background, dan
  terminated, termasuk deep link ke halaman pengumuman.
- Menguji logika rute dan pemetaan error dengan unit test murni.

## Stack Teknologi

- Flutter (Material 3)
- [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) — state management
- [go_router](https://pub.dev/packages/go_router) — navigasi deklaratif + guard
- [dio](https://pub.dev/packages/dio) — HTTP client + interceptor refresh token
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) — penyimpanan token terenkripsi
- [firebase_core](https://pub.dev/packages/firebase_core) + [firebase_messaging](https://pub.dev/packages/firebase_messaging) — FCM
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) — banner notifikasi saat foreground
- flutter_test — unit test

## Arsitektur

### Alur autentikasi & keamanan token

```
UI (LoginPage)
   │ login(email, password)
   ▼
AuthNotifier (Riverpod)                    lib/providers/auth_provider.dart
   │ AuthRepository.login()                lib/data/auth_repository.dart
   ▼
TokenStore.save(access, refresh)           lib/data/token_store.dart
   │  → FlutterSecureStorage (Keychain/Keystore)
   ▼
AuthNotifier build() membaca access token  → authStateProvider (bool)
   │
   ▼
GoRouter redirect: belum login → /login    lib/router.dart
```

Token **tidak pernah** disimpan di SharedPreferences. `TokenStore` adalah
satu-satunya pintu masuk/keluar token, memakai `FlutterSecureStorage` yang
dienkripsi di level OS (Keychain iOS, Keystore Android).

### Refresh token otomatis (401)

`buildApiClient()` (`lib/data/api_client.dart`) memasang interceptor Dio:

1. **onRequest** — menyisipkan `Authorization: Bearer <access>`.
2. **onError** — saat balasan `401`:
   - jika request ini **sudah** pernah di-retry (ditandai `extra`), token
     dianggap mati → `store.clear()` dan error diteruskan;
   - jika belum, refresh token ditukar lewat `AuthRepository.refresh()`,
     token baru disimpan, lalu request asli diulang **sekali**.

Penanda `_retriedAfterRefresh` mencegah loop refresh tanpa henti bila server
terus membalas `401`.

### Guard rute

`routerProvider` memakai `redirect` yang membaca `authStateProvider`:

- `auth.isLoading` → `null` (tunggu pembacaan token selesai);
- belum login & bukan di `/login` → pindah ke `/login`;
- sudah login & berada di `/login` → pindah ke `/`.

`refreshListenable` berupa `ValueNotifier<int>` yang **selalu naik** setiap
status auth berubah. Nilai boolean tidak berubah saat `false → false`, jadi
counter dipakai agar GoRouter tetap menjalankan ulang redirect.

### FCM & deep link

```
main()
 ├─ registerBackgroundHandler()        ← wajib sebelum runApp
 ├─ runApp(...)
 └─ addPostFrameCallback
      ├─ attachRouter(router.go)       ← router siap, deep link bisa jalan
      ├─ listenOpened()                ← background → diketuk
      └─ handleTerminated()            ← terminated → getInitialMessage()
```

Handler di `lib/messaging/push_service.dart` **tidak tahu** soal GoRouter.
Mereka hanya memanggil `go(route)` yang disuntikkan lewat `attachRouter`.
Route diambil dari `routeFromMessage(message.data)` (`lib/routes.dart`), jadi
handler tidak menyentuh `Map` secara langsung dan logikanya bisa diuji.

Tiga kondisi notifikasi:

| Kondisi | Handler | Perilaku |
|---|---|---|
| Foreground | `FirebaseMessaging.onMessage` | banner dibuat manual lewat `flutter_local_notifications` |
| Background | `onMessageOpenedApp` | banner dari sistem, klik → `router.go` |
| Terminated | `getInitialMessage()` | app cold start, langsung ke route notifikasi |

## Struktur Project

```
lib/
├── main.dart                       # init Firebase, background handler, wiring push
├── router.dart                     # GoRouter + guard auth
├── routes.dart                     # konstanta rute + routeFromMessage()
├── data/
│   ├── announcements.dart          # data mock pengumuman
│   ├── api_client.dart             # Dio + interceptor refresh 401
│   ├── api_errors.dart             # messageForError(): error → pesan ramah
│   ├── auth_repository.dart        # AuthRepository mock (kontrak token)
│   └── token_store.dart            # FlutterSecureStorage (Keychain/Keystore)
├── messaging/
│   └── push_service.dart           # handler FCM 3 kondisi + topik
├── pages/
│   ├── login_page.dart             # form login
│   ├── home_page.dart              # daftar pengumuman + kartu Debug FCM
│   └── announcement_page.dart      # detail pengumuman berdasarkan id
└── providers/
    ├── auth_provider.dart          # tokenStore, authRepository, apiClient, authState
    └── push_provider.dart          # fcmTokenProvider

test/
├── deep_link_test.dart             # unit test routeFromMessage + AppRoute
└── auth_test.dart                  # unit test AuthRepository + messageForError
```

---

## Langkah Pengerjaan

### Langkah 1 — Praktikum 1: Login, secure storage, refresh token, guard

**Halaman login** memvalidasi kredensial lewat `AuthRepository` mock
(`mahasiswa@kampus.ac.id` / `rahasia123`). Pesan gagal ditampilkan lewat
SnackBar:

![Login](screenshots/01-login.png)
![Login gagal](screenshots/02-login-gagal.png)

**Token disimpan aman.** Setelah login, `TokenStore.save()` menulis access &
refresh token ke `FlutterSecureStorage`. Karena `authStateProvider`
menurunkan status login dari ada/tidaknya access token, sesi bertahan setelah
app ditutup dan dibuka lagi.

**Guard rute.** Membuka `/pengumuman/1` tanpa login akan dibelokkan ke
`/login`. Setelah login, halaman daftar pengumuman tampil:

![Home pengumuman](screenshots/03-home-pengumuman.png)

**Halaman detail** membaca konten dari satu sumber data berdasarkan `id`, jadi
daftar dan deep link FCM menunjuk ke konten yang sama:

![Detail UKT](screenshots/04-detail-ukt.png)
![Detail beasiswa](screenshots/05-detail-beasiswa.png)
![Detail jadwal](screenshots/06-detail-jadwal.png)

### Langkah 2 — Praktikum 2: Firebase & FCM setup

- Project Firebase **"Campus Notify"** (project id `campus-notify-3bc1d`).
- `google-services.json` diletakkan di `android/app/`.
- Plugin Gradle `com.google.gms.google-services` **4.5.0** ditambahkan di
  `android/settings.gradle.kts` (apply false) dan `android/app/build.gradle.kts`.
- Izin `POST_NOTIFICATIONS` ditambahkan di `AndroidManifest.xml`.
- Core library desugaring diaktifkan (dibutuhkan `flutter_local_notifications`).

**Izin notifikasi** diminta saat pertama kali app berjalan:

![Izin notifikasi](screenshots/07-izin-notifikasi.png)

**Token lifecycle.** `initFcmToken()` mengambil token awal lewat `getToken()`
(dengan timeout 10 detik agar tidak memblokir startup), lalu memantau
perubahan lewat `onTokenRefresh`. Kartu Debug FCM menampilkan token
**terpotong** (12 karakter) untuk bukti lifecycle tanpa membocorkan token utuh:

![Token FCM](screenshots/08-token-fcm.png)
![Token berubah](screenshots/09-token-berubah.png)

Kedua screenshot menampilkan token yang **berbeda** (`dn1ZSLLBSF-v...` vs
`cxhcYzs6RT-G...`), membuktikan `onTokenRefresh` bekerja.

**Notifikasi diterima** di emulator:

![Notifikasi masuk](screenshots/10-notifikasi-masuk.png)

### Langkah 3 — Praktikum 3: Handler 3 kondisi + deep link

**Background handler** wajib top-level dan memakai `@pragma('vm:entry-point')`
karena berjalan di isolate terpisah:

```dart
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}
```

Handler ini didaftarkan **sebelum** `runApp()` supaya pesan saat app tidak
aktif tetap tertangani.

**Deep link.** Payload notifikasi berisi custom data `route` (atau `id`), yang
diterjemahkan `routeFromMessage()` menjadi path. Klik notifikasi memanggil
`router.go(path)` sehingga pengguna langsung dibawa ke halaman pengumuman.

**Topik.** Perangkat otomatis subscribe ke `pengumuman-kampus` saat init, dan
tersedia `subscribeTopic()` / `unsubscribeTopic()` untuk kontrol manual.

---

## Pengujian

### Verifikasi manual — matriks 3 kondisi FCM

Payload uji: title `Jadwal kuliah berubah`, body
`Kelas Mobile pindah ke Ruang A2 jam 13.00`, custom data
`route=/pengumuman/3`.

| Kondisi | Kondisi app | Yang diharapkan | Hasil | Bukti |
|---|---|---|---|---|
| Foreground | App terbuka | Banner lokal muncul | ✅ | ![fg](screenshots/11-foreground-banner.png) |
| Foreground | Setelah diketuk | Pindah ke `/pengumuman/3` | ✅ | ![fg-link](screenshots/12-foreground-deeplink.png) |
| Background | Ditekan Home | Banner sistem muncul | ✅ | ![bg](screenshots/13-background-banner.png) |
| Background | Setelah diketuk | Pindah ke `/pengumuman/3` | ✅ | ![bg-link](screenshots/14-background-deeplink.png) |
| Terminated | App dimatikan | Banner muncul | ✅ | ![term](screenshots/15-terminated-banner.png) |
| Terminated | Setelah diketuk | Cold start langsung ke `/pengumuman/3` | ✅ | ![term-link](screenshots/16-terminated-deeplink.png) |

Campaign dikirim dari Firebase Console (Messaging):

![Konsol campaign](screenshots/17-konsol-campaign.png)

**Catatan penting:** pada background & terminated, banner ditampilkan oleh
sistem Android memakai channel notifikasi. Supaya muncul **heads-up banner**
(bukan hanya suara + ikon), app merujuk channel `pengumuman` ber-importance
tinggi lewat meta-data `com.google.firebase.messaging.default_notification_channel_id`
di `AndroidManifest.xml`, dan channel tersebut dibuat eksplisit saat init.

### Verifikasi statis

```bash
flutter analyze
```

Hasil: **0 error/warning** — hanya 1 lint info `package_names` (nama folder
tugas diawali underscore mengikuti struktur repo kursus) yang dibiarkan.

### Unit test

```bash
flutter test
```

Hasil: **16 test lolos**.

| File | Cakupan |
|---|---|
| `test/deep_link_test.dart` | `routeFromMessage()` (route eksplisit, fallback `id`, data kosong, route tidak valid) dan `AppRoute.announcementOf()` |
| `test/auth_test.dart` | `AuthRepository` (login sukses/gagal, refresh sukses/gagal) dan `messageForError()` (401, 404, 5xx, timeout, connection error, Exception biasa) |

---

## AI Challenge

Prompt, output awal AI, koreksi manual, dan keputusan akhir didokumentasikan di
[docs/ai-challenge.md](docs/ai-challenge.md).

## Cara Menjalankan

```bash
flutter pub get
flutter run
```

> Catatan: setelah mengubah plugin native atau `AndroidManifest.xml`, lakukan
> **full restart** (`flutter run` ulang), bukan hot reload.

Kredensial login mock:

- Email: `mahasiswa@kampus.ac.id`
- Kata sandi: `rahasia123`

Perintah verifikasi:

```bash
flutter analyze
flutter test
```

## Refleksi

**Mengapa token tidak boleh di SharedPreferences?**
SharedPreferences menyimpan data sebagai teks polos yang bisa dibaca lewat
backup atau akses root. Access/refresh token adalah kredensial setara kata
sandi; `FlutterSecureStorage` menyimpannya di Keychain/Keystore yang dienkripsi
OS, sehingga kebocoran file preferensi tidak otomatis membocorkan sesi.

**Mengapa refresh 401 hanya boleh di-retry sekali?**
Tanpa penanda, server yang terus membalas `401` akan memicu refresh berulang
tanpa henti (loop) dan membebani backend. Menandai request yang sudah di-retry
membuat percobaan kedua menyerah dan memaksa login ulang — kegagalan yang jelas
lebih baik daripada loop yang senyap.

**Mengapa handler FCM dipisah dari router?**
Handler background berjalan di isolate terpisah tanpa `BuildContext`, jadi
tidak boleh menyentuh widget atau Riverpod. Dengan menyuntikkan `go` lewat
`attachRouter`, `push_service.dart` tetap bebas dari ketergantungan UI dan
logika penentuan route (`routeFromMessage`) menjadi fungsi murni yang mudah
diuji.

## Kesimpulan

Autentikasi pada aplikasi ini dibangun di atas tiga pilar: **penyimpanan token
yang aman** (`FlutterSecureStorage`), **refresh otomatis sekali coba** pada
`401`, dan **guard rute** yang menjaga halaman privat. Sesi bertahan lintas
restart tanpa menaruh kredensial di tempat yang bisa dibaca bebas.

Integrasi FCM melengkapi aplikasi dengan notifikasi pengumuman yang tertangani
di ketiga kondisi (foreground, background, terminated) dan mampu membawa
pengguna langsung ke konten yang relevan lewat deep link. Pemisahan antara
`push_service` (tanpa UI) dan `router` membuat alur ini dapat diuji, dan
pemetaan error yang terpusat di `api_errors.dart` menjaga pesan ke pengguna
tetap ramah sekaligus konsisten.
