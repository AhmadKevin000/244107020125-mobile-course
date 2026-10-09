import 'package:flutter_test/flutter_test.dart';

import 'package:_07_week_7_clean_architecture/core/failures.dart';
import 'package:_07_week_7_clean_architecture/features/announcements/domain/entities/announcement.dart';
import 'package:_07_week_7_clean_architecture/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:_07_week_7_clean_architecture/features/announcements/domain/usecases/get_announcements.dart';

/// Repository palsu: domain diuji murni tanpa jaringan atau database.
class FakeAnnouncementRepository implements AnnouncementRepository {
  FakeAnnouncementRepository({this.items = const [], this.fail = false});

  final List<Announcement> items;
  final bool fail;

  @override
  Future<({List<Announcement> announcements, Failure? failure})>
      fetchAnnouncements() async {
    if (fail) {
      return (
        announcements: const <Announcement>[],
        failure: const LocalFailure('db locked (simulasi)'),
      );
    }
    return (announcements: items, failure: null);
  }

  @override
  Future<({Announcement? announcement, Failure? failure})> fetchById(
    String id,
  ) {
    throw UnimplementedError();
  }
}

void main() {
  test('GetAnnouncements meneruskan daftar dari repository', () async {
    final repo = FakeAnnouncementRepository(
      items: [
        const Announcement(id: '1', title: 'A', body: ''),
      ],
    );

    final result = await GetAnnouncements(repo).call();

    expect(result.failure, isNull);
    expect(result.announcements.length, 1);
    expect(result.announcements.first.title, 'A');
  });

  test('GetAnnouncements meneruskan failure tanpa melempar', () async {
    final repo = FakeAnnouncementRepository(fail: true);

    final result = await GetAnnouncements(repo).call();

    expect(result.failure, isA<LocalFailure>());
    expect(result.announcements, isEmpty);
  });
}
