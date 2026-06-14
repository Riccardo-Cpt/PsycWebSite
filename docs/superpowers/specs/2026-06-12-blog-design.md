# Blog "I miei articoli" — Design

**Date:** 2026-06-12

---

## Goal

Add a blog page called "I miei articoli" to the Flutter psychologist web app. The admin can create, edit, and delete articles through a hidden authenticated panel. Public users can only read. No external backend — articles live in a local Drift SQLite database in the browser (same device, admin only).

---

## Context

This feature is designed alongside the calendar-removal refactor (`docs/superpowers/specs/2026-06-12-remove-calendar-design.md`). The calendar removal strips Drift entirely; this feature re-introduces Drift scoped only to the blog. The final app has no appointment or profile tables — only `Articoli`.

---

## Storage

**Drift (SQLite/WASM)** via `driftDatabase` with `DriftWebOptions` (sqlite3.wasm + drift_worker.js, already present in `web/`).

One table:

```
Articoli
  id                INTEGER PRIMARY KEY AUTOINCREMENT
  titolo            TEXT NOT NULL
  corpo             TEXT NOT NULL
  dataPubblicazione TEXT NOT NULL     -- YYYY-MM-DD
  immagine          BLOB nullable     -- raw image bytes (Uint8List)
  immagineMime      TEXT nullable     -- e.g. 'image/jpeg', needed to render as data: URI
```

`immagine` and `immagineMime` are the only nullable fields; both are always set or both null. Cover images are uploaded by the admin via a file picker and stored as binary blobs in SQLite. No external storage service.

Schema version: 1 (fresh database, no migrations needed).

---

## Routes

| Route | Access | Purpose |
|---|---|---|
| `/articoli` | Public (no auth) | Read-only article list |
| `/articoli/admin` | Hidden, password-gated | CRUD admin panel |

`/articoli/admin` is not linked from any public UI element. It is reachable only by typing the URL directly.

GoRouter redirect: if `/articoli/admin` is accessed and `BlogAuthService.isAdmin` is false, stay on `/articoli/admin` but show the password form (do not redirect away — the page itself handles the gate).

---

## Authentication

- Password hardcoded in `lib/config/admin_config.dart` (same constant file used previously for the calendar admin).
- `BlogAuthService` holds a `ValueNotifier<bool> isAdmin`. `login(password)` sets it to true if password matches; `logout()` sets it to false.
- Session is in-memory only. Closing or refreshing the tab resets `isAdmin` to false — no persistent token, no cookie.
- The admin panel widget watches `isAdmin` via `ValueListenableBuilder`. When false it shows the password form; when true it shows the CRUD panel.

---

## Public Page `/articoli`

### Layout

Full-page `Scaffold` with `NavBar`. Body is a `SingleChildScrollView` with a `ScrollController`.

**Header row:** "I miei articoli" title on the left, a burger icon button (`Icons.menu`) on the right that opens the index `Drawer`.

**Article list:** Articles sorted by `dataPubblicazione` descending (newest first). The most recent article is expanded by default; all others start collapsed. Each article is wrapped in a `Card` with a `GlobalKey` for scroll-to anchoring.

**Responsive breakpoint: 720px** (same approach as `_HeroSection` in `home_page.dart`):
- **Narrow (< 720px):** cover image full-width above title, date, body — stacked `Column`
- **Wide (≥ 720px):** cover image fixed 280px on left, title + date + body on right — `Row` with `IntrinsicHeight`

**Expanded article anatomy:**
```
[cover image]   Titolo articolo          ← wide: side-by-side; narrow: stacked
                12 Gennaio 2026
                Lorem ipsum corpo...
```

If no image, the image slot is omitted entirely (not a placeholder box).

**Collapsed article:** Shows only the title and date in a single row with a leading expand icon (`Icons.expand_more`). Tapping expands it in place.

### Index Drawer

Opens from the burger icon. Lists all article titles (newest first) as `ListTile` widgets. Tapping a title closes the drawer and scrolls to that article's `GlobalKey` position using `Scrollable.ensureVisible`.

---

## Admin Panel `/articoli/admin`

### Password Gate

Centered `Card` (max width 400px), same visual style as the old `LoginPage`:
- Password `TextField` (obscured)
- "Accedi" `ElevatedButton` (teal)
- Wrong password shows a `SnackBar` with "Password errata"

