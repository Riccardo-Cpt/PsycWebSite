# Drift → Supabase Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the local Drift/SQLite database with Supabase REST API for article storage and Supabase Storage bucket for images, while keeping the existing UI and admin password gate intact.

**Architecture:** Thin HTTP service layer using the `http` package — `ArticoliService` wraps REST calls to `/rest/v1/articoli`, `StorageService` wraps the storage bucket API. Pages switch from `StreamBuilder` to `FutureBuilder` with `setState`-triggered refreshes. All Drift code is removed.

**Tech Stack:** Flutter web, `http ^1.2.0`, `intl ^0.20.0`, Supabase REST API v1, Supabase Storage v1.

---

## File Map

| Action | Path | Responsibility |
|---|---|---|
| Create branch | `feature/supabase-migration` | Isolation |
| Create | `lib/models/articolo.dart` | Plain Dart model replacing `ArticoliData` |
| Create | `lib/services/articoli_service.dart` | REST CRUD for `articoli` table |
| Create | `lib/services/storage_service.dart` | Image upload/delete in storage bucket |
| Modify | `lib/config/admin_config.dart` | Add all Supabase config constants |
| Modify | `lib/main.dart` | Swap `AppDatabase` for service globals |
| Modify | `lib/pages/articoli_page.dart` | `FutureBuilder` + `Articolo` model |
| Modify | `lib/pages/articoli_admin_page.dart` | `FutureBuilder` + service calls + image URL flow |
| Modify | `pubspec.yaml` | Remove Drift deps, add `http` + `intl` |
| Modify | `test/pages/articoli_page_test.dart` | Remove Drift dependency, stub service |
| Modify | `test/pages/articoli_admin_page_test.dart` | Remove Drift dependency |
| Delete | `lib/database/app_database.dart` | Drift database definition |
| Delete | `lib/database/app_database.g.dart` | Generated Drift code |
| Delete | `lib/database/articoli_dao.dart` | Drift DAO |
| Delete | `lib/database/articoli_dao.g.dart` | Generated Drift DAO |
| Delete | `web/sqlite3.wasm` | SQLite WASM binary (no longer needed) |
| Delete | `web/drift_worker.js` | Drift web worker (no longer needed) |
| Delete | `web/drift_worker.js.deps` | |
| Delete | `web/drift_worker.js.map` | |

---

## Task 1: Create branch and update pubspec.yaml

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Create the feature branch**

```bash
git checkout -b feature/supabase-migration
```

- [ ] **Step 2: Remove Drift deps and add http + intl in pubspec.yaml**

Open `pubspec.yaml`. Replace the dependencies and dev_dependencies sections so they read:

```yaml
dependencies:
  flutter:
    sdk: flutter
  go_router: ^17.3.0
  url_launcher: ^6.3.0
  cupertino_icons: ^1.0.8
  image_picker: ^1.1.0
  http: ^1.2.0
  intl: ^0.20.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

(Remove `drift`, `drift_flutter`, `sqlite3_flutter_libs`, `build_runner`, `drift_dev`.)

- [ ] **Step 3: Get packages**

```bash
flutter pub get
```

Expected: resolves without errors, no Drift packages in output.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: swap Drift deps for http + intl"
```

---

## Task 2: Add Supabase config to AdminConfig

**Files:**
- Modify: `lib/config/admin_config.dart`

- [ ] **Step 1: Replace the file contents**

```dart
class AdminConfig {
  static const String password = 'admin123';
  static const String supabaseUrl = 'https://snsvamcecgizhecvtpwk.supabase.co';
  static const String supabaseAnonKey =
      'F6092D47-06DF-4FEF-86CB-10312D4B87CC';
  static const String supabaseServiceRoleKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNuc3ZhbWNlY2dpemhlY3Z0cHdrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MTUxMTg4MywiZXhwIjoyMDk3MDg3ODgzfQ.EVH2iQBi3Aox6rdWgs3B1jFmg0CZ2j829DgbAV3_b-I';
  static const String supabaseRestUrl = '$supabaseUrl/rest/v1';
  static const String supabaseStorageUrl = '$supabaseUrl/storage/v1';
  static const String articoliBucket = 'articoli-images';
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/config/admin_config.dart
git commit -m "feat: add Supabase config constants to AdminConfig"
```

