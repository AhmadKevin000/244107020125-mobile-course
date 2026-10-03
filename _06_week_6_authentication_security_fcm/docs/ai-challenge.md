# AI Challenge — Week 6

Dokumentasi penggunaan AI selama pengerjaan minggu 6, termasuk koreksi yang
harus dilakukan manual karena output awal tidak langsung benar.

## Prompt yang dipakai

> Buatkan aplikasi Flutter "Campus Notify" dengan: (1) login memakai
> repository mock yang mengembalikan access + refresh token, (2) token
> disimpan di `flutter_secure_storage`, (3) Dio interceptor yang otomatis
> refresh saat `401` lalu mengulang request sekali, (4) guard GoRouter agar
> halaman pengumuman hanya bisa diakses saat login, (5) FCM dari
> `firebase_messaging` dengan handler foreground/background/terminated, dan
> (6) deep link dari notifikasi ke `/pengumuman/:id`. Sertakan unit test.

## Output awal AI

AI menghasilkan struktur yang benar secara arsitektur (repository, provider,
router, push service terpisah), tetapi beberapa potongan **tidak bisa
langsung dikompilasi** atau berperilaku salah.

## Koreksi manual

### 1. API `flutter_local_notifications` v22 memakai named argument

Output awal memakai positional argument ala versi lama:

```dart
await _local.initialize(InitializationSettings(android: android, iOS: ios));
await _local.show(0, title, body, details);
```

Versi 22 mewajibkan named argument:

```dart
await _local.initialize(
  settings: const InitializationSettings(android: android, iOS: ios),
  onDidReceiveNotificationResponse: (response) => ...,
);
await _local.show(
  id: message.hashCode,
  title: ...,
  body: ...,
  notificationDetails: ...,
  payload: ...,
);
```

### 2. `refreshListenable` boolean tidak memicu redirect ulang

Output awal memakai `ValueNotifier<bool>` untuk status login. Saat status
berubah `false → false` (mis. pembacaan token selesai tetapi hasilnya tetap
belum login), notifier tidak mengirim notifikasi sehingga guard tidak
dijalankan ulang. Diperbaiki dengan `ValueNotifier<int>` yang **selalu naik**:

```dart
ref.listen(authStateProvider, (_, _) => refresh.value++);
```

### 3. `getToken()` bisa menggantung saat startup

Tanpa batas waktu, `getToken()` dapat menahan startup ketika layanan Firebase
Installations tidak terjangkau. Ditambahkan timeout 10 detik, dan listener
`onTokenRefresh` tetap dipasang setelahnya:

```dart
final token = await FirebaseMessaging.instance
    .getToken()
    .timeout(const Duration(seconds: 10));
```

### 4. Banner background tidak muncul (hanya suara + ikon)

Ini koreksi paling penting dan **tidak terdeteksi** sampai pengujian manual di
device. Notifikasi background ditampilkan oleh sistem memakai channel default
ber-importance rendah, sehingga tidak ada heads-up banner. Perbaikan:

- meta-data di `AndroidManifest.xml`:

  ```xml
  <meta-data
      android:name="com.google.firebase.messaging.default_notification_channel_id"
      android:value="pengumuman" />
  ```

- channel `pengumuman` (importance tinggi) dibuat eksplisit saat init, karena
  importance channel bersifat *immutable* setelah dibuat.

### 5. Duplikasi literal path rute

Output awal menyebar string `'/pengumuman'` di router, halaman, dan handler.
Direfaktor ke `lib/routes.dart` (`AppRoute` + `routeFromMessage()`), yang juga
membuat logika deep link bisa diuji sebagai fungsi murni.

### 6. Pemetaan error tersebar

Pesan error awalnya dirakit di masing-masing halaman dengan
`replaceFirst('Exception: ', '')`. Dipusatkan ke `lib/data/api_errors.dart`
(`messageForError()`) supaya konsisten dan dapat diuji.

## Verifikasi

| Verifikasi | Hasil |
|---|---|
| `flutter analyze` | 0 error/warning (1 info `package_names`) |
| `flutter test` | 16 test lolos |
| `flutter build apk --debug` | sukses |
| Uji manual FCM 3 kondisi | foreground, background, terminated semua berhasil (lihat README) |

## Pelajaran

AI sangat membantu menyusun kerangka arsitektur, tetapi detail versi paket,
perilaku platform Android (channel notifikasi), dan nuansa API seperti
`refreshListenable` tetap harus diverifikasi lewat `flutter analyze`, unit
test, dan — yang paling menentukan — pengujian manual di perangkat. Kegagalan
banner background hanya ketahuan saat diuji langsung, bukan dari kode.