### CRUD Panel (shown after login)

After authentication, replaces the password gate:

- Page title: "Pannello Admin — I miei articoli"
- "Nuovo articolo" button (top-right)
- List of existing articles: each row shows title, date, edit icon (`Icons.edit`), delete icon (`Icons.delete`)
- Tapping delete shows a confirmation `AlertDialog` before calling `articoliDao.cancella(id)`

### Article Edit Form

Shown as a `showModalBottomSheet` on narrow screens, and a full-page push route (`/articoli/admin/edit`) on wide screens (breakpoint 720px).

Fields:
- **Titolo** — required `TextField`
- **Data pubblicazione** — required, opens `showDatePicker`, displays formatted date
- **Corpo** — required multiline `TextField` (minLines: 5)
- **Immagine** — optional; "Seleziona immagine" button using `image_picker` (web: gallery only); shows thumbnail preview if selected; "Rimuovi immagine" button if one is set

Submit button: "Salva". Validates all required fields before saving. On success, pops back to the admin list.

---

## Services Page `/servizi` — Changes

`lib/pages/servizi_page.dart` is modified as part of this feature:

- **Remove** the `ElevatedButton.icon` ("Contattami") from `_ServizioCard` and the `_mostraContatti` top-level function (and its dialog) entirely.
- **Add** a `_ContattiSection` widget at the bottom of the page (below the therapy cards `Wrap`), consisting of a single `ExpansionTile` with label "Contattami" and leading `Icons.contact_phone_outlined`. When expanded, shows two `ListTile` rows inline:
  - Phone: `Icons.phone` leading, `Contatti.telefono` subtitle, `chiamaTelefono` on tap
  - Email: `Icons.email_outlined` leading, `Contatti.email` subtitle, `inviaEmail` on tap
- Collapsed by default (`initiallyExpanded: false`).
- `test/pages/servizi_page_test.dart` updated: remove test for "Contattami" button per card; add test that `ExpansionTile` with "Contattami" label is present.

---

## File Map

### New files
- `lib/pages/articoli_page.dart` — public read-only view (`ArticoliPage`)
- `lib/pages/articoli_admin_page.dart` — password gate + CRUD panel + edit form (`ArticoliAdminPage`)
- `lib/database/app_database.dart` — Drift schema (`Articoli` table only, `AppDatabase`)
- `lib/database/articoli_dao.dart` — DAO: `tutti()`, `inserisci()`, `aggiorna()`, `cancella()`
- `lib/database/app_database.g.dart` — generated (do not edit)
- `lib/database/articoli_dao.g.dart` — generated (do not edit)
- `lib/services/blog_auth_service.dart` — `BlogAuthService` (`ValueNotifier<bool>`, `login`, `logout`)
- `lib/config/admin_config.dart` — `AdminConfig.password` constant

### Modified files
- `pubspec.yaml` — re-add `drift`, `drift_flutter`, `sqlite3_flutter_libs`; re-add `build_runner`, `drift_dev`; add `image_picker`
- `lib/main.dart` — add `appDatabase` global, add `/articoli` and `/articoli/admin` routes
- `lib/widgets/nav_bar.dart` — add "I miei articoli" nav link pointing to `/articoli`
- `lib/pages/servizi_page.dart` — remove per-card "Contattami" button and dialog; add `_ContattiSection` `ExpansionTile` at page bottom
- `test/pages/servizi_page_test.dart` — update tests to match new contact UI


---

## Packages

```yaml
dependencies:
  drift: ^2.33.0
  drift_flutter: ^0.3.0
  sqlite3_flutter_libs: ^0.6.0+eol
  image_picker: ^1.1.0

dev_dependencies:
  build_runner: ^2.4.0
  drift_dev: ^2.33.0
```

---

## Testing

- `test/pages/articoli_page_test.dart` — renders without error; shows "I miei articoli" heading; shows burger menu icon
- `test/pages/articoli_admin_page_test.dart` — shows password form by default; wrong password shows snackbar; correct password reveals admin panel heading
- `test/services/blog_auth_service_test.dart` — isAdmin starts false; correct password sets true; logout resets to false; wrong password keeps false
