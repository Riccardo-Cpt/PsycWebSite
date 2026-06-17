# Review Submission Redesign — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the login/register + mailto flow with a password-free magic-link review submission: user fills a form → receives a one-time email link → clicks it → submits review → admin gets an email notification and approves/rejects in the admin console.

**Architecture:** Three Supabase edge functions handle the three stages (send magic link, verify token, submit review). Flutter reads the token from the URL on load, stores verified identity in `ReviewAuthService`, and drives a two-step form on the recensioni page. No passwords, no sessions — the DB `email_approval` table holds short-lived tokens.

**Tech Stack:** Flutter/Dart (web), Supabase PostgREST, Supabase Edge Functions (Deno/TypeScript), Resend (email), go_router, `http` package.

---

## File Map

| Action | Path | Responsibility |
|---|---|---|
| Modify | `lib/models/review.dart` | Remove `reviewer_users` join fields, add `email` field |
| Replace | `lib/services/review_auth_service.dart` | `sendMagicLink` + `verifyToken`, `isVerified` notifier |
| Modify | `lib/services/reviews_service.dart` | Replace `inserisci`, remove `mia`/`aggiorna` |
| Modify | `lib/pages/recensioni_page.dart` | Two-step form, remove auth dialog + logout |
| Modify | `lib/main.dart` | Parse `token` from URL on init, call `verifyToken` |
| Replace | `test/services/review_auth_service_test.dart` | Tests for new `sendMagicLink`/`verifyToken` API |
| Modify | `test/pages/recensioni_page_test.dart` | Update tests for new two-step flow |
| Modify | `test/models/review_test.dart` | Update for new `Review` fields |
| Create | `supabase/functions/send-review-magic-link/index.ts` | Upsert user, store token, send email to user |
| Create | `supabase/functions/verify-review-token/index.ts` | Validate token, return identity |
| Create | `supabase/functions/submit-review/index.ts` | Insert review, send admin email |
| Delete | `supabase/functions/reset-password/index.ts` | No longer needed |

---

## Task 1: Update `Review` model

The `Review` model currently joins `reviewer_users` to get `name`, `surname`, `userEmail`. Under the new schema, `reviews` has its own `username` column (no join needed for display), and `email` is on the review row itself. The admin view no longer needs a join either.

**Files:**
- Modify: `lib/models/review.dart`
- Modify: `test/models/review_test.dart`

- [ ] **Step 1: Write the failing tests**

Replace `test/models/review_test.dart` entirely:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:psic_app/models/review.dart';

void main() {
  group('Review.fromJson', () {
    test('parses all fields from flat row', () {
      final r = Review.fromJson({
        'id': 1,
        'username': 'mario_r',
        'email': 'mario@example.com',
        'title': 'Ottimo',
        'description': 'ottimo servizio',
        'created_at': '2026-06-16T10:00:00Z',
        'stars': 4,
        'approved': true,
      });
      expect(r.id, 1);
      expect(r.username, 'mario_r');
      expect(r.email, 'mario@example.com');
      expect(r.title, 'Ottimo');
      expect(r.description, 'ottimo servizio');
      expect(r.createdAt, DateTime.parse('2026-06-16T10:00:00Z'));
      expect(r.stars, 4);
      expect(r.approved, isTrue);
    });

    test('nullable createdAt when null', () {
      final r = Review.fromJson({
        'id': 2,
        'username': 'lucia',
        'email': 'lucia@example.com',
        'title': 'Buono',
        'description': 'buono',
        'created_at': null,
        'stars': 3,
        'approved': false,
      });
      expect(r.createdAt, isNull);
      expect(r.approved, isFalse);
    });
  });
}
```

- [ ] **Step 2: Run to confirm failure**

```bash
flutter test test/models/review_test.dart
```
Expected: FAIL (fields mismatch)

- [ ] **Step 3: Update `Review` model**

Replace `lib/models/review.dart` entirely:

```dart
class Review {
  final int id;
  final String username;
  final String email;
  final String title;
  final String description;
  final DateTime? createdAt;
  final int stars;
  final bool approved;

