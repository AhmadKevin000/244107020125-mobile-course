/// Model representasi data Comment dari JSONPlaceholder API.
class Comment {
  /// Konstruktor konstan untuk membuat objek [Comment].
  const Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  /// ID dari postingan pemilik komentar ini.
  final int postId;

  /// ID unik komentar.
  final int id;

  /// Nama pengirim komentar atau judul komentar.
  final String name;

  /// Alamat email pengirim komentar.
  final String email;

  /// Isi konten teks komentar.
  final String body;

  /// Factory constructor untuk mem-parsing JSON menjadi objek [Comment] secara aman dari null.
  /// 
  /// Jika field bernilai `null` atau tidak ditemukan dalam payload JSON, 
  /// maka nilai fallback default yang aman (0 untuk num/int, '' untuk String) akan digunakan.
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      // Mengonversi postId ke int secara aman, default ke 0 jika null atau tidak ada
      postId: (json['postId'] as num?)?.toInt() ?? 0,
      // Mengonversi id ke int secara aman, default ke 0 jika null atau tidak ada
      id: (json['id'] as num?)?.toInt() ?? 0,
      // Mengambil name sebagai String, default ke string kosong jika null atau tidak ada
      name: json['name'] as String? ?? '',
      // Mengambil email sebagai String, default ke string kosong jika null atau tidak ada
      email: json['email'] as String? ?? '',
      // Mengambil body sebagai String, default ke string kosong jika null atau tidak ada
      body: json['body'] as String? ?? '',
    );
  }

  /// Mengonversi objek [Comment] kembali menjadi format JSON Map.
  Map<String, dynamic> toJson() => {
        'postId': postId,
        'id': id,
        'name': name,
        'email': email,
        'body': body,
      };
}
