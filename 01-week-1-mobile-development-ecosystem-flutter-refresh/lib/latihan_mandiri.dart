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