  const Review({
    required this.id,
    required this.username,
    required this.email,
    required this.title,
    required this.description,
    this.createdAt,
    required this.stars,
    this.approved = false,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      stars: json['stars'] as int,
      approved: (json['approved'] as bool?) ?? false,
    );
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/models/review_test.dart
```
Expected: PASS (2 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/models/review.dart test/models/review_test.dart
git commit -m "refactor(review): flatten model — email + username on reviews row, remove join fields"
```

---

## Task 2: Replace `ReviewAuthService`

The current service handles login/register/logout with passwords. The new one calls two edge functions: `send-review-magic-link` and `verify-review-token`.

The edge functions don't exist yet, so we use override hooks for testing (same pattern as the current codebase).

**Files:**
- Replace: `lib/services/review_auth_service.dart`
- Replace: `test/services/review_auth_service_test.dart`

- [ ] **Step 1: Write the failing tests**

Replace `test/services/review_auth_service_test.dart` entirely:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:psic_app/services/review_auth_service.dart';

void main() {
  late ReviewAuthService service;

  setUp(() => service = ReviewAuthService());

  group('sendMagicLink', () {
    test('does not set isVerified', () async {
      service.overrideSendMagicLinkForTest = (_, __, ___, ____) async {};
      await service.sendMagicLink(
        email: 'a@b.com',
        username: 'user1',
        name: 'Mario',
        surname: 'Rossi',
      );
      expect(service.isVerified.value, isFalse);
    });

    test('throws on error', () async {
      service.overrideSendMagicLinkForTest = (_, __, ___, ____) async {
        throw Exception('network error');
      };
      expect(
        () => service.sendMagicLink(
          email: 'a@b.com',
          username: 'user1',
          name: 'Mario',
          surname: 'Rossi',
        ),
        throwsException,
      );
    });
  });

  group('verifyToken', () {
    test('sets isVerified and stores identity on success', () async {
      service.overrideVerifyTokenForTest = (_) async => {
        'email': 'a@b.com',
        'username': 'user1',
        'name': 'Mario',
      };
      await service.verifyToken('valid-token');
      expect(service.isVerified.value, isTrue);
      expect(service.currentEmail, 'a@b.com');
      expect(service.currentUsername, 'user1');
      expect(service.currentName, 'Mario');
    });

    test('throws and does not set isVerified on error', () async {
      service.overrideVerifyTokenForTest = (_) async =>
          throw Exception('Link non valido o scaduto');
      expect(() => service.verifyToken('bad-token'), throwsException);
      expect(service.isVerified.value, isFalse);
      expect(service.currentEmail, isNull);
    });

    test('reset clears all state', () async {
      service.overrideVerifyTokenForTest = (_) async => {
        'email': 'a@b.com',
        'username': 'user1',
        'name': 'Mario',
      };
      await service.verifyToken('valid-token');
      service.reset();
      expect(service.isVerified.value, isFalse);
      expect(service.currentEmail, isNull);
      expect(service.currentUsername, isNull);
      expect(service.currentName, isNull);
    });
  });
}
```

- [ ] **Step 2: Run to confirm failure**

```bash
flutter test test/services/review_auth_service_test.dart
```
Expected: FAIL (class API mismatch)

- [ ] **Step 3: Replace `review_auth_service.dart`**

```dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/admin_config.dart';

class ReviewAuthService {
  final ValueNotifier<bool> isVerified = ValueNotifier(false);
  String? currentEmail;
  String? currentUsername;
  String? currentName;

  // ignore: avoid_public_members_for_test
  Future<void> Function(String, String, String, String)?
      overrideSendMagicLinkForTest;
  // ignore: avoid_public_members_for_test
  Future<Map<String, dynamic>> Function(String)? overrideVerifyTokenForTest;

  Future<void> sendMagicLink({
    required String email,
    required String username,
    required String name,
    required String surname,
  }) async {
    if (overrideSendMagicLinkForTest != null) {
      return overrideSendMagicLinkForTest!(email, username, name, surname);
    }
    final uri = Uri.parse(
        '${AdminConfig.supabaseUrl}/functions/v1/send-review-magic-link');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer ${AdminConfig.supabaseAnonKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'username': username,
        'name': name,
        'surname': surname,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Errore: riprova più tardi.');
    }
  }

  Future<void> verifyToken(String token) async {
    final Map<String, dynamic> data;
    if (overrideVerifyTokenForTest != null) {
      data = await overrideVerifyTokenForTest!(token);
    } else {
      final uri = Uri.parse(
          '${AdminConfig.supabaseUrl}/functions/v1/verify-review-token');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer ${AdminConfig.supabaseAnonKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'token': token}),
      );
      if (response.statusCode != 200) {
        throw Exception('Link non valido o scaduto. Richiedi un nuovo link.');
      }
      data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['error'] != null) {
        throw Exception('Link non valido o scaduto. Richiedi un nuovo link.');
      }
    }
    currentEmail = data['email'] as String;
    currentUsername = data['username'] as String;
    currentName = data['name'] as String?;
    isVerified.value = true;
  }

  void reset() {
    currentEmail = null;
    currentUsername = null;
    currentName = null;
    isVerified.value = false;
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/services/review_auth_service_test.dart
```
Expected: PASS (5 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/services/review_auth_service.dart test/services/review_auth_service_test.dart
git commit -m "refactor(review-auth): replace login/register with magic-link sendMagicLink/verifyToken"
```

---

## Task 3: Update `ReviewsService`

Remove `mia()`, `aggiorna()`, and the direct REST insert + `_notificaAdmin`. Replace `inserisci()` with a call to the `submit-review` edge function.

**Files:**
- Modify: `lib/services/reviews_service.dart`

- [ ] **Step 1: Update `reviews_service.dart`**

The `tutti()`, `tuttiAdmin()`, `approva()`, `cancella()` methods stay as-is. Replace the file:

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

  static const _adminReadHeaders = {
    'apikey': AdminConfig.supabaseServiceRoleKey,
    'Authorization': 'Bearer ${AdminConfig.supabaseServiceRoleKey}',
  };

  static const _writeHeaders = {
    'apikey': AdminConfig.supabaseServiceRoleKey,
    'Authorization': 'Bearer ${AdminConfig.supabaseServiceRoleKey}',
    'Content-Type': 'application/json',
    'Prefer': 'return=minimal',
  };

  // ignore: avoid_public_members_for_test
  Future<List<Review>>? overrideForTest;

  /// Public: only approved reviews.
  Future<List<Review>> tutti() async {
    if (overrideForTest != null) return overrideForTest!;
    final uri = Uri.parse(
        '${AdminConfig.supabaseRestUrl}/reviews?select=*&approved=eq.true&order=created_at.desc');
    final response = await http.get(uri, headers: _readHeaders);
    if (response.statusCode != 200) {
      throw Exception('Errore nel recupero delle recensioni: ${response.body}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Admin: all reviews regardless of approval status.
  Future<List<Review>> tuttiAdmin() async {
    final uri = Uri.parse(
        '${AdminConfig.supabaseRestUrl}/reviews'
        '?select=*'
        '&order=created_at.desc');
    final response = await http.get(uri, headers: _adminReadHeaders);
    if (response.statusCode != 200) {
      throw Exception('Errore nel recupero delle recensioni: ${response.body}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> inserisci({
    required String email,
    required String title,
    required String description,
    required int stars,
  }) async {
    final uri = Uri.parse(
        '${AdminConfig.supabaseUrl}/functions/v1/submit-review');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer ${AdminConfig.supabaseAnonKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'title': title,
        'description': description,
        'stars': stars,
      }),
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['error'] == 'duplicate') {
        throw Exception(
            'Hai già inviato una recensione. Puoi contattarci per modificarla.');
      }
      throw Exception('Errore: riprova più tardi.');
    }
  }

  Future<void> approva(int id) async {
    final uri = Uri.parse(
        '${AdminConfig.supabaseRestUrl}/reviews?id=eq.$id');
    final body = jsonEncode({'approved': true});
    final response = await http.patch(uri, headers: _writeHeaders, body: body);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Errore nell\'approvazione della recensione: ${response.body}');
    }
  }

  Future<void> cancella(int id) async {
    final uri = Uri.parse(
        '${AdminConfig.supabaseRestUrl}/reviews?id=eq.$id');
    final response = await http.delete(uri, headers: _writeHeaders);
    if (response.statusCode != 204) {
      throw Exception('Errore nell\'eliminazione della recensione: ${response.body}');
    }
  }
}
```

- [ ] **Step 2: Run all tests**

```bash
flutter test
```
Expected: the previously-passing tests still pass; any compilation errors from removed methods are visible here.

- [ ] **Step 3: Commit**

```bash
git add lib/services/reviews_service.dart
git commit -m "refactor(reviews): replace inserisci direct-insert with submit-review edge fn, remove mia/aggiorna"
```

---

## Task 4: Update `recensioni_page.dart`

Remove the `_AuthDialog`, the logout button, and the login-gated form open. Replace with a two-step inline flow: step 1 (identity form) shown when not verified, step 2 (review form) shown when `isVerified` is true. Token from URL is handled in `main.dart` (Task 5) — the page just reacts to `isVerified`.

**Files:**
- Modify: `lib/pages/recensioni_page.dart`
- Modify: `test/pages/recensioni_page_test.dart`

- [ ] **Step 1: Write the failing tests**

Replace `test/pages/recensioni_page_test.dart` entirely:

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
```

