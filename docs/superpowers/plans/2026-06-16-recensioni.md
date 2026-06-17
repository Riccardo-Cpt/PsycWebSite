# Recensioni Feature Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `/recensioni` page where visitors can self-register, log in, and submit or edit a star (1–5) + description review stored in a Supabase `reviews` table.

**Architecture:** Custom auth via `reviewer_users` Supabase table (SHA-256 hashed passwords, no Supabase Auth SDK). Four new files (`Review` model, `ReviewAuthService`, `ReviewsService`, `RecensioniPage`) wired into existing `main.dart` globals and `NavDrawer`. All HTTP calls use the same `http` package pattern already in use for articles.

**Tech Stack:** Flutter/Dart, `http ^1.2.0`, `crypto ^3.0.0` (SHA-256), Supabase REST v1, GoRouter, `intl ^0.20.0`, `flutter_test`

---

## File Map

| Action | Path | Responsibility |
|---|---|---|
| Modify | `pubspec.yaml` | Add `crypto: ^3.0.0` |
| Create | `lib/models/review.dart` | Plain Dart model for `reviews` table |
| Create | `lib/services/review_auth_service.dart` | Register/login/logout against `reviewer_users` |
| Create | `lib/services/reviews_service.dart` | CRUD for `reviews` table |
| Create | `lib/pages/recensioni_page.dart` | Reviews page + auth dialog + review form |
| Modify | `lib/main.dart` | Add globals + `/recensioni` route |
| Modify | `lib/widgets/nav_drawer.dart` | Add "Recensioni" nav entry |
| Create | `test/models/review_test.dart` | Unit tests for `Review.fromJson` |
| Create | `test/services/review_auth_service_test.dart` | Unit tests for hash + auth state |
| Create | `test/pages/recensioni_page_test.dart` | Widget tests for RecensioniPage |

---

### Task 1: Add crypto dependency

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add `crypto` to pubspec.yaml**

In `pubspec.yaml`, under `dependencies:`, add the line `crypto: ^3.0.0` after `intl: ^0.20.0`:

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
  crypto: ^3.0.0
```

- [ ] **Step 2: Fetch the package**

Run: `flutter pub get`
Expected: resolves without errors, `pubspec.lock` updated.

- [ ] **Step 3: Verify import compiles**

Run: `flutter build web --no-pub 2>&1 | head -5` (or just `flutter pub get` — if step 2 passed, that's sufficient; the full compilation happens in a later task).

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add crypto dependency for SHA-256 password hashing"
```

---

### Task 2: Review model

**Files:**
- Create: `lib/models/review.dart`
- Create: `test/models/review_test.dart`

- [ ] **Step 1: Write the failing tests**

Create `test/models/review_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:psic_app/models/review.dart';

void main() {
  group('Review.fromJson', () {
    test('parses all fields', () {
      final r = Review.fromJson({
        'id': 1,
        'Name': 'mario',
        'description': 'ottimo servizio',
        'created_at': '2026-06-16T10:00:00Z',
        'stars': 4,
      });
      expect(r.id, 1);
      expect(r.name, 'mario');
      expect(r.description, 'ottimo servizio');
      expect(r.createdAt, DateTime.parse('2026-06-16T10:00:00Z'));
      expect(r.stars, 4);
    });

    test('nullable createdAt when null', () {
      final r = Review.fromJson({
        'id': 2,
        'Name': 'lucia',
        'description': 'buono',
        'created_at': null,
        'stars': 3,
      });
      expect(r.createdAt, isNull);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/models/review_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:psic_app/models/review.dart'`

- [ ] **Step 3: Create the model**

Create `lib/models/review.dart`:

```dart
class Review {
  final int id;
  final String name;
  final String description;
  final DateTime? createdAt;
  final int stars;

  const Review({
    required this.id,
    required this.name,
    required this.description,
    this.createdAt,
    required this.stars,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as int,
        name: json['Name'] as String,
        description: json['description'] as String,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        stars: json['stars'] as int,
      );
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/models/review_test.dart`
Expected: All 2 tests pass.

