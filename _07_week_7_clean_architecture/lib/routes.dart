/// Konstanta path rute aplikasi.
///
/// Dipakai bersama oleh router, guard, halaman, dan handler notifikasi supaya
/// tidak ada literal string '/pengumuman' yang tersebar dan gampang salah
/// ketik. File ini sengaja tanpa dependensi Flutter agar logika rute murni
/// bisa diuji tanpa widget test.
abstract final class AppRoute {
  static const login = '/login';
  static const home = '/';
  static const announcementPrefix = '/pengumuman';
  static const announcementPattern = '/pengumuman/:id';

  static String announcementOf(Object id) => '$announcementPrefix/$id';
}

/// Rute tujuan dari `data` sebuah pesan FCM.
///
/// Fungsi murni supaya bisa diuji langsung: handler hanya menyerahkan
/// `RemoteMessage.data`. Urutan prioritasnya:
/// 1. `route` eksplisit dari backend (dipakai codelab),
/// 2. `id` pengumuman bila `route` tidak ada,
/// 3. Home sebagai jaring terakhir.
String routeFromMessage(Map<String, dynamic> data) {
  final route = data['route'];
  if (route is String && route.startsWith('/')) return route;

  final id = data['id'];
  if (id != null && '$id'.isNotEmpty) return AppRoute.announcementOf(id);

  return AppRoute.home;
}
