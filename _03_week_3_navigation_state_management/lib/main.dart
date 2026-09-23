import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'pages/detail_page.dart';
import 'pages/home_page.dart';
import 'pages/stats_page.dart';
import 'pages/todo_page.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          _ShellScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const TodoPage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/stats',
            builder: (context, state) => const StatsPage(),
          ),
        ]),
      ],
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'detail/:id',
          builder: (context, state) => DetailPage(
            id: state.pathParameters['id']!,
          ),
        ),
      ],
    ),
  ],
);

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.checklist),
            label: 'ToDo',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Week 3 - ToDo',
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        routerConfig: _router,
      );
}
