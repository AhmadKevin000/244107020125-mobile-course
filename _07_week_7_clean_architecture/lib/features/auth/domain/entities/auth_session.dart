/// Pasangan token yang dikeluarkan backend auth.
///
/// Entity bisnis murni: tanpa import Flutter dan tanpa mapping.
class AuthSession {
  const AuthSession({required this.access, required this.refresh});

  final String access;
  final String refresh;
}
