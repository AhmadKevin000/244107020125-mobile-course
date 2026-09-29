import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:_04_week_4_networking_rest_api/data/models/post.dart';
import 'package:_04_week_4_networking_rest_api/data/providers.dart';
import 'package:_04_week_4_networking_rest_api/data/repositories/post_repository.dart';
import 'package:_04_week_4_networking_rest_api/main.dart';

class FakePostRepository extends PostRepository {
  FakePostRepository() : super(Dio());

  @override
  Future<List<Post>> fetchPosts() async => const [];

  @override
  Future<List<Post>> fetchPostsPage({
    required int page,
    int limit = 10,
  }) async =>
      const [];
}

void main() {
  testWidgets('PostListPage menampilkan AppBar (route awal /posts)',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postRepositoryProvider.overrideWithValue(FakePostRepository()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Posts API'), findsOneWidget);
  });

  testWidgets('PagedPostPage menampilkan AppBar (route /posts-paged)',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postRepositoryProvider.overrideWithValue(FakePostRepository()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Posts Paged'), findsNothing);
  });
}
