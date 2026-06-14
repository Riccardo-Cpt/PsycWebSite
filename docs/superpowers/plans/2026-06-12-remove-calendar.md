# Remove Calendar Functionality — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove all calendar/appointment functionality from `psic_app_definitive`, leaving only `HomePage`, `ServiziPage`, and `NavBar`.

**Architecture:** The `lib/` source files are missing from disk but present in an identical copy at `../psic_app_calendar/`. Restore them first, then surgically remove calendar code across 3 modified files and 13 deleted files. No new code is written — this is pure deletion/trimming. The git repo has corrupted objects (Zone.Identifier files); commits will use `git add` per-file rather than by tree.

**Tech Stack:** Flutter Web, Dart, go_router ^17, drift ^2 (being removed), build_runner (dev, being removed).

---

## File Map

### Restored then deleted (from `../psic_app_calendar/`)
- `lib/pages/appuntamento_page.dart` — appointment booking form
- `lib/pages/miei_appuntamenti_page.dart` — calendar grid view
- `lib/pages/login_page.dart` — admin login gate
- `lib/database/app_database.dart` — Drift schema
- `lib/database/app_database.g.dart` — generated
- `lib/database/appuntamenti_dao.dart` — appointment DAO
- `lib/database/appuntamenti_dao.g.dart` — generated
- `lib/database/profili_dao.dart` — profile DAO
- `lib/database/profili_dao.g.dart` — generated
- `lib/services/auth_service.dart` — login/logout
- `lib/config/admin_config.dart` — hardcoded admin password
- `test/pages/appuntamento_page_test.dart` — tests for deleted page
- `test/pages/miei_appuntamenti_page_test.dart` — tests for deleted page
- `test/services/auth_service_test.dart` — tests for deleted service
- `test/pages/login_page_test.dart` — tests for deleted page

### Restored then modified
- `lib/main.dart` — strip calendar imports, globals, redirect guard, routes
- `lib/widgets/nav_bar.dart` — strip calendar nav links and logout button
- `pubspec.yaml` — strip 5 drift-related packages

### Not touched
- `lib/pages/home_page.dart`
- `lib/pages/servizi_page.dart`
- `lib/config/contatti.dart`
- `lib/widgets/contact_chip.dart`
- `test/pages/home_page_test.dart`
- `test/pages/servizi_page_test.dart`
- `web/`, `assets/`

---

## Task 1: Restore source files from psic_app_calendar

**Files:**
- Restore: entire `lib/` and `test/` trees

- [ ] **Step 1: Copy lib/ and test/ from the identical psic_app_calendar copy**

```bash
cp -r /home/luser/claude_projects/psic_app_calendar/lib /home/luser/claude_projects/psic_app_definitive/
cp -r /home/luser/claude_projects/psic_app_calendar/test /home/luser/claude_projects/psic_app_definitive/
```

- [ ] **Step 2: Verify the key files are present**

```bash
ls /home/luser/claude_projects/psic_app_definitive/lib/pages/
ls /home/luser/claude_projects/psic_app_definitive/lib/database/
ls /home/luser/claude_projects/psic_app_definitive/test/pages/
```

Expected output for pages: `appuntamento_page.dart  home_page.dart  login_page.dart  miei_appuntamenti_page.dart  servizi_page.dart`

---

## Task 2: Delete calendar pages, database, services, and their tests

**Files:**
- Delete: `lib/pages/appuntamento_page.dart`
- Delete: `lib/pages/miei_appuntamenti_page.dart`
- Delete: `lib/pages/login_page.dart`
- Delete: `lib/database/app_database.dart`
- Delete: `lib/database/app_database.g.dart`
- Delete: `lib/database/appuntamenti_dao.dart`
- Delete: `lib/database/appuntamenti_dao.g.dart`
- Delete: `lib/database/profili_dao.dart`
- Delete: `lib/database/profili_dao.g.dart`
- Delete: `lib/services/auth_service.dart`
- Delete: `lib/config/admin_config.dart`
- Delete: `test/pages/appuntamento_page_test.dart`
- Delete: `test/pages/miei_appuntamenti_page_test.dart`
- Delete: `test/services/auth_service_test.dart`
- Delete: `test/pages/login_page_test.dart`

- [ ] **Step 1: Delete all calendar-related source files**

```bash
rm /home/luser/claude_projects/psic_app_definitive/lib/pages/appuntamento_page.dart
rm /home/luser/claude_projects/psic_app_definitive/lib/pages/miei_appuntamenti_page.dart
rm /home/luser/claude_projects/psic_app_definitive/lib/pages/login_page.dart
rm /home/luser/claude_projects/psic_app_definitive/lib/database/app_database.dart
rm /home/luser/claude_projects/psic_app_definitive/lib/database/app_database.g.dart
rm /home/luser/claude_projects/psic_app_definitive/lib/database/appuntamenti_dao.dart
rm /home/luser/claude_projects/psic_app_definitive/lib/database/appuntamenti_dao.g.dart
rm /home/luser/claude_projects/psic_app_definitive/lib/database/profili_dao.dart
rm /home/luser/claude_projects/psic_app_definitive/lib/database/profili_dao.g.dart
rm /home/luser/claude_projects/psic_app_definitive/lib/services/auth_service.dart
rm /home/luser/claude_projects/psic_app_definitive/lib/config/admin_config.dart
```

