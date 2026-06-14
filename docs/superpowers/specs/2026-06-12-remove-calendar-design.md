# Remove Calendar Functionality — Design

**Date:** 2026-06-12  
**Goal:** Strip all appointment/calendar code from `psic_app_definitive`, leaving a clean Flutter web app with only `HomePage`, `ServiziPage`, and `NavBar`.

---

## Context

The calendar feature was built on top of an electrician app conversion. It introduced a Drift (SQLite/WASM) database layer, a login page, an admin config, and two calendar pages. Every one of these additions exists solely to support appointment booking — none of them should survive the removal.

The `lib/` source files are missing from disk (git objects corrupted by Windows Zone.Identifier files), so they must be restored from `psic_app_calendar/` (an identical copy) before editing.

---

## Files Deleted (13)

| File | Reason |
|---|---|
| `lib/pages/appuntamento_page.dart` | Calendar booking form |
| `lib/pages/miei_appuntamenti_page.dart` | Calendar grid view |
| `lib/pages/login_page.dart` | Only gates calendar access |
| `lib/database/app_database.dart` | Drift schema (Profili + Appuntamenti) |
| `lib/database/app_database.g.dart` | Generated from above |
| `lib/database/appuntamenti_dao.dart` | Appointment queries |
| `lib/database/appuntamenti_dao.g.dart` | Generated from above |
| `lib/database/profili_dao.dart` | Profile queries (only used for login/calendar) |
| `lib/database/profili_dao.g.dart` | Generated from above |
| `lib/services/auth_service.dart` | Calendar access control only |
| `lib/config/admin_config.dart` | Hardcoded admin credentials for calendar |
| `test/pages/appuntamento_page_test.dart` | Tests for deleted page |
| `test/pages/miei_appuntamenti_page_test.dart` | Tests for deleted page |

---

## Files Modified (3)

### `pubspec.yaml`
Remove from `dependencies`: `drift`, `drift_flutter`, `sqlite3_flutter_libs`  
Remove from `dev_dependencies`: `build_runner`, `drift_dev`

### `lib/main.dart`
- Remove imports: `miei_appuntamenti_page.dart`, `appuntamento_page.dart`, `login_page.dart`, `auth_service.dart`, `app_database.dart`
- Remove globals: `authService`, `appDatabase`
- Remove router redirect guard (the whole `redirect:` block)
- Remove routes: `/appuntamento`, `/appuntamenti`, `/login`

### `lib/widgets/nav_bar.dart`
- Remove import of `../main.dart` (used only for `authService`)
- Remove `ValueListenableBuilder` "Prenota ora" link
- Remove `_NavLink` for "Sezione appuntamenti"
- Remove `ValueListenableBuilder` logout `IconButton`

---

## Files Unchanged

Everything else stays exactly as-is:
- `lib/pages/home_page.dart`
- `lib/pages/servizi_page.dart`
- `lib/config/contatti.dart`
- `lib/widgets/contact_chip.dart`
- `test/pages/home_page_test.dart`
- `test/pages/login_page_test.dart` — kept (tests the login page independently; no calendar dependency)
- `test/pages/servizi_page_test.dart`
- `test/services/auth_service_test.dart` — will be deleted (tests auth_service which is being removed)
- All web/, assets/ files

---

## Packages Remaining After Removal

```yaml
dependencies:
  flutter: sdk: flutter
  go_router: ^17.3.0
  url_launcher: ^6.3.0
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test: sdk: flutter
  flutter_lints: ^6.0.0
```

No `drift` packages remain.

---

## Result

A clean, lightweight Flutter web app:
- `HomePage` — psychologist landing page
- `ServiziPage` — therapy services listing
- `NavBar` — "Servizi" link only (no login/booking nav items)
- No database, no authentication, no SQLite/WASM
