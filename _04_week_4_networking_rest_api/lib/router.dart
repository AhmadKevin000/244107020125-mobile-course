import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'pages/paged_post_page.dart';
import 'pages/post_detail_page.dart';
import 'pages/post_list_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/posts',
    routes: [
      GoRoute(
        path: '/posts',
        builder: (context, state) => const PostListPage(),
      ),
      GoRoute(
        path: '/posts-paged',
        builder: (context, state) => const PagedPostPage(),
      ),
      GoRoute(
        path: '/post/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const Scaffold(
              body: Center(child: Text('ID post tidak valid.')),
            );
          }
          return PostDetailPage(postId: id);
        },
      ),
    ],
  );
});
