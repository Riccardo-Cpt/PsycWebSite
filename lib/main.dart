import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'dart:js_interop';
import 'pages/home_page.dart';
import 'pages/servizi_page.dart';
import 'pages/articoli_page.dart';
import 'pages/articoli_admin_page.dart';
import 'pages/approccio_terapeutico_page.dart';
import 'pages/psicoterapia_page.dart';
import 'pages/figure_professionali_page.dart';
import 'pages/disturbi_page.dart';
import 'pages/privacy_page.dart';
import 'pages/faq_page.dart';
import 'pages/chi_sono_page.dart';
import 'pages/recensioni_page.dart';
import 'widgets/nav_bar.dart';
import 'services/articoli_service.dart';
import 'services/storage_service.dart';
import 'services/blog_auth_service.dart';
import 'services/review_auth_service.dart';
import 'services/reviews_service.dart';
import 'services/contact_service.dart';

const _siteName = 'Dott. Antonella Petrini — Psicologa e Psicoterapeuta';

const _pageTitles = {
  '/': 'Psicologa e Psicoterapeuta a Firenze | $_siteName',
  '/servizi': 'Servizi di psicoterapia | $_siteName',
  '/chi-sono': 'Chi sono | $_siteName',
  '/approccio-terapeutico': 'Approccio terapeutico | $_siteName',
  '/psicoterapia': 'Psicoterapia | $_siteName',
  '/disturbi': 'Disturbi trattati | $_siteName',
  '/figure-professionali': 'Psicologo, psicoterapeuta e psichiatra | $_siteName',
  '/faq': 'Domande frequenti | $_siteName',
  '/articoli': 'Articoli | $_siteName',
  '/recensioni': 'Recensioni | $_siteName',
  '/privacy': 'Privacy e consenso informato | $_siteName',
};

@JS('document.title')
external set _documentTitle(String value);

final articoliService = ArticoliService();
final storageService = StorageService();
final blogAuthService = BlogAuthService();
final reviewAuthService = ReviewAuthService();
final reviewsService = ReviewsService();
final contactService = ContactService();

final _router = GoRouter(
  observers: [_TitleObserver()],
  errorBuilder: (context, state) => Scaffold(
    appBar: NavBar(onToggleDrawer: () {}),
    body: const Center(
      child: Text('Pagina non trovata', style: TextStyle(fontSize: 24)),
    ),
  ),
  routes: [
    GoRoute(path: '/', builder: (_, _) => const HomePage()),
    GoRoute(path: '/servizi', builder: (_, _) => const ServiziPage()),
    GoRoute(path: '/articoli', builder: (_, _) => const ArticoliPage()),
    GoRoute(
      path: '/recensioni',
      builder: (_, state) {
        final token = state.uri.queryParameters['token'];
        if (token != null && token.isNotEmpty) {
          reviewAuthService.verifyToken(token).catchError((_) {});
        }
        return const RecensioniPage();
      },
    ),
    GoRoute(path: '/admin', builder: (_, _) => const ArticoliAdminPage()),
    GoRoute(path: '/chi-sono', builder: (_, _) => const ChiSonoPage()),
    GoRoute(path: '/approccio-terapeutico', builder: (_, _) => const ApproccioTerapeuticoPage()),
    GoRoute(path: '/psicoterapia', builder: (_, _) => const PsicoterapiaPage()),
    GoRoute(path: '/disturbi', builder: (_, _) => const DisturbPage()),
    GoRoute(path: '/figure-professionali', builder: (_, _) => const FigureProfessionaliPage()),
    GoRoute(path: '/privacy', builder: (_, _) => const PrivacyPage()),
    GoRoute(path: '/faq', builder: (_, _) => const FaqPage()),
  ],
);

void main() {
  usePathUrlStrategy();
  runApp(const PsicApp());
}

class _TitleObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) => _update(route);

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) => _update(newRoute);

  void _update(Route? route) {
    final path = route?.settings.name ?? '/';
    _documentTitle = _pageTitles[path] ?? _siteName;
  }
}

class PsicApp extends StatelessWidget {
  const PsicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Dott Antonella Petrini — Psicologa e Psicoterapeuta',
      routerConfig: _router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF93a996)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
