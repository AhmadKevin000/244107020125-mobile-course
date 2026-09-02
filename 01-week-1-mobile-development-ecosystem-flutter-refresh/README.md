# Laporan Praktikum Minggu 1 - Pemrograman Mobile

**Nama:** Ahmad Kevin Malik Zakaria  
**NIM:** 244107020125  
**Kelas:** TI-3E  
**No. Absen:** 05  

---

## 1. Langkah Setup dan Penginstalan

Melakukan instalasi dan setup *environment* Flutter dengan langkah-langkah berikut:

### A. Penginstalan Flutter SDK
1. Mengunduh Flutter SDK versi macOS Apple Silicon (ARM64) dari website resmi Flutter.
2. Mengekstrak file SDK ke direktori `~/development/flutter`.
3. Menambahkan path Flutter ke file `~/.zshrc` agar perintah `flutter` bisa dipanggil di terminal:
   ```bash
   export PATH="$PATH:$HOME/development/flutter/bin"
   ```
4. Menjalankan `source ~/.zshrc` dan `flutter upgrade` untuk memastikan Flutter serta Dart SDK ter-update ke versi terbaru.

![Flutter Upgrade](screenshots/Screenshot%202026-09-02%20at%2019.01.11.png)

### B. Penginstalan Dart SDK
- Dart SDK sudah langsung ada di dalam folder Flutter SDK, jadi tidak perlu menginstalnya lagi.

### C. Penginstalan Android Studio & Setup Emulator
1. Mengunduh dan menginstal **Android Studio** versi Mac Apple Silicon.
2. Menginstal Android SDK dan komponen pendukungnya lewat SDK Manager.
3. Menginstal plugin **Flutter** dan **Dart** di Android Studio.
4. Membuat emulator Android
5. Menyetujui lisensi SDK dengan menjalankan perintah `flutter doctor --android-licenses`.

### D. Membuat Project Pertama
Membuat project baru bernama `my_first_app` dengan perintah:
```bash
flutter create my_first_app
```

![Flutter Create Project](screenshots/Screenshot%202026-09-02%20at%2019.03.32.png)

### E. Cek Verifikasi (`flutter doctor`)
Memastikan semua setup sudah siap dengan menjalankan perintah:
```bash
flutter doctor
```

![Flutter Doctor Output](screenshots/Screenshot%202026-09-02%20at%2018.59.51.png)

Pada bagian Xcode terdapat tanda seru karena tidak menginstal Xcode, namun tidak mempengaruhi praktikum.

---

## 2. Praktikum Aplikasi Profil (`main.dart`)

Berikut adalah kode dasar aplikasi profil awal di file `lib/main.dart`:

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Profil Mahasiswa')),
        body: const Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.school, size: 72),
            SizedBox(height: 16),
            Text('Ahmad Kevin Malik Zakaria', style: TextStyle(fontSize: 24)),
            SizedBox(height: 16),
            Text('Pemrograman Mobile — Minggu 1'),
          ]),
        ),
      ),
    );
  }
}
```

### Hasil Running `main.dart` (Awal)
Saat di-run di emulator, aplikasi menampilkan header "Profil Mahasiswa", ikon sekolah, nama saya, dan teks keterangan minggu ke-1.

![Hasil Running Awal main.dart](screenshots/Screenshot%202026-09-02%20at%2019.06.14.png)

---

## 3. Latihan Mandiri Dart (`latihan_mandiri.dart`)

Pada tugas latihan mandiri, membuat program Dart sederhana di file `lib/latihan_mandiri.dart` untuk mempelajari perhitungan variabel dasar dan konsep Class/Object serta Null Safety.

### Kode Program:
```dart
void main() {
  int panjang = 10;
  int lebar = 20;
  int luas = panjang * lebar;

  print('Panjang : $panjang');
  print('Lebar : $lebar');
  print('Luas : $luas');

  Profile mahasiswa = Profile(nama: 'Ahmad kevin Malik Zakaria', nim: '244107020125', noTelp: "089601302560");
  String emailDitampilkan = mahasiswa.email ?? 'Email belum diisi';
  String noTelpDitampilkan = mahasiswa.noTelp ?? "No Telp belum diisi";
  print('''Nama: ${mahasiswa.nama}
Nim: ${mahasiswa.nim}
Email: $emailDitampilkan
No Telp: $noTelpDitampilkan''');
}