- [ ] **Step 5: Run full test suite to verify no regression**

Run: `flutter test`
Expected: All tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/models/review.dart test/models/review_test.dart
git commit -m "feat: add Review model with fromJson"
```

---

### Task 3: ReviewAuthService

**Files:**
- Create: `lib/services/review_auth_service.dart`
- Create: `test/services/review_auth_service_test.dart`

The service uses SHA-256 to hash passwords before storing or comparing. It exposes `isLoggedIn` as a `ValueNotifier<bool>` so the UI can react to auth state changes. `overrideLoginForTest` and `overrideRegisterForTest` replace HTTP calls in tests.

- [ ] **Step 1: Create the test directory if needed**

Run: `mkdir -p test/services`

- [ ] **Step 2: Write the failing tests**

Create `test/services/review_auth_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:psic_app/services/review_auth_service.dart';

void main() {
  late ReviewAuthService service;

  setUp(() {
    service = ReviewAuthService();
  });

  group('login', () {
    test('sets isLoggedIn and currentUsername on success', () async {
      service.overrideLoginForTest = (u, p) async {};
      await service.login('mario', 'pass123');
      expect(service.isLoggedIn.value, isTrue);
      expect(service.currentUsername, 'mario');
    });

    test('throws and does not set state on wrong password', () async {
      service.overrideLoginForTest = (u, p) async {
        throw Exception('Credenziali errate');
      };
      expect(
        () => service.login('mario', 'wrong'),
        throwsException,
      );
      expect(service.isLoggedIn.value, isFalse);
      expect(service.currentUsername, isNull);
    });
  });

  group('register', () {
    test('sets isLoggedIn and currentUsername on success', () async {
      service.overrideRegisterForTest = (u, p) async {};
      await service.register('newuser', 'pass123');
      expect(service.isLoggedIn.value, isTrue);
      expect(service.currentUsername, 'newuser');
    });

    test('throws on duplicate username without setting state', () async {
      service.overrideRegisterForTest = (u, p) async {
        throw Exception('Username già in uso');
      };
      expect(
        () => service.register('existing', 'pass123'),
        throwsException,
      );
      expect(service.isLoggedIn.value, isFalse);
    });
  });

  group('logout', () {
    test('clears isLoggedIn and currentUsername', () async {
      service.overrideLoginForTest = (u, p) async {};
      await service.login('mario', 'pass');
      service.logout();
      expect(service.isLoggedIn.value, isFalse);
      expect(service.currentUsername, isNull);
    });
  });
}
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `flutter test test/services/review_auth_service_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:psic_app/services/review_auth_service.dart'`

- [ ] **Step 4: Create the service**

Create `lib/services/review_auth_service.dart`:

```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/admin_config.dart';

class ReviewAuthService {
  static const _readHeaders = {
    'apikey': AdminConfig.supabaseServiceRoleKey,
    'Authorization': 'Bearer ${AdminConfig.supabaseServiceRoleKey}',
  };

  static const _writeHeaders = {
    'apikey': AdminConfig.supabaseServiceRoleKey,
    'Authorization': 'Bearer ${AdminConfig.supabaseServiceRoleKey}',
    'Content-Type': 'application/json',
    'Prefer': 'return=minimal',
  };

  final ValueNotifier<bool> isLoggedIn = ValueNotifier(false);
  String? currentUsername;

  // ignore: avoid_public_members_for_test
  Future<void> Function(String, String)? overrideLoginForTest;
  // ignore: avoid_public_members_for_test
  Future<void> Function(String, String)? overrideRegisterForTest;

  static String _hash(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  Future<void> register(String username, String password) async {
    if (overrideRegisterForTest != null) {
      await overrideRegisterForTest!(username, password);
      currentUsername = username;
      isLoggedIn.value = true;
      return;
    }
    final uri = Uri.parse('${AdminConfig.supabaseRestUrl}/reviewer_users');
    final body = jsonEncode({
      'username': username,
      'password_hash': _hash(password),
    });
    final response = await http.post(uri, headers: _writeHeaders, body: body);
    if (response.statusCode == 409) {
      throw Exception('Username già in uso');
    }
    if (response.statusCode != 201) {
      throw Exception('Errore nella registrazione: ${response.body}');
    }
    currentUsername = username;
    isLoggedIn.value = true;
  }

  Future<void> login(String username, String password) async {
    if (overrideLoginForTest != null) {
      await overrideLoginForTest!(username, password);
      currentUsername = username;
      isLoggedIn.value = true;
      return;
    }
    final hash = _hash(password);
    final uri = Uri.parse(
        '${AdminConfig.supabaseRestUrl}/reviewer_users'
        '?username=eq.$username&password_hash=eq.$hash&select=id');
    final response = await http.get(uri, headers: _readHeaders);
    if (response.statusCode != 200) {
      throw Exception('Errore nel login: ${response.body}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    if (list.isEmpty) throw Exception('Credenziali errate');
    currentUsername = username;
    isLoggedIn.value = true;
  }

  void logout() {
    currentUsername = null;
    isLoggedIn.value = false;
  }
}
```

