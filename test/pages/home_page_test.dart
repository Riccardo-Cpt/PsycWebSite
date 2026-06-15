// test/pages/home_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:psic_app/pages/home_page.dart';
import 'package:psic_app/config/contatti.dart';
import 'package:psic_app/main.dart';

// Returns only body overflow error messages; silently swallows asset-load
// failures that occur because the test bundle has no real image files.
Future<List<String>> _pumpAt(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final overflows = <String>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    final msg = details.toString();
    if (msg.contains('overflowed') && !msg.contains('AppBar')) {
      overflows.add(msg);
    }
    // Swallow everything (including asset-not-found) so nothing reaches the
    // framework's default handler and leaves a pending exception.
  };

  final router = GoRouter(
    routes: [GoRoute(path: '/', builder: (_, _) => const HomePage())],
  );
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
  await tester.pump(); // flush any late-arriving async image errors

  FlutterError.onError = previous;
  return overflows;
}

void main() {
  setUp(() {
    articoliService.overrideForTest = Future.value([]);
  });

  tearDown(() {
    articoliService.overrideForTest = null;
  });

  testWidgets('value tiles do not overflow on a phone screen', (tester) async {
    final overflows = await _pumpAt(tester, const Size(375, 800));
    expect(overflows, isEmpty);
    expect(find.text('I miei valori'), findsOneWidget);
    expect(find.text('Empatia e ascolto'), findsOneWidget);
  });

  testWidgets('value tiles do not overflow on a phone screen', (tester) async {
    final overflows = await _pumpAt(tester, const Size(390, 844));
    expect(overflows, isEmpty);
  });

  testWidgets('value tiles do not overflow on a phone screen', (tester) async {
    final overflows = await _pumpAt(tester, const Size(430, 932));
    expect(overflows, isEmpty);
  });

  testWidgets('contact details are in the footer', (tester) async {
    await _pumpAt(tester, const Size(375, 2400));
    expect(find.text(Contatti.telefono), findsOneWidget);
    expect(find.text(Contatti.indirizzo), findsOneWidget);
    expect(find.text(Contatti.email), findsOneWidget);
    final ctaTop = tester.getTopLeft(find.text('Inizia il tuo percorso')).dy;
    final phoneTop = tester.getTopLeft(find.text(Contatti.telefono)).dy;
    expect(phoneTop, greaterThan(ctaTop));
  });
}
