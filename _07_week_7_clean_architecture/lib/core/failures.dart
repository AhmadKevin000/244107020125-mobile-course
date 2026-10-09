/// Kegagalan yang ramah pengguna dan aman ditampilkan ke UI.
///
/// Semua error dari layer data diterjemahkan menjadi [Failure] sebelum
/// mencapai presentation, sehingga UI tidak pernah melihat exception mentah
/// (DioException, PlatformException, dan sejenisnya). Ini murni Dart: tidak ada
/// import Flutter, Dio, SQLite, atau Firebase.
sealed class Failure {
  const Failure(this.message);

  /// Pesan yang aman ditampilkan ke pengguna.
  final String message;
}

/// Kegagalan pada sumber data lokal (secure storage, cache, database).
class LocalFailure extends Failure {
  const LocalFailure(super.message);
}

/// Kegagalan yang berasal dari jaringan atau server.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Kegagalan autentikasi (kredensial salah, sesi tidak valid).
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