- [ ] **Step 5: Run service tests to verify they pass**

Run: `flutter test test/services/review_auth_service_test.dart`
Expected: All 5 tests pass.

- [ ] **Step 6: Run full test suite**

Run: `flutter test`
Expected: All tests pass.

- [ ] **Step 7: Commit**

```bash
git add lib/services/review_auth_service.dart test/services/review_auth_service_test.dart
git commit -m "feat: add ReviewAuthService with SHA-256 hashing and test overrides"
```

---

### Task 4: ReviewsService

**Files:**
- Create: `lib/services/reviews_service.dart`

No separate test file for this service — its HTTP layer is covered by the integration-style pattern already established (widget tests stub `overrideForTest`; direct HTTP is not unit-tested). The `overrideForTest` pattern mirrors `ArticoliService`.

- [ ] **Step 1: Create the service**

Create `lib/services/reviews_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/admin_config.dart';
import '../models/review.dart';

class ReviewsService {
  static const _readHeaders = {
    'apikey': AdminConfig.supabaseAnonKey,
    'Authorization': 'Bearer ${AdminConfig.supabaseAnonKey}',
  };

  static const _writeHeaders = {
    'apikey': AdminConfig.supabaseServiceRoleKey,
    'Authorization': 'Bearer ${AdminConfig.supabaseServiceRoleKey}',
    'Content-Type': 'application/json',
    'Prefer': 'return=minimal',
  };

  // ignore: avoid_public_members_for_test
  Future<List<Review>>? overrideForTest;
  // ignore: avoid_public_members_for_test
  Future<Review?> Function(String)? overrideMiaForTest;

  Future<List<Review>> tutti() async {
    if (overrideForTest != null) return overrideForTest!;
    final uri = Uri.parse(
        '${AdminConfig.supabaseRestUrl}/reviews?select=*&order=created_at.desc');
    final response = await http.get(uri, headers: _readHeaders);
    if (response.statusCode != 200) {
      throw Exception('Errore nel recupero delle recensioni: ${response.body}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Review?> mia(String username) async {
    if (overrideMiaForTest != null) return overrideMiaForTest!(username);
    final encodedUsername = Uri.encodeQueryComponent(username);
    final uri = Uri.parse(
        '${AdminConfig.supabaseRestUrl}/reviews'
        '?Name=eq.$encodedUsername&select=*');
    final response = await http.get(uri, headers: _readHeaders);
    if (response.statusCode != 200) {
      throw Exception('Errore nel recupero della recensione: ${response.body}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    if (list.isEmpty) return null;
    return Review.fromJson(list.first as Map<String, dynamic>);
  }

  Future<void> inserisci({
    required String name,
    required String description,
    required int stars,
  }) async {
    final uri = Uri.parse('${AdminConfig.supabaseRestUrl}/reviews');
    final body = jsonEncode({
      'Name': name,
      'description': description,
      'stars': stars,
    });
    final response = await http.post(uri, headers: _writeHeaders, body: body);
    if (response.statusCode != 201) {
      throw Exception('Errore nel salvataggio della recensione: ${response.body}');
    }
  }

  Future<void> aggiorna({
    required int id,
    required String description,
    required int stars,
  }) async {
    final uri = Uri.parse(
        '${AdminConfig.supabaseRestUrl}/reviews?id=eq.$id');
    final body = jsonEncode({
      'description': description,
      'stars': stars,
    });
    final response = await http.patch(uri, headers: _writeHeaders, body: body);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Errore nella modifica della recensione: ${response.body}');
    }
  }
}
```

