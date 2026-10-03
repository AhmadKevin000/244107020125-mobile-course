# Hasil Pengujian Notifikasi (Tiga App State)

Payload uji yang dikirim dari Firebase Console (campaign **Firebase Notification
messages**):

```json
{
  "notification": {
    "title": "Jadwal kuliah berubah",
    "body": "Kelas Mobile pindah ke Ruang A2 jam 13.00"
  },
  "data": {
    "route": "/pengumuman/3",
    "id": "3"
  }
}
```

`route` mengarah ke halaman detail pengumuman id `3` ("Jadwal kuliah berubah").
Device sudah login sehingga guard rute mengizinkan akses.

## Tabel pengujian

| # | App state | Cara menyiapkan | Yang diharapkan | Hasil | Bukti |
|---|---|---|---|---|---|
| 1 | **Foreground** | App terbuka & login, tidak menekan apa pun | Banner lokal muncul (dibuat manual) | ✅ | <img src="screenshots/11-foreground-banner.png" width="200" /> |
| 2 | Foreground | Ketuk banner | Pindah ke `/pengumuman/3` | ✅ | <img src="screenshots/12-foreground-deeplink.png" width="200" /> |
| 3 | **Background** | Tekan Home (app di belakang) | Banner sistem muncul otomatis | ✅ | <img src="screenshots/13-background-banner.png" width="200" /> |
| 4 | Background | Ketuk banner | Pindah ke `/pengumuman/3` | ✅ | <img src="screenshots/14-background-deeplink.png" width="200" /> |
| 5 | **Terminated** | Swipe-close dari recent apps | Banner muncul walau app mati | ✅ | <img src="screenshots/15-terminated-banner.png" width="200" /> |
| 6 | Terminated | Ketuk banner | Cold start langsung ke `/pengumuman/3` | ✅ | <img src="screenshots/16-terminated-deeplink.png" width="200" /> |

Campaign dikirim dari Firebase Console:

<img src="screenshots/17-konsol-campaign.png" alt="Konsol campaign" width="900" />

## Catatan teknis

- **Foreground** satu-satunya state yang bannernya dibuat oleh app sendiri
  (`flutter_local_notifications`), karena Android tidak menampilkan banner
  otomatis saat aplikasi terbuka.
- **Background** & **terminated** bannernya dibuat oleh sistem Android memakai
  channel `pengumuman` (importance high). Klik diteruskan ke app lewat
  `onMessageOpenedApp` (background) atau `getInitialMessage()` (terminated).
- Tanpa meta-data `com.google.firebase.messaging.default_notification_channel_id`
  dan channel high, background/terminated hanya berbunyi tanpa banner — ini
  yang terjadi di percobaan pertama dan diperbaiki (lihat
  [ai-challenge.md](ai-challenge.md), perbaikan #4).
- App harus **login** sebelum uji terminated; jika tidak, klik notifikasi akan
  dibelokkan ke `/login` oleh guard rute.

## Token lifecycle

| Bukti | Keterangan |
|---|---|
| <img src="screenshots/08-token-fcm.png" width="200" /> | Token awal (`dn1ZSLLBSF-v...`) |
| <img src="screenshots/09-token-berubah.png" width="200" /> | Setelah rotasi (`cxhcYzs6RT-G...`) — membuktikan `onTokenRefresh` |

Token sengaja ditampilkan **terpotong** (12 karakter) sebagai bukti lifecycle
tanpa membocorkan token utuh.
