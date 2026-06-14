import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:psic_app/pages/articoli_admin_page.dart';
import 'package:psic_app/main.dart';

Widget _wrap(Widget child) => MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => child),
        ],
      ),
    );

void main() {
  setUp(() {
    blogAuthService.isAdmin.value = false;
  });

  testWidgets('shows password form by default', (tester) async {
    await tester.pumpWidget(_wrap(const ArticoliAdminPage()));
    await tester.pumpAndSettle();
    expect(find.text('Accedi'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('wrong password shows snackbar', (tester) async {
    await tester.pumpWidget(_wrap(const ArticoliAdminPage()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'sbagliata');
    await tester.tap(find.text('Accedi'));
    await tester.pumpAndSettle();

    expect(find.text('Password errata'), findsOneWidget);
  });

  testWidgets('correct password reveals admin panel', (tester) async {
    await tester.pumpWidget(_wrap(const ArticoliAdminPage()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'admin123');
    await tester.tap(find.text('Accedi'));
    await tester.pumpAndSettle();

    expect(find.text('Pannello Admin — I miei articoli'), findsOneWidget);
  });
}