- [ ] **Step 2: Delete all calendar-related test files**

```bash
rm /home/luser/claude_projects/psic_app_definitive/test/pages/appuntamento_page_test.dart
rm /home/luser/claude_projects/psic_app_definitive/test/pages/miei_appuntamenti_page_test.dart
rm /home/luser/claude_projects/psic_app_definitive/test/services/auth_service_test.dart
rm /home/luser/claude_projects/psic_app_definitive/test/pages/login_page_test.dart
```

- [ ] **Step 3: Verify remaining file structure**

```bash
find /home/luser/claude_projects/psic_app_definitive/lib -name "*.dart" | sort
find /home/luser/claude_projects/psic_app_definitive/test -name "*.dart" | sort
```

Expected `lib/` files:
```
lib/config/contatti.dart
lib/main.dart
lib/pages/home_page.dart
lib/pages/servizi_page.dart
lib/widgets/contact_chip.dart
lib/widgets/nav_bar.dart
```

Expected `test/` files:
```
test/pages/home_page_test.dart
test/pages/servizi_page_test.dart
```

---

## Task 3: Rewrite lib/main.dart — strip calendar code

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Replace lib/main.dart with calendar-free version**

Replace the entire file with:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/home_page.dart';
import 'pages/servizi_page.dart';
import 'widgets/nav_bar.dart';

final _router = GoRouter(
  errorBuilder: (context, state) => Scaffold(
    appBar: const NavBar(),
    body: const Center(
      child: Text('Pagina non trovata', style: TextStyle(fontSize: 24)),
    ),
  ),
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomePage()),
    GoRoute(path: '/servizi', builder: (_, __) => const ServiziPage()),
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00695C)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

---

## Task 4: Rewrite lib/widgets/nav_bar.dart — strip calendar nav

**Files:**
- Modify: `lib/widgets/nav_bar.dart`

- [ ] **Step 1: Replace lib/widgets/nav_bar.dart with calendar-free version**

Replace the entire file with:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  const NavBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF00695C),
      foregroundColor: Colors.white,
      title: InkWell(
        onTap: () => context.go('/'),
        child: const Text(
          'Dr.ssa Maria Bianchi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      actions: [
        _NavLink(label: 'Servizi', path: '/servizi'),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final String path;
  const _NavLink({required this.label, required this.path});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => context.go(path),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}
```

---

## Task 5: Update pubspec.yaml — remove drift packages

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Replace the dependencies and dev_dependencies sections**

The `dependencies` section should become:

```yaml
dependencies:
  flutter:
    sdk: flutter
  go_router: ^17.3.0
  url_launcher: ^6.3.0
  cupertino_icons: ^1.0.8
```

The `dev_dependencies` section should become:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

Packages removed: `drift: ^2.33.0`, `drift_flutter: ^0.3.0`, `sqlite3_flutter_libs: ^0.6.0+eol` from deps; `build_runner: ^2.4.0`, `drift_dev: ^2.33.0` from dev deps.

- [ ] **Step 2: Run flutter pub get to update pubspec.lock**

```bash
cd /home/luser/claude_projects/psic_app_definitive && flutter pub get
```

Expected: resolves packages, no errors. The lock file will be updated to remove drift-related entries.

---

## Task 6: Verify the app compiles and tests pass

**Files:** none changed

- [ ] **Step 1: Run flutter analyze**

```bash
cd /home/luser/claude_projects/psic_app_definitive && flutter analyze
```

Expected: `No issues found!` (or only pre-existing warnings unrelated to calendar code)

- [ ] **Step 2: Run the test suite**

```bash
cd /home/luser/claude_projects/psic_app_definitive && flutter test
```

Expected: all tests pass. Only `home_page_test.dart` and `servizi_page_test.dart` remain; both should pass.

- [ ] **Step 3: Commit**

```bash
cd /home/luser/claude_projects/psic_app_definitive
git add lib/main.dart lib/widgets/nav_bar.dart pubspec.yaml pubspec.lock
git add lib/pages/home_page.dart lib/pages/servizi_page.dart
git add lib/config/contatti.dart lib/widgets/contact_chip.dart
git add test/pages/home_page_test.dart test/pages/servizi_page_test.dart
git rm --cached lib/pages/appuntamento_page.dart lib/pages/miei_appuntamenti_page.dart lib/pages/login_page.dart
git rm --cached lib/database/app_database.dart lib/database/app_database.g.dart
git rm --cached lib/database/appuntamenti_dao.dart lib/database/appuntamenti_dao.g.dart
git rm --cached lib/database/profili_dao.dart lib/database/profili_dao.g.dart
git rm --cached lib/services/auth_service.dart lib/config/admin_config.dart
git rm --cached test/pages/appuntamento_page_test.dart test/pages/miei_appuntamenti_page_test.dart
git rm --cached test/pages/login_page_test.dart test/services/auth_service_test.dart
git commit -m "$(cat <<'EOF'
remove calendar/appointment functionality

Deletes all calendar pages, database layer (Drift), auth service,
admin config, and related tests. Removes drift, drift_flutter,
sqlite3_flutter_libs, build_runner, drift_dev packages.
App now contains only HomePage, ServiziPage, and NavBar.
EOF
)"
```
