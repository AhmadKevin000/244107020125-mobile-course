import 'package:flutter_test/flutter_test.dart';
import 'package:week02_declarative_ui/main.dart'; 

void main() {
  testWidgets('Test UI Dashboard Mahasiswa', (WidgetTester tester) async {
    await tester.pumpWidget(const DashboardApp());

    expect(find.text('Student Dashboard'), findsOneWidget);
    expect(find.text('Ahmad Kevin Malik Zakaria'), findsOneWidget);
    expect(find.text('Assignments'), findsOneWidget);
  });
}