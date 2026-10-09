import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'infrastructure/messaging/push_provider.dart';
import 'infrastructure/messaging/push_service.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Harus terdaftar sebelum runApp supaya pesan saat app tidak aktif tertangani.
  registerBackgroundHandler();

  final container = ProviderContainer();
  final router = container.read(routerProvider);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );

  // Deep link dari notifikasi butuh router yang sudah terpasang, jadi dipasang
  // setelah frame pertama; handleTerminated mengambil pesan pembuka aplikasi.
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    attachRouter(router.go);
    listenOpened();
    await handleTerminated();
  });

  // FCM diinisialisasi setelah UI tampil supaya jaringan yang lambat atau
  // layanan Firebase yang tidak terjangkau tidak memblokir startup.
  unawaited(_initPush(container));
}

Future<void> _initPush(ProviderContainer container) async {
  try {
    await requestNotificationPermission();
    await initLocalNotifications();
    listenForeground();
    await initFcmToken(
      onToken: (token) async {
        container.read(fcmTokenProvider.notifier).setToken(token);
        // Endpoint backend kampus: POST /devices
        //   { "fcm_token": token, "platform": "android" }
      },
    );
  } catch (_) {
    // FCM tidak tersedia; aplikasi tetap berjalan tanpa notifikasi.
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Campus Notify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
