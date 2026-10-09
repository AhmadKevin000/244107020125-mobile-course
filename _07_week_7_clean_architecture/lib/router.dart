import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // GoRouter hanya menjalankan ulang redirect saat Listenable berubah. Nilai
  // boolean tidak berubah saat false -> false, jadi pakai counter yang selalu
  // naik agar redirect tetap jalan ketika pembacaan token selesai.
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, _) {
    refresh.value++;
  });
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoute.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      if (auth.isLoading) return null;
      final loggedIn = auth.value ?? false;
      final goingLogin = state.matchedLocation == AppRoute.login;
      if (!loggedIn && !goingLogin) return AppRoute.login;
      if (loggedIn && goingLogin) return AppRoute.home;
      return null;
    },
    routes: [
      GoRoute(path: AppRoute.login, builder: (_, _) => const LoginPage()),
      GoRoute(path: AppRoute.home, builder: (_, _) => const HomePage()),
      GoRoute(
        path: AppRoute.announcementPattern,
        builder: (_, state) =>
            AnnouncementPage(id: state.pathParameters['id'] ?? ''),
      ),
    ],
  );
});
