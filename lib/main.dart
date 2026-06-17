import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/home_page.dart';
import 'pages/servizi_page.dart';
import 'pages/articoli_page.dart';
import 'pages/articoli_admin_page.dart';
import 'pages/chi_sono_page.dart';
import 'pages/recensioni_page.dart';
import 'widgets/nav_bar.dart';
import 'services/articoli_service.dart';
import 'services/storage_service.dart';
import 'services/blog_auth_service.dart';
import 'services/review_auth_service.dart';
import 'services/reviews_service.dart';

final articoliService = ArticoliService();
final storageService = StorageService();
final blogAuthService = BlogAuthService();
final reviewAuthService = ReviewAuthService();
final reviewsService = ReviewsService();

final _router = GoRouter(
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
  ],
);

void main() {
  runApp(const PsicApp());
}

class PsicApp extends StatelessWidget {
  const PsicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Dr.ssa Maria Bianchi — Psicologa',
      routerConfig: _router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B7A1D)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
