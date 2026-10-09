import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import 'api_client.dart';

/// Dio client aplikasi dengan interceptor refresh 401.
///
/// Wiring ini berada di lapisan infrastruktur (composition root) supaya
/// presentation tidak perlu mengimpor `package:dio` secara langsung. Saat
/// sesi tidak bisa dipulihkan, callback mengarahkan pengguna untuk logout.
final apiClientProvider = Provider<Dio>((ref) {
  return buildApiClient(
    ref.watch(sessionRepositoryProvider),
    ref.watch(authRepositoryProvider),
    onSessionExpired: () => ref.read(authStateProvider.notifier).logout(),
  );
});
