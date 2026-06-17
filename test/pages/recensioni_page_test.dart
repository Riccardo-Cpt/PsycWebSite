import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:psic_app/pages/recensioni_page.dart';
import 'package:psic_app/main.dart';

Widget _wrap(Widget child) => MaterialApp.router(
      routerConfig: GoRouter(
        routes: [GoRoute(path: '/', builder: (_, _) => child)],
      ),
    );

void main() {
  setUp(() {
    reviewsService.overrideForTest = Future.value([]);
    reviewAuthService.isVerified.value = false;
    reviewAuthService.currentEmail = null;
    reviewAuthService.currentUsername = null;
  });

  tearDown(() {
    reviewsService.overrideForTest = null;
    reviewAuthService.overrideSendMagicLinkForTest = null;
    reviewAuthService.overrideVerifyTokenForTest = null;
  });

  testWidgets('renders heading', (tester) async {
    await tester.pumpWidget(_wrap(const RecensioniPage()));
    await tester.pumpAndSettle();
    expect(find.text('Recensioni'), findsAtLeastNWidgets(1));
  });

  testWidgets('shows identity form when not verified', (tester) async {
    await tester.pumpWidget(_wrap(const RecensioniPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lascia una recensione'));
    await tester.pumpAndSettle();
    expect(find.text('Email *'), findsOneWidget);
    expect(find.text('Username *'), findsOneWidget);
    expect(find.text('Nome *'), findsOneWidget);
    expect(find.text('Cognome *'), findsOneWidget);
  });

  testWidgets('shows review form when verified', (tester) async {
    reviewAuthService.isVerified.value = true;
    reviewAuthService.currentEmail = 'a@b.com';
    reviewAuthService.currentUsername = 'user1';
    await tester.pumpWidget(_wrap(const RecensioniPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lascia una recensione'));
    await tester.pumpAndSettle();
    expect(find.text('Titolo *'), findsOneWidget);
    expect(find.text('Descrizione *'), findsOneWidget);
  });

  testWidgets('shows empty state text when no reviews', (tester) async {
    await tester.pumpWidget(_wrap(const RecensioniPage()));
    await tester.pumpAndSettle();
    expect(find.text('Nessuna recensione ancora.'), findsOneWidget);
  });
}