class Profile {
  Profile({required this.nama, required this.nim, this.email, this.noTelp});
  final String nama;
  final String nim;
  final String? email;
  final String? noTelp;
}
```

### Hasil Running di Terminal:
Saya menjalankannya dengan perintah `dart run lib/latihan_mandiri.dart` di terminal:

![Hasil Running latihan_mandiri.dart](screenshots/Screenshot%202026-09-02%20at%2019.02.24.png)

---

## 4. Penjelasan Hot Reload vs Hot Restart

Selama mencoba Flutter, saya mempelajari dua fitur penting ini:

* **Hot Reload (`r`):**
  * Memperbarui tampilan UI secara langsung tanpa mereset ulang data/state aplikasi.
  * Prosesnya sangat cepat (< 1 detik).
  * Cocok digunakan saat mengubah warna, teks, ukuran font, atau layout UI.

* **Hot Restart (`R`):**
  * Mengulang aplikasi dari awal (memanggil kembali fungsi `main()`) dan mereset semua data/state ke kondisi semula.
  * Lebih cepat dari menjalankan ulang aplikasi dari awal (cold restart).
  * Digunakan jika ada perubahan pada logika fungsi `main()`, `initState()`, atau struktur variabel global.

---

## 5. Mini Assignment (Tugas Tambahan Profil)

Pada tugas *mini assignment* ini, menambahkan informasi identitas seperti **NIM**, **Kelas**, dan **No. Absen** ke dalam aplikasi profil di `lib/main.dart`.

### Perubahan Kode (Diff):
```diff
             Icon(Icons.school, size: 72),
             SizedBox(height: 16),
             Text('Ahmad Kevin Malik Zakaria', style: TextStyle(fontSize: 24)),
+            SizedBox(height: 8),
+            Text('NIM: 244107020125', style: TextStyle(fontSize: 18)),
+            Text('Kelas: TI-3E | Absen: 5', style: TextStyle(fontSize: 18)),
+            SizedBox(height: 16),
             Text('Pemrograman Mobile — Minggu 1'),
```

### Penjelasan Perubahan:
1. Menambahkan widget `Text('NIM: 244107020125', ...)` untuk menampilkan NIM.
2. Menambahkan widget `Text('Kelas: TI-3E | Absen: 5', ...)` untuk menampilkan informasi kelas dan nomor absen.
3. Menambahkan `SizedBox` untuk memberi jarak spasi yang rapi antar teks.

### Hasil Running Tampilan Akhir:
Berikut adalah hasil tampilan di emulator setelah informasi NIM, Kelas, dan Absen berhasil ditambahkan:

![Hasil Running Mini Assignment main.dart](screenshots/Screenshot%202026-09-02%20at%2019.00.07.png)

## 6. Pertanyaan Refleksi

- Kapan native lebih tepat dipilih daripada cross-platform?

  Saat aplikasi membutuhkan performa maksimal (seperti game bergrafis tinggi), butuh akses mendalam ke hardware spesifik (sensor khusus, fitur kamera advanced), atau jika aplikasi dituntut untuk memiliki UI/UX yang 100% mengikuti standar asli bawaan iOS atau Android.

- Bagaimana perubahan state berhubungan dengan widget tree dan UI deklaratif?

  Dalam konsep UI deklaratif (seperti Flutter), tampilan antarmuka adalah cerminan langsung dari data (state). Saat nilai state berubah, sistem akan secara otomatis membangun ulang (rebuild) bagian widget tree yang terkait saja, sehingga UI selalu ter- update sesuai data terbaru tanpa perlu kita ubah secara manual.

- Mengapa commit kecil dengan pesan jelas bermanfaat?

    Bagi kerja tim, ini sangat memudahkan pelacakan sumber error (debugging) dan mempercepat proses code review. Sedangkan untuk portofolio, riwayat commit yang rapi menunjukkan bahwa kamu memiliki alur pikir yang terstruktur dan bekerja secara profesional.