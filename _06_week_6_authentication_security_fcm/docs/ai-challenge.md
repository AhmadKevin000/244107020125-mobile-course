# AI Challenge — Week 6

Dokumentasi AI Challenge: prompt, output awal AI, perbaikan manual, checklist
verifikasi, dan keputusan teknis.

## Prompt

> Aplikasi Flutter Campus Notification App.
> Stack: firebase_messaging, flutter_local_notifications,
> flutter_secure_storage, go_router, Riverpod.
> Buatkan PushService dengan:
> - requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
> - onMessage (tampilkan local notification manual)
> - onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
> - subscribe/unsubscribe topic pengumuman-kampus
> - background handler top-level dengan @pragma('vm:entry-point')
> Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
> dan bagian yang tidak boleh mengakses BuildContext.

## Output awal AI

Draf awal menghasilkan `PushService` dengan struktur yang benar (permission,
token, tiga handler, topik, background handler top-level). Potongan intinya:

```dart
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

void listenForeground() {
  FirebaseMessaging.onMessage.listen((message) async {
    await _local.show(...);        // banner manual saat app terbuka
  });
}

void listenOpened() {
  FirebaseMessaging.onMessageOpenedApp.listen((m) => _navigate(m.data['route']));
}

Future<void> handleTerminated() async {
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) _navigate(initial.data['route']);
}
```

Draf ini **diterima kerangkanya**, tetapi beberapa detail tidak bisa langsung
dipakai (lihat "Perbaikan manual"). Kode finalnya ada di
`lib/messaging/push_service.dart`.

## Bagian yang berbeda: Android 13+ vs iOS

| Aspek | Android 13+ | iOS |
|---|---|---|
| Izin notifikasi | Permission `POST_NOTIFICATIONS` diminta runtime; wajib di `AndroidManifest.xml` | `requestPermission(alert/badge/sound)`; tanpa langkah manifest |
| Notification channel | Wajib (Android 8+). Channel `pengumuman` importance **high** agar heads-up banner muncul | Tidak ada konsep channel |
| Banner saat foreground | Sistem **tidak** menampilkan apa pun → harus `flutter_local_notifications` | Bisa lewat foreground presentation options atau local notification |
| Token | `getToken()` langsung dari FCM | Butuh konfigurasi APNs (key/entitlement) sebelum token terbit |
| Background handler | Berjalan di isolate terpisah (top-level wajib) | Dibatasi; data message butuh `content-available` |
| Meta-data default channel | `com.google.firebase.messaging.default_notification_channel_id` | Tidak berlaku |

## Bagian yang tidak boleh mengakses BuildContext

- **`firebaseMessagingBackgroundHandler`** — berjalan di isolate terpisah tanpa
  pohon widget, jadi tidak ada `BuildContext` (juga tidak ada Riverpod/state UI).
- **Semua fungsi di `push_service.dart`** — sengaja bebas UI. Navigasi tidak
  memakai `context.go` melainkan `go` yang disuntikkan lewat `attachRouter`.
- **`initFcmToken` / `listenForeground` / `listenOpened` / `handleTerminated`** —
  hanya boleh menyentuh plugin, bukan widget.

Konsekuensinya, penentuan route dipisah ke fungsi murni `routeFromMessage()`
(`lib/routes.dart`) yang bisa diuji tanpa widget test.

## Perbaikan manual atas draf AI

| # | Temuan | Perbaikan |
|---|---|---|
| 1 | `flutter_local_notifications` v22 memakai **named argument**; draf memakai positional | `initialize(settings: ...)`, `show(id: ..., title: ..., ...)` |
| 2 | `refreshListenable` boolean tidak memicu redirect saat `false → false` | `ValueNotifier<int>` yang selalu naik |
| 3 | `getToken()` tanpa timeout bisa menahan startup | `.timeout(Duration(seconds: 10))`, `onTokenRefresh` tetap dipasang |
| 4 | Notifikasi background hanya suara + ikon, tanpa banner | Meta-data `default_notification_channel_id` + buat channel high eksplisit |
| 5 | Path rute tersebar sebagai literal string | Refaktor ke `AppRoute` (`lib/routes.dart`) |
| 6 | Pesan error dirakit di tiap halaman | Dipusatkan di `messageForError()` (`lib/data/api_errors.dart`) |
| 7 | Sesi tidak langsung logout saat refresh mati (hanya `store.clear()`) | Callback `onSessionExpired` → `authStateProvider.notifier.logout()` |

## Checklist verifikasi

| # | Item | Temuan |
|---|---|---|
| 1 | Background handler top-level + `@pragma('vm:entry-point')`? | ✅ `firebaseMessagingBackgroundHandler` di `push_service.dart`, bukan method kelas |
| 2 | `onTokenRefresh` benar-benar mengirim token baru, bukan cuma log? | ✅ `initFcmToken(onToken:)` menyimpan token baru ke `fcmTokenProvider` dan disiapkan untuk `POST /devices`. Tidak ada `print`/`debugPrint` token di kode |
| 3 | Foreground pakai local notification manual? | ✅ `listenForeground()` memanggil `_local.show(...)` dengan channel high |
| 4 | Klik dari 3 state masuk rute benar? | ✅ tabel pengujian di [testing.md](testing.md) |
| 5 | Token/secret tidak hardcode & tidak di-log penuh? | ✅ tidak ada log token; kartu Debug menampilkan 12 karakter + `...`. Kredensial login mock di-hardcode sengaja (bukan secret produksi) dan didokumentasikan |

## Keputusan final

1. **Auth tetap mock**, bukan Firebase Auth. Codelab mengizinkan
   "mock/Firebase Auth". Mock dipilih agar fokus tetap pada **pola keamanan
   token** (secure storage + refresh 401 + guard), yang justru lebih jelas
   terlihat dengan kontrak token tiruan. Menggantinya ke
   `FirebaseAuth.signInWithEmailAndPassword` cukup di `AuthRepository` karena
   pemanggil hanya bergantung pada `AuthSession`.
2. **Background handler sengaja kosong.** Codelab menegaskan jangan melakukan
   pekerjaan berat di isolate background dan navigasi dilakukan saat diketuk.
   Isi kosong + komentar adalah bentuk paling aman.
3. **Navigasi lewat callback `attachRouter`, bukan `context`.** Memenuhi
   syarat "tidak boleh akses BuildContext" sekaligus membuat handler bisa
   diuji.
4. **`routeFromMessage` sebagai fungsi murni.** Memenuhi tuntutan "minimal 2
   test yang lulus (parsing route)".

## Verifikasi

| Verifikasi | Hasil |
|---|---|
| `flutter analyze` | 0 error/warning (1 info `package_names`) |
| `flutter test` | 19 test lolos |
| `flutter build apk --debug` | sukses |
| Uji manual FCM 3 state | lihat [testing.md](testing.md) |

## Tanggung jawab teknis

Saat demo, lifecycle token dapat dijelaskan tanpa catatan:

1. **Terbit** — `getToken()` saat init; token awal dikirim ke backend.
2. **Berubah** — `onTokenRefresh` menangkap token baru (reinstall, clear data,
   rotasi keamanan) dan mengirim ulang. Tanpa ini backend menyimpan token
   basi dan push berhenti tanpa error.
3. **Dipakai** — token disimpan aman (secure storage) dan dipakai backend
   untuk mengirim pesan.
4. **Mati** — refresh token mati → `401` → `store.clear()` +
   `onSessionExpired()` → login ulang.
