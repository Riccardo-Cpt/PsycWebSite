import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:psic_app/pages/articoli_page.dart';

Widget _wrap(Widget child) => MaterialApp.router(
      routerConfig: GoRouter(
        routes: [GoRoute(path: '/', builder: (_, _) => child)],
      ),
    );

void main() {
  testWidgets('renders without error and shows heading', (tester) async {
    await tester.pumpWidget(_wrap(const ArticoliPage()));
    await tester.pumpAndSettle();
    expect(find.text('I miei articoli'), findsAtLeastNWidgets(1));
  });

  testWidgets('shows nav menu burger and article index icon', (tester) async {
    await tester.pumpWidget(_wrap(const ArticoliPage()));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.byIcon(Icons.list), findsOneWidget);
  });

  testWidgets('tapping article index icon opens article index drawer',
      (tester) async {
    await tester.pumpWidget(_wrap(const ArticoliPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.list));
    await tester.pumpAndSettle();
    expect(find.text('Indice articoli'), findsOneWidget);
  });
}
