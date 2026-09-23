import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:_03_week_3_navigation_state_management/main.dart';

void main() {
  testWidgets('menambah tugas baru', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    expect(find.text('Belum ada tugas'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Kerjakan PR minggu 3');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    expect(find.text('Kerjakan PR minggu 3'), findsOneWidget);
  });

  testWidgets('NavigationBar berpindah ke tab Stats dan kembali',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    expect(find.text('ToDo'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);

    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(find.text('Statistik'), findsOneWidget);

    await tester.tap(find.text('ToDo'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada tugas'), findsOneWidget);
  });

  testWidgets('counter belum selesai berkurang saat tugas dicentang',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Tugas uji filter');
    await tester.tap(find.text('Tambah'));
    await tester.pump();

    expect(find.text('Belum selesai: 1 dari 1'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(find.text('Belum selesai: 0 dari 1'), findsOneWidget);
  });
}