- [ ] **Step 2: Run to confirm failure**

```bash
flutter test test/pages/recensioni_page_test.dart
```
Expected: FAIL

- [ ] **Step 3: Rewrite `recensioni_page.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/review.dart';
import '../widgets/nav_bar.dart';
import '../widgets/site_footer.dart';

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

  @override
  void initState() {
    super.initState();
    _futureReviews = reviewsService.tutti();
  }

  void _refresh() {
    setState(() {
      _futureReviews = reviewsService.tutti();
    });
  }

  void _openForm() {
    final isWide = MediaQuery.of(context).size.width >= 720;
    if (isWide) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => _ReviewFlowPage(onSaved: _refresh),
      ));
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => _ReviewFlowSheet(onSaved: _refresh),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Recensioni',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E6370)),
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
                              style: TextStyle(
                                  fontSize: 18, color: Colors.black54)),
                        ),
                      );
                    }
                    return Column(
                      children: reviews
                          .map((r) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child:
                                    _ReviewCard(review: r, onDeleted: _refresh),
                              ))
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _openForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E6370),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Lascia una recensione',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          const SiteFooter(),
        ],
      ),
    );
  }
}

// ── Review card ────────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback? onDeleted;
  const _ReviewCard({required this.review, this.onDeleted});

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Elimina recensione'),
        content: Text(
            'Eliminare la recensione di "${review.username}"? L\'azione è irreversibile.'),
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
      try {
        await reviewsService.cancella(review.id);
        onDeleted?.call();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore durante l\'eliminazione: $e')),
          );
        }
      }
    }
  }

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
                Text(review.username,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const Spacer(),
                if (review.createdAt != null)
                  Text(
                    DateFormat('yyyy-MM-dd').format(review.createdAt!),
                    style:
                        const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ValueListenableBuilder<bool>(
                  valueListenable: blogAuthService.isAdmin,
                  builder: (context, isAdmin, _) => isAdmin
                      ? IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red, size: 20),
                          tooltip: 'Elimina recensione',
                          onPressed: () => _confirmDelete(context),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                for (int i = 1; i <= 5; i++)
                  Icon(
                    i <= review.stars ? Icons.star : Icons.star_border,
                    color: const Color(0xFFFFC107),
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(review.title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 6),
            Text(review.description,
                style: const TextStyle(
                    fontSize: 15, height: 1.5, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}

// ── Flow: step 1 = identity form, step 2 = review form ────────────────────────

class _ReviewFlow extends StatefulWidget {
  final VoidCallback onSaved;
  const _ReviewFlow({required this.onSaved});

  @override
  State<_ReviewFlow> createState() => _ReviewFlowState();
}

class _ReviewFlowState extends State<_ReviewFlow> {
  // Step 1 controllers
  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _nomeCtrl = TextEditingController();
  final _cognomeCtrl = TextEditingController();

  // Step 2 controllers
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  int _stars = 5;

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _nomeCtrl.dispose();
    _cognomeCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendLink() async {
    final email = _emailCtrl.text.trim();
    final username = _usernameCtrl.text.trim();
    final name = _nomeCtrl.text.trim();
    final surname = _cognomeCtrl.text.trim();
    if (email.isEmpty || username.isEmpty || name.isEmpty || surname.isEmpty) {
      setState(() => _error = 'Compila tutti i campi');
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      await reviewAuthService.sendMagicLink(
        email: email,
        username: username,
        name: name,
        surname: surname,
      );
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Link inviato! Controlla la tua email e clicca il link per continuare.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Errore: riprova più tardi.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _submitReview() async {
    if (_titleCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Inserisci titolo e descrizione');
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      await reviewsService.inserisci(
        email: reviewAuthService.currentEmail!,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        stars: _stars,
      );
      reviewAuthService.reset();
      if (mounted) widget.onSaved();
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
    return ValueListenableBuilder<bool>(
      valueListenable: reviewAuthService.isVerified,
      builder: (context, isVerified, _) {
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
              if (!isVerified) ..._buildStep1() else ..._buildStep2(),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 20),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: isVerified ? _submitReview : _sendLink,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E6370),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        isVerified ? 'Invia recensione' : 'Invia link di conferma',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildStep1() => [
        const Text('Lascia una recensione',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text(
          'Inserisci i tuoi dati. Riceverai un link via email per confermare e inviare la tua recensione.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailCtrl,
          decoration: const InputDecoration(labelText: 'Email *'),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _usernameCtrl,
          decoration: const InputDecoration(labelText: 'Username *'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nomeCtrl,
          decoration: const InputDecoration(labelText: 'Nome *'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cognomeCtrl,
          decoration: const InputDecoration(labelText: 'Cognome *'),
        ),
      ];

  List<Widget> _buildStep2() => [
        const Text('La tua recensione',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            for (int i = 1; i <= 5; i++)
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  i <= _stars ? Icons.star : Icons.star_border,
                  color: const Color(0xFF1E6370),
                  size: 32,
                ),
                onPressed: () => setState(() => _stars = i),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _titleCtrl,
          decoration: const InputDecoration(labelText: 'Titolo *'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descCtrl,
          decoration: const InputDecoration(labelText: 'Descrizione *'),
          minLines: 4,
          maxLines: null,
          keyboardType: TextInputType.multiline,
        ),
      ];
}

// ── Wide: full page ────────────────────────────────────────────────────────────

class _ReviewFlowPage extends StatelessWidget {
  final VoidCallback onSaved;
  const _ReviewFlowPage({required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        foregroundColor: const Color(0xFF1E6370),
        title: const Text('Lascia una recensione'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: _ReviewFlow(
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

class _ReviewFlowSheet extends StatelessWidget {
  final VoidCallback onSaved;
  const _ReviewFlowSheet({required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      expand: false,
      builder: (_, _) => _ReviewFlow(
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
flutter test test/pages/recensioni_page_test.dart
```
Expected: PASS (4 tests)

