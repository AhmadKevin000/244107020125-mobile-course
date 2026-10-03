import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Registration token FCM terakhir dari getToken atau onTokenRefresh.
/// Halaman Debug menampilkannya terpotong untuk bukti token lifecycle.
final fcmTokenProvider =
    NotifierProvider<FcmTokenNotifier, String?>(FcmTokenNotifier.new);

class FcmTokenNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setToken(String token) => state = token;
}