---

## Task 3: Create Articolo model

**Files:**
- Create: `lib/models/articolo.dart`
- Create: `test/models/articolo_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/models/articolo_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:psic_app/models/articolo.dart';

void main() {
  group('Articolo.fromJson', () {
    test('parses all fields', () {
      final json = {
        'id': 1,
        'titolo': 'Test',
        'corpo': 'Corpo',
        'pubblicato_at': '2024-03-15T10:30:00+00:00',
        'immagine_url': 'https://example.com/img.jpg',
      };
      final a = Articolo.fromJson(json);
      expect(a.id, 1);
      expect(a.titolo, 'Test');
      expect(a.corpo, 'Corpo');
      expect(a.pubblicatoAt, DateTime.parse('2024-03-15T10:30:00+00:00'));
      expect(a.immagineUrl, 'https://example.com/img.jpg');
    });

    test('handles null immagine_url', () {
      final json = {
        'id': 2,
        'titolo': 'No image',
        'corpo': 'Corpo',
        'pubblicato_at': '2024-03-15T10:30:00+00:00',
        'immagine_url': null,
      };
      final a = Articolo.fromJson(json);
      expect(a.immagineUrl, isNull);
    });

    test('handles null pubblicato_at', () {
      final json = {
        'id': 3,
        'titolo': 'No date',
        'corpo': 'Corpo',
        'pubblicato_at': null,
        'immagine_url': null,
      };
      final a = Articolo.fromJson(json);
      expect(a.pubblicatoAt, isNull);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/models/articolo_test.dart
```

Expected: FAIL — `Target of URI doesn't exist: 'package:psic_app/models/articolo.dart'`

- [ ] **Step 3: Create the model**

Create `lib/models/articolo.dart`:

```dart
class Articolo {
  final int id;
  final String titolo;
  final String corpo;
  final DateTime? pubblicatoAt;
  final String? immagineUrl;

  const Articolo({
    required this.id,
    required this.titolo,
    required this.corpo,
    this.pubblicatoAt,
    this.immagineUrl,
  });

  factory Articolo.fromJson(Map<String, dynamic> json) => Articolo(
        id: json['id'] as int,
        titolo: json['titolo'] as String,
        corpo: json['corpo'] as String,
        pubblicatoAt: json['pubblicato_at'] != null
            ? DateTime.parse(json['pubblicato_at'] as String)
            : null,
        immagineUrl: json['immagine_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'titolo': titolo,
        'corpo': corpo,
        'pubblicato_at': pubblicatoAt?.toIso8601String(),
        'immagine_url': immagineUrl,
      };
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/models/articolo_test.dart
```

Expected: All 3 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/models/articolo.dart test/models/articolo_test.dart
git commit -m "feat: add Articolo model with fromJson/toJson"
```

---

## Task 4: Create ArticoliService

**Files:**
- Create: `lib/services/articoli_service.dart`

No unit test for this service — it makes real HTTP calls and would require a mock HTTP client setup that adds complexity not warranted for a simple service wrapper. Integration is verified manually in Task 8.

- [ ] **Step 1: Create the service**

Create `lib/services/articoli_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/admin_config.dart';
import '../models/articolo.dart';

class ArticoliService {
  static const _headers = {
    'apikey': AdminConfig.supabaseAnonKey,
    'Authorization': 'Bearer ${AdminConfig.supabaseAnonKey}',
    'Content-Type': 'application/json',
  };

  static const _writeHeaders = {
    'apikey': AdminConfig.supabaseServiceRoleKey,
    'Authorization': 'Bearer ${AdminConfig.supabaseServiceRoleKey}',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation',
  };

