import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../routes.dart';

const topicAnnouncements = 'pengumuman-kampus';

// Id channel harus sama dengan yang dirujuk AndroidManifest
// (com.google.firebase.messaging.default_notification_channel_id).
const _channelId = 'pengumuman';
const _channelName = 'Pengumuman Kampus';

final _local = FlutterLocalNotificationsPlugin();

/// Handler background wajib top-level dan berjalan di isolate terpisah, jadi
/// jangan akses BuildContext, Riverpod, atau state UI di sini. Navigasi
/// dilakukan saat pengguna mengetuk notifikasi.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

/// Route dari ketukan notifikasi yang terjadi sebelum router terpasang (mis.
/// dari state terminated), ditahan sampai attachRouter dipanggil.
String? _pendingRoute;
void Function(String route)? _onRoute;

void attachRouter(void Function(String route) onRoute) {
  _onRoute = onRoute;
  final pending = _pendingRoute;
  _pendingRoute = null;
  if (pending != null) onRoute(pending);
}

void _navigate(String route) {
  final handler = _onRoute;
  if (handler == null) {
    _pendingRoute = route;
  } else {
    handler(route);
  }
}

Future<bool> requestNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: false,
    carPlay: false,
    criticalAlert: false,
  );
  return settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;
}

Future<void> initLocalNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  await _local.initialize(
    settings: const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: (response) {
      // Ketukan banner foreground -> teruskan payload ke router.
      _navigate(response.payload ?? AppRoute.home);
    },
  );

  // Channel harus sudah ada sebelum notifikasi background dari FCM tiba.
  // Importance channel bersifat immutable setelah dibuat, jadi dibuat sekali
  // di sini dengan Importance.high agar banner heads-up muncul.
  await _local
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: 'Notifikasi pengumuman kampus',
          importance: Importance.high,
        ),
      );
}

/// Mengambil token saat ini, menyerahkannya ke [onToken], lalu memantau
/// perubahan token dan mendaftarkan perangkat ke topik pengumuman.
///
/// Listener onTokenRefresh wajib ada: token berubah setelah reinstall, clear
/// data, atau rotasi keamanan. Tanpa itu backend menyimpan token basi dan
/// push berhenti sampai tanpa error.
Future<void> initFcmToken({
  required Future<void> Function(String token) onToken,
}) async {
  try {
    // getToken bisa menggantung kalau layanan Firebase Installations tidak
    // terjangkau, jadi dibatasi timeout agar listener di bawah tetap terpasang.
    final token = await FirebaseMessaging.instance
        .getToken()
        .timeout(const Duration(seconds: 10));
    if (token != null) await onToken(token);
  } catch (_) {
    // Lewati token saat ini; onTokenRefresh di bawah akan menangkap token
    // begitu layanan kembali tersedia.
  }

  FirebaseMessaging.instance.onTokenRefresh.listen(onToken);

  await FirebaseMessaging.instance.subscribeToTopic(topicAnnouncements);
}

/// Foreground: sistem tidak menampilkan banner otomatis, jadi tampilkan
/// manual lewat local notification.
void listenForeground() {
  FirebaseMessaging.onMessage.listen((message) async {
    await _local.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'Pengumuman',
      body: message.notification?.body ?? '',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Notifikasi pengumuman kampus',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: routeFromMessage(message.data),
    );
  });
}

/// Background lalu notifikasi diketuk.
void listenOpened() {
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    _navigate(routeFromMessage(message.data));
  });
}

/// Terminated lalu aplikasi dibuka dari notifikasi.
Future<void> handleTerminated() async {
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) {
    _navigate(routeFromMessage(initial.data));
  }
}

Future<void> subscribeTopic(String topic) =>
    FirebaseMessaging.instance.subscribeToTopic(topic);

Future<void> unsubscribeTopic(String topic) =>
    FirebaseMessaging.instance.unsubscribeFromTopic(topic);
