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
    reviewAuthService.isLoggedIn.value = false;
    reviewAuthService.currentUsername = null;
  });

  tearDown(() {
    reviewsService.overrideForTest = null;
    reviewAuthService.overrideLoginForTest = null;
    reviewAuthService.overrideRegisterForTest = null;
  });

  testWidgets('renders heading and submit button', (tester) async {
    await tester.pumpWidget(_wrap(const RecensioniPage()));
    await tester.pumpAndSettle();
    expect(find.text('Recensioni'), findsAtLeastNWidgets(1));
    expect(find.text('Lascia una recensione'), findsOneWidget);
  });

  testWidgets('tapping button when not logged in opens auth dialog',
      (tester) async {
    await tester.pumpWidget(_wrap(const RecensioniPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lascia una recensione'));
    await tester.pumpAndSettle();
    expect(find.text('Accedi'), findsAtLeastNWidgets(1));
  });

  testWidgets('shows empty state text when no reviews', (tester) async {
    await tester.pumpWidget(_wrap(const RecensioniPage()));
    await tester.pumpAndSettle();
    expect(find.text('Nessuna recensione ancora.'), findsOneWidget);
  });
}