- [ ] **Step 2: Run full test suite to verify no regression**

Run: `flutter test`
Expected: All tests pass (new file has no tests yet — that's covered by widget tests in Task 5).

- [ ] **Step 3: Commit**

```bash
git add lib/services/reviews_service.dart
git commit -m "feat: add ReviewsService (tutti, mia, inserisci, aggiorna)"
```

---

### Task 5: RecensioniPage

**Files:**
- Create: `lib/pages/recensioni_page.dart`
- Create: `test/pages/recensioni_page_test.dart`

This task assumes `reviewAuthService` and `reviewsService` globals exist in `main.dart` — they are added in Task 6. Add the import and global declarations to `main.dart` as part of this task so the page compiles and tests can run.

- [ ] **Step 1: Write the failing widget tests**

Create `test/pages/recensioni_page_test.dart`:

```dart
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
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/pages/recensioni_page_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:psic_app/pages/recensioni_page.dart'`

- [ ] **Step 3: Add globals to main.dart** (prerequisite so the page file can import them)

Edit `lib/main.dart` — add imports and globals (the route is added in Task 6):

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B7A1D)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

- [ ] **Step 4: Create RecensioniPage**

Create `lib/pages/recensioni_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/review.dart';
import '../widgets/nav_bar.dart';

class RecensioniPage extends StatelessWidget {
  const RecensioniPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const NavScaffold(body: _RecensioniBody());
  }
}

// ── Body ───────────────────────────────────────────────────────────────────────

class _RecensioniBody extends StatefulWidget {
  const _RecensioniBody();

  @override
  State<_RecensioniBody> createState() => _RecensioniBodyState();
}

class _RecensioniBodyState extends State<_RecensioniBody> {
  late Future<List<Review>> _futureReviews;
  Review? _myReview;
  bool _loadingMyReview = false;

  @override
  void initState() {
    super.initState();
    _futureReviews = reviewsService.tutti();
  }

  void _refresh() {
    setState(() {
      _futureReviews = reviewsService.tutti();
      _myReview = null;
    });
  }

  Future<void> _onButtonTap() async {
    if (!reviewAuthService.isLoggedIn.value) {
      final loggedIn = await showDialog<bool>(
        context: context,
        builder: (_) => const _AuthDialog(),
      );
      if (loggedIn != true || !mounted) return;
    }
    if (!mounted) return;
    setState(() => _loadingMyReview = true);
    final username = reviewAuthService.currentUsername!;
    final existing = await reviewsService.mia(username);
    if (!mounted) return;
    setState(() {
      _myReview = existing;
      _loadingMyReview = false;
    });
    _openForm(existing);
  }

  void _openForm(Review? existing) {
    final isWide = MediaQuery.of(context).size.width >= 720;
    if (isWide) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => _ReviewFormPage(existing: existing, onSaved: _refresh),
      ));
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => _ReviewFormSheet(existing: existing, onSaved: _refresh),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Recensioni',
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B7A1D)),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Review>>(
            future: _futureReviews,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Errore: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red)),
                );
              }
              final reviews = snapshot.data ?? [];
              if (reviews.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: Text('Nessuna recensione ancora.',
                        style: TextStyle(fontSize: 18, color: Colors.black54)),
                  ),
                );
              }
              return Column(
                children: reviews
                    .map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ReviewCard(review: r),
                        ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder<bool>(
            valueListenable: reviewAuthService.isLoggedIn,
            builder: (context, isLoggedIn, _) {
              return _loadingMyReview
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _onButtonTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B7A1D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        isLoggedIn && _myReview != null
                            ? 'Modifica la tua recensione'
                            : 'Lascia una recensione',
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
            },
          ),
          if (reviewAuthService.isLoggedIn.value) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => reviewAuthService.logout(),
                child: const Text('Esci',
                    style: TextStyle(color: Color(0xFF3B7A1D))),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Review card ────────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                for (int i = 1; i <= 5; i++)
                  Icon(
                    i <= review.stars ? Icons.star : Icons.star_border,
                    color: const Color(0xFF3B7A1D),
                    size: 20,
                  ),
                const SizedBox(width: 12),
                Text(review.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (review.createdAt != null)
                  Text(
                    DateFormat('yyyy-MM-dd').format(review.createdAt!),
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review.description,
                style: const TextStyle(fontSize: 15, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

// ── Auth dialog ────────────────────────────────────────────────────────────────

class _AuthDialog extends StatefulWidget {
  const _AuthDialog();

  @override
  State<_AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<_AuthDialog> {
  bool _isLogin = true;
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'Inserisci username e password');
      return;
    }
    if (!_isLogin && password != _confirmCtrl.text) {
      setState(() => _error = 'Le password non coincidono');
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      if (_isLogin) {
        await reviewAuthService.login(username, password);
      } else {
        await reviewAuthService.register(username, password);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isLogin ? 'Accedi' : 'Registrati'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              onSubmitted: _isLogin ? (_) => _submit() : null,
            ),
            if (!_isLogin) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _confirmCtrl,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Conferma password'),
                onSubmitted: (_) => _submit(),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() {
            _isLogin = !_isLogin;
            _error = null;
          }),
          child: Text(
            _isLogin
                ? 'Non hai un account? Registrati'
                : 'Hai già un account? Accedi',
            style: const TextStyle(color: Color(0xFF3B7A1D)),
          ),
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(8),
            child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B7A1D),
              foregroundColor: Colors.white,
            ),
            child: Text(_isLogin ? 'Accedi' : 'Registrati'),
          ),
      ],
    );
  }
}

// ── Review form (shared logic) ─────────────────────────────────────────────────

class _ReviewForm extends StatefulWidget {
  final Review? existing;
  final VoidCallback onSaved;
  const _ReviewForm({this.existing, required this.onSaved});

  @override
  State<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<_ReviewForm> {
  late final TextEditingController _descCtrl;
  late int _stars;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.existing?.description ?? '');
    _stars = widget.existing?.stars ?? 5;
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci una descrizione')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      if (widget.existing == null) {
        await reviewsService.inserisci(
          name: reviewAuthService.currentUsername!,
          description: _descCtrl.text.trim(),
          stars: _stars,
        );
      } else {
        await reviewsService.aggiorna(
          id: widget.existing!.id,
          description: _descCtrl.text.trim(),
          stars: _stars,
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
            widget.existing == null ? 'Lascia una recensione' : 'Modifica la tua recensione',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (int i = 1; i <= 5; i++)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    i <= _stars ? Icons.star : Icons.star_border,
                    color: const Color(0xFF3B7A1D),
                    size: 32,
                  ),
                  onPressed: () => setState(() => _stars = i),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(labelText: 'Descrizione *'),
            minLines: 4,
            maxLines: null,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 20),
          _saving
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B7A1D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Salva', style: TextStyle(fontSize: 16)),
                ),
        ],
      ),
    );
  }
}

// ── Wide: full page ────────────────────────────────────────────────────────────

class _ReviewFormPage extends StatelessWidget {
  final Review? existing;
  final VoidCallback onSaved;
  const _ReviewFormPage({this.existing, required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        foregroundColor: const Color(0xFF3B7A1D),
        title: Text(
            existing == null ? 'Lascia una recensione' : 'Modifica la tua recensione'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: _ReviewForm(
            existing: existing,
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

class _ReviewFormSheet extends StatelessWidget {
  final Review? existing;
  final VoidCallback onSaved;
  const _ReviewFormSheet({this.existing, required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      expand: false,
      builder: (_, _) => _ReviewForm(
        existing: existing,
        onSaved: () {
          onSaved();
          Navigator.pop(context);
        },
      ),
    );
  }
}
```