- [ ] **Step 5: Run all tests**

```bash
flutter test
```
Expected: all previously-passing tests still pass; no regressions.

- [ ] **Step 6: Commit**

```bash
git add lib/pages/recensioni_page.dart test/pages/recensioni_page_test.dart
git commit -m "feat(recensioni): two-step magic-link flow, remove auth dialog and logout"
```

---

## Task 5: Handle token in URL (`main.dart`)

When the user clicks the magic link (`{SITE_URL}/#/recensioni?token=xxx`), `go_router` lands on `/recensioni`. We need to intercept the `token` query param on that route and call `verifyToken` before rendering the page.

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Update `main.dart`**

```dart
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E6370)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

- [ ] **Step 2: Run all tests**

```bash
flutter test
```
Expected: all tests pass.

- [ ] **Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "feat(router): verify magic-link token from URL on /recensioni route"
```

---

## Task 6: Delete obsolete files

`reset_password_page.dart` and `password_reset_service.dart` were untracked (never committed). The `reset-password` edge function is committed and must be removed.

**Files:**
- Delete: `supabase/functions/reset-password/index.ts`

- [ ] **Step 1: Delete the reset-password edge function**

```bash
rm -rf supabase/functions/reset-password
```

- [ ] **Step 2: Verify the files never existed in Flutter source**