  Future<List<Articolo>> tutti() async {
    final uri = Uri.parse(
        '${AdminConfig.supabaseRestUrl}/articoli?select=*&order=pubblicato_at.desc');
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Errore nel recupero degli articoli: ${response.body}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => Articolo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Articolo> inserisci({
    required String titolo,
    required String corpo,
    String? immagineUrl,
  }) async {
    final uri =
        Uri.parse('${AdminConfig.supabaseRestUrl}/articoli');
    final body = jsonEncode({
      'titolo': titolo,
      'corpo': corpo,
      'pubblicato_at': DateTime.now().toUtc().toIso8601String(),
      if (immagineUrl != null) 'immagine_url': immagineUrl,
    });
    final response = await http.post(uri, headers: _writeHeaders, body: body);
    if (response.statusCode != 201) {
      throw Exception('Errore nel salvataggio: ${response.body}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return Articolo.fromJson(list.first as Map<String, dynamic>);
  }

  Future<void> aggiorna({
    required int id,
    required String titolo,
    required String corpo,
    String? immagineUrl,
  }) async {
    final uri = Uri.parse(
        '${AdminConfig.supabaseRestUrl}/articoli?id=eq.$id');
    final body = jsonEncode({
      'titolo': titolo,
      'corpo': corpo,
      'immagine_url': immagineUrl,
    });
    final response =
        await http.patch(uri, headers: _writeHeaders, body: body);
    if (response.statusCode != 200) {
      throw Exception('Errore nella modifica: ${response.body}');
    }
  }

  Future<void> cancella(int id) async {
    final uri = Uri.parse(
        '${AdminConfig.supabaseRestUrl}/articoli?id=eq.$id');
    final response = await http.delete(uri, headers: _writeHeaders);
    if (response.statusCode != 204) {
      throw Exception('Errore nell\'eliminazione: ${response.body}');
    }
  }
}
```

- [ ] **Step 2: Verify it compiles**

```bash
flutter build web --no-pub 2>&1 | head -20
```

Expected: No errors referencing `articoli_service.dart`.

- [ ] **Step 3: Commit**

```bash
git add lib/services/articoli_service.dart
git commit -m "feat: add ArticoliService for Supabase REST CRUD"
```

---

## Task 5: Create StorageService

**Files:**
- Create: `lib/services/storage_service.dart`

- [ ] **Step 1: Create the service**

Create `lib/services/storage_service.dart`:

```dart
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/admin_config.dart';

class StorageService {
  static const _writeHeaders = {
    'apikey': AdminConfig.supabaseServiceRoleKey,
    'Authorization': 'Bearer ${AdminConfig.supabaseServiceRoleKey}',
  };

  String _publicUrl(String filename) =>
      '${AdminConfig.supabaseStorageUrl}/object/public/${AdminConfig.articoliBucket}/$filename';

  String? _filenameFromUrl(String url) {
    final prefix =
        '${AdminConfig.supabaseStorageUrl}/object/public/${AdminConfig.articoliBucket}/';
    if (!url.startsWith(prefix)) return null;
    return url.substring(prefix.length);
  }

  Future<String> uploadImmagine(Uint8List bytes, String mime) async {
    final filename =
        '${DateTime.now().millisecondsSinceEpoch}.${mime.split('/').last}';
    final uri = Uri.parse(
        '${AdminConfig.supabaseStorageUrl}/object/${AdminConfig.articoliBucket}/$filename');
    final response = await http.post(
      uri,
      headers: {
        ..._writeHeaders,
        'Content-Type': mime,
      },
      body: bytes,
    );
    if (response.statusCode != 200) {
      throw Exception('Errore nel caricamento immagine: ${response.body}');
    }
    return _publicUrl(filename);
  }

  Future<void> deleteImmagine(String url) async {
    final filename = _filenameFromUrl(url);
    if (filename == null) return;
    final uri = Uri.parse(
        '${AdminConfig.supabaseStorageUrl}/object/${AdminConfig.articoliBucket}/$filename');
    await http.delete(uri, headers: _writeHeaders);
  }
}
```

- [ ] **Step 2: Verify it compiles**

```bash
flutter build web --no-pub 2>&1 | head -20
```

Expected: No errors referencing `storage_service.dart`.

- [ ] **Step 3: Commit**

```bash
git add lib/services/storage_service.dart
git commit -m "feat: add StorageService for Supabase Storage bucket"
```

---

## Task 6: Update main.dart — swap globals

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Replace the file contents**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/home_page.dart';
import 'pages/servizi_page.dart';
import 'pages/articoli_page.dart';
import 'pages/articoli_admin_page.dart';
import 'widgets/nav_bar.dart';
import 'services/articoli_service.dart';
import 'services/storage_service.dart';
import 'services/blog_auth_service.dart';

final articoliService = ArticoliService();
final storageService = StorageService();
final blogAuthService = BlogAuthService();

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
    GoRoute(path: '/articoli/admin', builder: (_, _) => const ArticoliAdminPage()),
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E6370)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/main.dart
git commit -m "feat: swap AppDatabase global for ArticoliService + StorageService"
```

---

## Task 7: Rewrite ArticoliPage

**Files:**
- Modify: `lib/pages/articoli_page.dart`
- Modify: `test/pages/articoli_page_test.dart`

- [ ] **Step 1: Update the test**

The existing tests check UI structure (heading, menu icon, index icon) — they still apply, but `ArticoliPage` will now call `articoliService.tutti()` on load. Provide a `Future` that resolves to an empty list so the test doesn't make network calls. The test imports `main.dart` indirectly via the page, so we need to patch `articoliService`.

Replace `test/pages/articoli_page_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:psic_app/pages/articoli_page.dart';
import 'package:psic_app/models/articolo.dart';
import 'package:psic_app/main.dart';

Widget _wrap(Widget child) => MaterialApp.router(
      routerConfig: GoRouter(
        routes: [GoRoute(path: '/', builder: (_, _) => child)],
      ),
    );

void main() {
  setUp(() {
    articoliService.overrideForTest = Future.value([]);
  });

  tearDown(() {
    articoliService.overrideForTest = null;
  });

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
```

- [ ] **Step 2: Add `overrideForTest` to ArticoliService**

In `lib/services/articoli_service.dart`, add one field at the top of the class:

```dart
// ignore: avoid_public_members_for_test
Future<List<Articolo>>? overrideForTest;
```

And change the `tutti()` method to:

```dart
Future<List<Articolo>> tutti() async {
  if (overrideForTest != null) return overrideForTest!;
  final uri = Uri.parse(
      '${AdminConfig.supabaseRestUrl}/articoli?select=*&order=pubblicato_at.desc');
  final response = await http.get(uri, headers: _headers);
  if (response.statusCode != 200) {
    throw Exception('Errore nel recupero degli articoli: ${response.body}');
  }
  final list = jsonDecode(response.body) as List<dynamic>;
  return list
      .map((e) => Articolo.fromJson(e as Map<String, dynamic>))
      .toList();
}
```

- [ ] **Step 3: Run the test to verify it fails (page still uses Drift)**

```bash
flutter test test/pages/articoli_page_test.dart
```

Expected: FAIL — compilation errors because `articoli_page.dart` still imports Drift types.

- [ ] **Step 4: Rewrite ArticoliPage**

Replace `lib/pages/articoli_page.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/articolo.dart';
import '../widgets/nav_drawer.dart';

class ArticoliPage extends StatefulWidget {
  const ArticoliPage({super.key});

  @override
  State<ArticoliPage> createState() => _ArticoliPageState();
}

class _ArticoliPageState extends State<ArticoliPage>
    with SingleTickerProviderStateMixin {
  late Future<List<Articolo>> _futureArticoli;
  final _scrollController = ScrollController();
  final Map<int, GlobalKey> _articleKeys = {};
  double _scrollOffset = 0;
  late final AnimationController _navCtrl;
  late final Animation<Offset> _navSlide;

  @override
  void initState() {
    super.initState();
    _futureArticoli = articoliService.tutti();
    _scrollController.addListener(() {
      final offset = _scrollController.offset.clamp(0.0, 80.0);
      if ((offset - _scrollOffset).abs() > 0.5) {
        setState(() => _scrollOffset = offset);
      }
    });
    _navCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _navSlide = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _navCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _navCtrl.dispose();
    super.dispose();
  }

  void _toggleNav() {
    if (_navCtrl.isCompleted) {
      _navCtrl.reverse();
    } else {
      _navCtrl.forward();
    }
  }

  void _closeNav() => _navCtrl.reverse();

  void _showArticleIndex(List<Articolo> articoli) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        alignment: Alignment.topRight,
        insetPadding: const EdgeInsets.only(right: 8, top: kToolbarHeight + 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 8, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Indice articoli',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: articoli.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Nessun articolo',
                            style: TextStyle(color: Colors.black54)),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: articoli.length,
                        itemBuilder: (_, i) => ListTile(
                          title: Text(articoli[i].titolo),
                          subtitle: Text(
                            articoli[i].pubblicatoAt != null
                                ? DateFormat('yyyy-MM-dd')
                                    .format(articoli[i].pubblicatoAt!)
                                : '',
                          ),
                          onTap: () => _scrollToArticle(i, articoli),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToArticle(int index, List<Articolo> articoli) {
    if (index >= articoli.length) return;
    Navigator.pop(context);
    final id = articoli[index].id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _articleKeys[id]?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _navCtrl,
      builder: (context, _) {
        final t = (_scrollOffset / 80.0).clamp(0.0, 1.0);
        final appBarBg =
            Color.lerp(const Color(0xFFFAFAFA), const Color(0xFFEEEEEE), t)!;
        final navOpen = _navCtrl.value > 0.01;

        return FutureBuilder<List<Articolo>>(
          future: _futureArticoli,
          builder: (context, snapshot) {
            final articoli = snapshot.data ?? [];
            for (final a in articoli) {
              _articleKeys.putIfAbsent(a.id, () => GlobalKey());
            }
            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: appBarBg,
                foregroundColor: const Color(0xFF1E6370),
                elevation: t * 3.0,
                scrolledUnderElevation: 0,
                title: InkWell(
                  onTap: () => context.go('/'),
                  child: const Text(
                    'Dr.ssa Maria Bianchi',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E6370)),
                  ),
                ),
                actions: [
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Center(
                      child: Text(
                        'Naviga nel sito',
                        style: TextStyle(
                            color: Color(0xFF1E6370),
                            fontSize: 17,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        RotationTransition(
                          turns: animation,
                          child: FadeTransition(
                              opacity: animation, child: child),
                        ),
                    child: IconButton(
                      key: ValueKey(navOpen),
                      icon: Icon(navOpen ? Icons.close : Icons.menu),
                      tooltip: navOpen ? 'Chiudi menu' : 'Menu',
                      onPressed: _toggleNav,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              body: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'I miei articoli',
                                style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E6370)),
                              ),
                            ),
                            const Text(
                              'Naviga tra gli articoli',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E6370)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.list),
                              tooltip: 'Indice articoli',
                              onPressed: () => _showArticleIndex(articoli),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (snapshot.connectionState ==
                            ConnectionState.waiting)
                          const Center(child: CircularProgressIndicator())
                        else if (snapshot.hasError)
                          Center(
                              child: Text('Errore: ${snapshot.error}',
                                  style: const TextStyle(
                                      color: Colors.red)))
                        else if (articoli.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(48),
                              child: Text('Nessun articolo pubblicato.',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black54)),
                            ),
                          )
                        else
                          ...articoli.asMap().entries.map((entry) {
                            final i = entry.key;
                            final a = entry.value;
                            return Padding(
                              key: _articleKeys[a.id],
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _ArticoloCard(
                                articolo: a,
                                initiallyExpanded: i == 0,
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  if (navOpen)
                    GestureDetector(
                      onTap: _closeNav,
                      child: Container(
                        color: Colors.black
                            .withValues(alpha: 0.3 * _navCtrl.value),
                      ),
                    ),
                  Positioned(
                    top: 0,
                    right: 0,
                    bottom: 0,
                    child: SlideTransition(
                      position: _navSlide,
                      child: NavDrawer(onClose: _closeNav),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ArticoloCard extends StatefulWidget {
  final Articolo articolo;
  final bool initiallyExpanded;
  const _ArticoloCard(
      {required this.articolo, required this.initiallyExpanded});

  @override
  State<_ArticoloCard> createState() => _ArticoloCardState();
}

class _ArticoloCardState extends State<_ArticoloCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.articolo;
    return Card(
      elevation: 2,
      child: _expanded ? _buildExpanded(a) : _buildCollapsed(a),
    );
  }

  Widget _buildCollapsed(Articolo a) {
    return ListTile(
      leading: const Icon(Icons.expand_more, color: Color(0xFF1E6370)),
      title: Text(a.titolo,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        a.pubblicatoAt != null
            ? DateFormat('yyyy-MM-dd').format(a.pubblicatoAt!)
            : '',
      ),
      onTap: () => setState(() => _expanded = true),
    );
  }

  Widget _buildExpanded(Articolo a) {
    return InkWell(
      onTap: () => setState(() => _expanded = false),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;
            final imageWidget = a.immagineUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      a.immagineUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : null;

            final textContent = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.titolo,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  a.pubblicatoAt != null
                      ? DateFormat('yyyy-MM-dd').format(a.pubblicatoAt!)
                      : '',
                  style: const TextStyle(
                      color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Text(a.corpo,
                    style:
                        const TextStyle(fontSize: 16, height: 1.6)),
              ],
            );

            if (imageWidget == null) {
              return SizedBox(width: double.infinity, child: textContent);
            }

            if (!isWide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: imageWidget),
                  const SizedBox(height: 16),
                  textContent,
                ],
              );
            }

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 280, child: imageWidget),
                  const SizedBox(width: 20),
                  Expanded(child: textContent),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Run tests**

```bash
flutter test test/pages/articoli_page_test.dart
```

Expected: All 3 tests PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/pages/articoli_page.dart lib/services/articoli_service.dart test/pages/articoli_page_test.dart
git commit -m "feat: rewrite ArticoliPage to use FutureBuilder + ArticoliService"
```

---

## Task 8: Rewrite ArticoliAdminPage

**Files:**
- Modify: `lib/pages/articoli_admin_page.dart`
- Modify: `test/pages/articoli_admin_page_test.dart`

- [ ] **Step 1: Update the admin page test**

The existing tests check the password gate — they still apply and don't need network access. The admin panel list is behind auth so tests only verify the gate UI. Replace `test/pages/articoli_admin_page_test.dart`:

```dart
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
    articoliService.overrideForTest = Future.value([]);
  });

  tearDown(() {
    articoliService.overrideForTest = null;
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
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
flutter test test/pages/articoli_admin_page_test.dart
```

Expected: FAIL — compilation errors because the page still imports Drift types.

- [ ] **Step 3: Rewrite ArticoliAdminPage**

Replace `lib/pages/articoli_admin_page.dart` with:

```dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../widgets/nav_bar.dart';
import '../main.dart';
import '../models/articolo.dart';

class ArticoliAdminPage extends StatelessWidget {
  const ArticoliAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NavScaffold(
      body: ValueListenableBuilder<bool>(
        valueListenable: blogAuthService.isAdmin,
        builder: (context, isAdmin, _) =>
            isAdmin ? const _AdminPanel() : const _PasswordGate(),
      ),
    );
  }
}

// ── Password gate ─────────────────────────────────────────────────────────────

class _PasswordGate extends StatefulWidget {
  const _PasswordGate();

  @override
  State<_PasswordGate> createState() => _PasswordGateState();
}

class _PasswordGateState extends State<_PasswordGate> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _login() {
    blogAuthService.login(_controller.text);
    if (!blogAuthService.isAdmin.value && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password errata')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Accesso Admin',
                    style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                TextField(
                  controller: _controller,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Password'),
                  onSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E6370),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Accedi',
                      style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Admin panel ───────────────────────────────────────────────────────────────

class _AdminPanel extends StatefulWidget {
  const _AdminPanel();

  @override
  State<_AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<_AdminPanel> {
  late Future<List<Articolo>> _futureArticoli;

  @override
  void initState() {
    super.initState();
    _futureArticoli = articoliService.tutti();
  }

  void _refresh() {
    setState(() {
      _futureArticoli = articoliService.tutti();
    });
  }

  Future<void> _confirmDelete(BuildContext context, Articolo articolo) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Elimina articolo'),
        content: Text(
            'Eliminare "${articolo.titolo}"? L\'azione è irreversibile.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annulla')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Elimina',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      if (articolo.immagineUrl != null) {
        await storageService.deleteImmagine(articolo.immagineUrl!);
      }
      await articoliService.cancella(articolo.id);
      _refresh();
    }
  }

  void _openForm(BuildContext context, {Articolo? articolo}) {
    final isWide = MediaQuery.of(context).size.width >= 720;
    if (isWide) {
      Navigator.of(context)
          .push(MaterialPageRoute(
            builder: (_) => _ArticoloFormPage(
                articolo: articolo, onSaved: _refresh),
          ))
          .then((_) => _refresh());
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) =>
            _ArticoloFormSheet(articolo: articolo, onSaved: _refresh),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text('Pannello Admin — I miei articoli',
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton.icon(
                onPressed: () => _openForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Nuovo articolo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E6370),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Articolo>>(
              future: _futureArticoli,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Errore: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red)));
                }
                final articoli = snapshot.data ?? [];
                if (articoli.isEmpty) {
                  return const Center(
                      child: Text('Nessun articolo. Creane uno!',
                          style: TextStyle(color: Colors.black54)));
                }
                return ListView.separated(
                  itemCount: articoli.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final a = articoli[i];
                    return ListTile(
                      title: Text(a.titolo,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        a.pubblicatoAt != null
                            ? DateFormat('yyyy-MM-dd')
                                .format(a.pubblicatoAt!)
                            : '',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Color(0xFF1E6370)),
                            tooltip: 'Modifica',
                            onPressed: () =>
                                _openForm(context, articolo: a),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            tooltip: 'Elimina',
                            onPressed: () =>
                                _confirmDelete(context, a),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared form logic ──────────────────────────────────────────────────────────

class _ArticoloForm extends StatefulWidget {
  final Articolo? articolo;
  final VoidCallback onSaved;
  const _ArticoloForm({this.articolo, required this.onSaved});

  @override
  State<_ArticoloForm> createState() => _ArticoloFormState();
}

class _ArticoloFormState extends State<_ArticoloForm> {
  late final TextEditingController _titoloCtrl;
  late final TextEditingController _corpoCtrl;
  Uint8List? _newImageBytes;
  String? _newImageMime;
  bool _removeImage = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final a = widget.articolo;
    _titoloCtrl = TextEditingController(text: a?.titolo ?? '');
    _corpoCtrl = TextEditingController(text: a?.corpo ?? '');
  }

  @override
  void dispose() {
    _titoloCtrl.dispose();
    _corpoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _newImageBytes = bytes;
      _newImageMime = file.mimeType ?? 'image/jpeg';
      _removeImage = false;
    });
  }

  bool get _hasImage =>
      _newImageBytes != null ||
      (widget.articolo?.immagineUrl != null && !_removeImage);

  String? get _currentImageUrl =>
      _removeImage ? null : widget.articolo?.immagineUrl;

  Future<void> _save() async {
    if (_titoloCtrl.text.trim().isEmpty || _corpoCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Titolo e corpo sono obbligatori')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      String? immagineUrl = _currentImageUrl;

      if (_newImageBytes != null) {
        if (widget.articolo?.immagineUrl != null) {
          await storageService
              .deleteImmagine(widget.articolo!.immagineUrl!);
        }
        immagineUrl = await storageService.uploadImmagine(
            _newImageBytes!, _newImageMime!);
      } else if (_removeImage && widget.articolo?.immagineUrl != null) {
        await storageService
            .deleteImmagine(widget.articolo!.immagineUrl!);
        immagineUrl = null;
      }

      if (widget.articolo == null) {
        await articoliService.inserisci(
          titolo: _titoloCtrl.text.trim(),
          corpo: _corpoCtrl.text.trim(),
          immagineUrl: immagineUrl,
        );
      } else {
        await articoliService.aggiorna(
          id: widget.articolo!.id,
          titolo: _titoloCtrl.text.trim(),
          corpo: _corpoCtrl.text.trim(),
          immagineUrl: immagineUrl,
        );
      }
      if (mounted) widget.onSaved();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante il salvataggio: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.articolo == null ? 'Nuovo articolo' : 'Modifica articolo',
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titoloCtrl,
            decoration: const InputDecoration(labelText: 'Titolo *'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _corpoCtrl,
            decoration: const InputDecoration(labelText: 'Corpo *'),
            minLines: 5,
            maxLines: null,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 12),
          if (_newImageBytes != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(_newImageBytes!,
                  height: 160, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => setState(() {
                _newImageBytes = null;
                _newImageMime = null;
              }),
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Rimuovi immagine',
                  style: TextStyle(color: Colors.red)),
            ),
          ] else if (_currentImageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(_currentImageUrl!,
                  height: 160, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Cambia immagine'),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _removeImage = true),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Rimuovi immagine',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ] else
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image_outlined),
              label:
                  const Text('Seleziona immagine (facoltativa)'),
            ),
          const SizedBox(height: 20),
          _saving
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E6370),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Salva',
                      style: TextStyle(fontSize: 16)),
                ),
        ],
      ),
    );
  }
}

// ── Wide: full page ────────────────────────────────────────────────────────────

class _ArticoloFormPage extends StatelessWidget {
  final Articolo? articolo;
  final VoidCallback onSaved;
  const _ArticoloFormPage({this.articolo, required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        foregroundColor: const Color(0xFF1E6370),
        title: Text(
            articolo == null ? 'Nuovo articolo' : 'Modifica articolo'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: _ArticoloForm(
            articolo: articolo,
            onSaved: () {
              onSaved();
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}

// ── Narrow: bottom sheet ───────────────────────────────────────────────────────

class _ArticoloFormSheet extends StatelessWidget {
  final Articolo? articolo;
  final VoidCallback onSaved;
  const _ArticoloFormSheet({this.articolo, required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      expand: false,
      builder: (_, _) => _ArticoloForm(
        articolo: articolo,
        onSaved: () {
          onSaved();
          Navigator.pop(context);
        },
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/pages/articoli_admin_page_test.dart
```

Expected: All 3 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/pages/articoli_admin_page.dart test/pages/articoli_admin_page_test.dart
git commit -m "feat: rewrite ArticoliAdminPage to use FutureBuilder + ArticoliService"
```

---

## Task 9: Remove Drift files

**Files:**
- Delete: `lib/database/app_database.dart`
- Delete: `lib/database/app_database.g.dart`
- Delete: `lib/database/articoli_dao.dart`
- Delete: `lib/database/articoli_dao.g.dart`
- Delete: `web/sqlite3.wasm`
- Delete: `web/drift_worker.js`
- Delete: `web/drift_worker.js.deps`
- Delete: `web/drift_worker.js.map`
- Remove: `coi-serviceworker.js` script tag from `web/index.html` (needed only for SharedArrayBuffer required by sqlite3.wasm)

- [ ] **Step 1: Delete Drift library files**

```bash
rm lib/database/app_database.dart lib/database/app_database.g.dart
rm lib/database/articoli_dao.dart lib/database/articoli_dao.g.dart
rmdir lib/database
```

- [ ] **Step 2: Delete Drift web assets**

```bash
rm web/sqlite3.wasm web/drift_worker.js web/drift_worker.js.deps web/drift_worker.js.map
```

- [ ] **Step 3: Remove coi-serviceworker script tag from web/index.html**

In `web/index.html`, remove this line:

```html
  <!--Workaround for publishing on github pages-->
  <script src="coi-serviceworker.js"></script>
```

(The `coi-serviceworker.js` file itself can stay — removing the script tag is sufficient and safer than deleting a file that GitHub Pages may reference.)

- [ ] **Step 4: Run full test suite**

```bash
flutter test
```

Expected: All tests PASS. No references to Drift remain.

- [ ] **Step 5: Verify build compiles**

```bash
flutter build web --no-pub 2>&1 | tail -5
```

Expected: `✓ Built build/web` with no errors.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "chore: remove Drift database files and web WASM assets"
```

---

## Task 10: Final verification and push

- [ ] **Step 1: Run full test suite one more time**

```bash
flutter test
```

Expected: All tests PASS.

- [ ] **Step 2: Check no Drift imports remain**

```bash
grep -r "drift" lib/ --include="*.dart" -l
```

Expected: No output (zero files).

- [ ] **Step 3: Push branch**

```bash
git push -u origin feature/supabase-migration
```

- [ ] **Step 4: Manually verify in browser**
  - Run `flutter run -d chrome`
  - Navigate to `/articoli` — page loads, spinner shows, then "Nessun articolo pubblicato." (or actual articles if the Supabase table has data)
  - Navigate to `/articoli/admin`, log in, create a test article with an image — verify it appears in the list and the image loads from the storage URL
  - Delete the test article — verify it disappears and the image is removed from storage