- [ ] **Step 5: Run widget tests**

Run: `flutter test test/pages/recensioni_page_test.dart`
Expected: All 3 tests pass.

- [ ] **Step 6: Run full test suite**

Run: `flutter test`
Expected: All tests pass.

- [ ] **Step 7: Commit**

```bash
git add lib/pages/recensioni_page.dart lib/main.dart test/pages/recensioni_page_test.dart
git commit -m "feat: add RecensioniPage with auth dialog and review form"
```

---

### Task 6: Wire up route and nav entry

**Files:**
- Modify: `lib/main.dart` (add `/recensioni` route)
- Modify: `lib/widgets/nav_drawer.dart` (add "Recensioni" entry)

- [ ] **Step 1: Add the `/recensioni` route to main.dart**

Edit `lib/main.dart` — add the import and route. The full updated file:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/home_page.dart';
import 'pages/servizi_page.dart';
import 'pages/articoli_page.dart';
import 'pages/articoli_admin_page.dart';
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
    GoRoute(path: '/articoli/admin', builder: (_, _) => const ArticoliAdminPage()),
    GoRoute(path: '/recensioni', builder: (_, _) => const RecensioniPage()),
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
```

- [ ] **Step 2: Add "Recensioni" entry to NavDrawer**

Edit `lib/widgets/nav_drawer.dart` — add the Recensioni `ListTile` after the "I miei articoli" entry. The complete updated `children` list in the `ListView`:

```dart
children: [
  Container(
    padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
    color: const Color(0xFFEEEEEE),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dr.ssa Maria Bianchi',
          style: TextStyle(
              color: Color(0xFF3B7A1D),
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          'Psicologa e Psicoterapeuta',
          style: TextStyle(color: Color(0xFF3B7A1D), fontSize: 13),
        ),
      ],
    ),
  ),
  ListTile(
    leading: const Icon(Icons.home_outlined, color: Color(0xFF3B7A1D)),
    title: const Text('Home', style: TextStyle(color: Color(0xFF3B7A1D))),
    onTap: () => _go(context, '/'),
  ),
  ListTile(
    leading: const Icon(Icons.psychology_outlined, color: Color(0xFF3B7A1D)),
    title: const Text('Servizi', style: TextStyle(color: Color(0xFF3B7A1D))),
    onTap: () => _go(context, '/servizi'),
  ),
  ListTile(
    leading: const Icon(Icons.article_outlined, color: Color(0xFF3B7A1D)),
    title: const Text('I miei articoli', style: TextStyle(color: Color(0xFF3B7A1D))),
    onTap: () => _go(context, '/articoli'),
  ),
  ListTile(
    leading: const Icon(Icons.star_outline, color: Color(0xFF3B7A1D)),
    title: const Text('Recensioni', style: TextStyle(color: Color(0xFF3B7A1D))),
    onTap: () => _go(context, '/recensioni'),
  ),
],
```

- [ ] **Step 3: Run full test suite**

Run: `flutter test`
Expected: All tests pass.

- [ ] **Step 4: Commit**

```bash
git add lib/main.dart lib/widgets/nav_drawer.dart
git commit -m "feat: wire /recensioni route and nav drawer entry"
```

---

## Manual setup required (Supabase)

Before testing end-to-end in the browser, run this SQL in the Supabase SQL editor for the project at `https://snsvamcecgizhecvtpwk.supabase.co`:

```sql
create table reviewer_users (
  id bigint generated always as identity primary key,
  username text unique not null,
  password_hash text not null,
  created_at timestamptz default now()
);

create table reviews (
  id bigint generated always as identity primary key,
  "Name" text unique not null,
  "description" text not null,
  created_at timestamptz default now(),
  stars int not null check (stars >= 1 and stars <= 5)
);
```

Then set RLS policies:
- `reviews`: enable RLS, add policy `SELECT` for `anon` role (public reads).
- `reviewer_users`: enable RLS, no anon access (service-role key bypasses RLS).