```bash
ls lib/pages/reset_password_page.dart lib/services/password_reset_service.dart 2>&1
```
Expected: `No such file or directory` for both (they were untracked, never added).

- [ ] **Step 3: Run all tests**

```bash
flutter test
```
Expected: all tests pass.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "chore: remove reset-password edge function (no longer needed)"
```

---

## Task 7: Edge function — `send-review-magic-link`

Creates or updates the user in `reviewer_users`, stores a magic-link token in `email_approval`, sends the verification email via Resend.

**Files:**
- Create: `supabase/functions/send-review-magic-link/index.ts`

- [ ] **Step 1: Create the function**

```bash
mkdir -p supabase/functions/send-review-magic-link
```

Create `supabase/functions/send-review-magic-link/index.ts`:

```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')!;
const SITE_URL = Deno.env.get('SITE_URL')!;
const RESEND_FROM_EMAIL = Deno.env.get('RESEND_FROM_EMAIL')!;

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { email, username, name, surname } = await req.json();
    if (!email || !username || !name || !surname) {
      return new Response(
        JSON.stringify({ error: 'Tutti i campi sono obbligatori' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // Upsert user (email is PK)
    const { error: upsertError } = await supabase
      .from('reviewer_users')
      .upsert({ email, username, name, surname }, { onConflict: 'email' });
    if (upsertError) throw upsertError;

    // Delete any existing token for this email
    await supabase.from('email_approval').delete().eq('email', email);

    // Generate token and store
    const token = crypto.randomUUID() + '-' + crypto.randomUUID();
    const expiresAt = new Date(Date.now() + 60 * 60 * 1000); // 1 hour
    const { error: insertError } = await supabase.from('email_approval').insert({
      email,
      token,
      expires_at: expiresAt.toISOString(),
    });
    if (insertError) throw insertError;

    // Send magic link email
    const magicLink = `${SITE_URL}/#/recensioni?token=${token}`;
    const emailRes = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: RESEND_FROM_EMAIL,
        to: email,
        subject: 'Conferma la tua email per inviare la recensione',
        html: `
          <p>Ciao ${name},</p>
          <p>Clicca il link seguente per confermare la tua email e inviare la tua recensione. Il link è valido per 1 ora.</p>
          <p><a href="${magicLink}">${magicLink}</a></p>
          <p>Se non hai richiesto questo link, ignoralo.</p>
        `,
      }),
    });
    if (!emailRes.ok) {
      const body = await emailRes.text();
      throw new Error(`Errore Resend: ${body}`);
    }

    // Always return ok to avoid email enumeration
    return new Response(JSON.stringify({ ok: true }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
```

- [ ] **Step 2: Commit**

```bash
git add supabase/functions/send-review-magic-link/index.ts
git commit -m "feat(edge): add send-review-magic-link function"
```

---

## Task 8: Edge function — `verify-review-token`

Validates the token from `email_approval`, deletes it (one-time use), returns the user identity.

**Files:**
- Create: `supabase/functions/verify-review-token/index.ts`

- [ ] **Step 1: Create the function**

```bash
mkdir -p supabase/functions/verify-review-token
```

Create `supabase/functions/verify-review-token/index.ts`:

```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { token } = await req.json();
    if (!token) {
      return new Response(JSON.stringify({ error: 'Token mancante' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // Look up token
    const { data: rows, error } = await supabase
      .from('email_approval')
      .select('email, expires_at')
      .eq('token', token)
      .limit(1);
    if (error) throw error;

    if (!rows || rows.length === 0) {
      return new Response(JSON.stringify({ error: 'Token non valido' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const row = rows[0];
    if (new Date(row.expires_at) < new Date()) {
      await supabase.from('email_approval').delete().eq('token', token);
      return new Response(JSON.stringify({ error: 'Token scaduto' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Delete token (one-time use)
    await supabase.from('email_approval').delete().eq('token', token);

    // Fetch user details
    const { data: users, error: userError } = await supabase
      .from('reviewer_users')
      .select('username, name')
      .eq('email', row.email)
      .limit(1);
    if (userError) throw userError;

    const user = users?.[0];
    return new Response(
      JSON.stringify({
        email: row.email,
        username: user?.username ?? '',
        name: user?.name ?? '',
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
```

- [ ] **Step 2: Commit**

```bash
git add supabase/functions/verify-review-token/index.ts
git commit -m "feat(edge): add verify-review-token function"
```

---

## Task 9: Edge function — `submit-review`

Inserts the review row (fetching `username` from `reviewer_users`) and emails the admin.

**Files:**
- Create: `supabase/functions/submit-review/index.ts`

- [ ] **Step 1: Create the function**

```bash
mkdir -p supabase/functions/submit-review
```

Create `supabase/functions/submit-review/index.ts`:

```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')!;
const RESEND_FROM_EMAIL = Deno.env.get('RESEND_FROM_EMAIL')!;
const ADMIN_EMAIL = Deno.env.get('ADMIN_EMAIL')!;

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { email, title, description, stars } = await req.json();
    if (!email || !title || !description || !stars) {
      return new Response(
        JSON.stringify({ error: 'Tutti i campi sono obbligatori' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // Fetch user details for the review row and admin email
    const { data: users, error: userError } = await supabase
      .from('reviewer_users')
      .select('username, name, surname')
      .eq('email', email)
      .limit(1);
    if (userError) throw userError;
    if (!users || users.length === 0) {
      return new Response(JSON.stringify({ error: 'Utente non trovato' }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }
    const user = users[0];

    // Insert review
    const { error: insertError } = await supabase.from('reviews').insert({
      email,
      username: user.username,
      title,
      description,
      stars,
      approved: false,
    });
    if (insertError) {
      // Unique constraint on email = duplicate review
      if (insertError.code === '23505') {
        return new Response(JSON.stringify({ error: 'duplicate' }), {
          status: 409,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
      }
      throw insertError;
    }

    // Send admin notification (non-blocking — review already saved)
    fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: RESEND_FROM_EMAIL,
        to: ADMIN_EMAIL,
        subject: 'Nuova recensione in attesa di approvazione',
        html: `
          <p>È stata ricevuta una nuova recensione che richiede la tua approvazione.</p>
          <ul>
            <li><strong>Username:</strong> ${user.username}</li>
            <li><strong>Nome:</strong> ${user.name} ${user.surname}</li>
            <li><strong>Email:</strong> ${email}</li>
            <li><strong>Stelle:</strong> ${stars}/5</li>
            <li><strong>Titolo:</strong> ${title}</li>
          </ul>
          <blockquote>${description}</blockquote>
          <p>Accedi al pannello admin per approvarla o rifiutarla.</p>
        `,
      }),
    }).catch(() => {});

    return new Response(JSON.stringify({ ok: true }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
```

- [ ] **Step 2: Commit**

```bash
git add supabase/functions/submit-review/index.ts
git commit -m "feat(edge): add submit-review function with admin email notification"
```

---

## Task 10: Deploy edge functions and set env vars

The three new edge functions must be deployed to Supabase and given their environment variables.

**Prerequisites:** Supabase CLI installed and linked to the project (`supabase link`). A Resend account with a verified sender domain/email.

- [ ] **Step 1: Deploy the three functions**

```bash
supabase functions deploy send-review-magic-link
supabase functions deploy verify-review-token
supabase functions deploy submit-review
```

- [ ] **Step 2: Set environment variables**

Replace the values with your real credentials:

```bash
supabase secrets set \
  RESEND_API_KEY=re_xxxxxxxxxxxx \
  SITE_URL=https://your-deployed-site.com \
  RESEND_FROM_EMAIL=noreply@yourdomain.com \
  ADMIN_EMAIL=admin@yourdomain.com
```

`SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are injected automatically by Supabase into every edge function — do not set them manually.

- [ ] **Step 3: Smoke test `send-review-magic-link`**

```bash
curl -X POST \
  https://<your-project-ref>.supabase.co/functions/v1/send-review-magic-link \
  -H "Authorization: Bearer <anon-key>" \
  -H "Content-Type: application/json" \
  -d '{"email":"yourtest@email.com","username":"testuser","name":"Test","surname":"User"}'
```
Expected: `{"ok":true}` and an email arrives at `yourtest@email.com`.

- [ ] **Step 4: Smoke test `verify-review-token`** (use the token from the email link)

```bash
curl -X POST \
  https://<your-project-ref>.supabase.co/functions/v1/verify-review-token \
  -H "Authorization: Bearer <anon-key>" \
  -H "Content-Type: application/json" \
  -d '{"token":"<token-from-email>"}'
```
Expected: `{"email":"yourtest@email.com","username":"testuser","name":"Test"}`

- [ ] **Step 5: Smoke test `submit-review`**

```bash
curl -X POST \
  https://<your-project-ref>.supabase.co/functions/v1/submit-review \
  -H "Authorization: Bearer <anon-key>" \
  -H "Content-Type: application/json" \
  -d '{"email":"yourtest@email.com","title":"Test","description":"Ottimo servizio","stars":5}'
```
Expected: `{"ok":true}` and admin notification email arrives.

---

## Task 11: Final regression check

- [ ] **Step 1: Run full test suite**

```bash
flutter test
```
Expected: all tests pass, 0 failures.

- [ ] **Step 2: Build for web**

```bash
flutter build web
```
Expected: build completes with no errors.

- [ ] **Step 3: Manual end-to-end test**

Run `flutter run -d chrome`, navigate to `/recensioni`, click "Lascia una recensione":
1. Identity form shows Email, Username, Nome, Cognome fields
2. Fill in valid data → "Invia link di conferma" → SnackBar confirms email sent
3. Click magic link from inbox → page loads → form shows Titolo, Descrizione, stars
4. Submit review → page refreshes (review pending, not shown publicly yet)
5. Log in as admin → pending review visible → approve → review appears publicly
