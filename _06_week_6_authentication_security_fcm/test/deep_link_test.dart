import 'package:flutter_test/flutter_test.dart';

import 'package:_06_week_6_authentication_security_fcm/routes.dart';

void main() {
  group('routeFromMessage', () {
    test('memakai route eksplisit dari data notifikasi', () {
      expect(
        routeFromMessage({'route': '/pengumuman/3', 'id': '3'}),
        '/pengumuman/3',
      );
    });

    test('membangun route pengumuman dari id bila route tidak dikirim', () {
      expect(routeFromMessage({'id': '2'}), '/pengumuman/2');
    });

    test('kembali ke home saat data kosong', () {
      expect(routeFromMessage({}), AppRoute.home);
    });

    test('mengabaikan route yang tidak valid', () {
      expect(routeFromMessage({'route': 'pengumuman/3'}), AppRoute.home);
      expect(routeFromMessage({'route': 42}), AppRoute.home);
      expect(routeFromMessage({'route': ''}), AppRoute.home);
    });

    test('id dipakai saat route ada tapi tidak valid', () {
      expect(routeFromMessage({'route': 'bukan-path', 'id': 7}), '/pengumuman/7');
    });
  });

  group('AppRoute', () {
    test('announcementOf menyusun path detail', () {
      expect(AppRoute.announcementOf('1'), '/pengumuman/1');
      expect(AppRoute.announcementOf(12), '/pengumuman/12');
    });
  });
}
