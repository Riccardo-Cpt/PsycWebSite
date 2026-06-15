import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:psic_app/pages/servizi_page.dart';

void main() {
  testWidgets('shows all three therapy services', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, _) => const ServiziPage()),
    ]);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Terapia Individuale'), findsOneWidget);
    expect(find.text('Terapia di Coppia'), findsOneWidget);
    expect(find.text('Terapia Speciale'), findsOneWidget);
  });

  testWidgets('no per-card Contattami buttons', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, _) => const ServiziPage()),
    ]);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    // Only the single ExpansionTile header should have 'Contattami', not 3 buttons
    expect(find.text('Contattami'), findsOneWidget);
  });

  testWidgets('has Contattami button at bottom', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, _) => const ServiziPage()),
    ]);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ElevatedButton, 'Contattami'), findsOneWidget);
  });
}
