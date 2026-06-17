# Design: Recensioni (Reviews) Page

## Overview

Add a `/recensioni` page where site visitors can read and submit star reviews (1–5 stars + description). Reviewers self-register with a username + password; their username becomes the `Name` stored in the review. Each user can submit exactly one review and edit it later. Auth is handled via a custom `reviewer_users` Supabase table with SHA-256 hashed passwords — no dependency on Supabase Auth, portable to any SQL backend.

## Supabase DDL

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

The `UNIQUE` constraint on `reviews."Name"` enforces one review per username at the database level.

## New Config Constants — `lib/config/admin_config.dart`

No new constants needed — all REST calls use existing `supabaseRestUrl` + `supabaseServiceRoleKey` / `supabaseAnonKey`.

## File Map

| Action | Path | Responsibility |
|---|---|---|
| Create | `lib/models/review.dart` | Plain Dart model for `reviews` table |
| Create | `lib/services/review_auth_service.dart` | Register/login/logout against `reviewer_users` |
| Create | `lib/services/reviews_service.dart` | CRUD for `reviews` table |
| Create | `lib/pages/recensioni_page.dart` | Public reviews page + auth dialog + form |
| Modify | `lib/main.dart` | Add globals + `/recensioni` route |
| Modify | `lib/widgets/nav_drawer.dart` | Add "Recensioni" nav entry |

## Data Model — `lib/models/review.dart`

```dart
class Review {
  final int id;
  final String name;
  final String description;
  final DateTime? createdAt;
  final int stars;
}
```

`fromJson` maps: `id`, `Name`, `description`, `created_at`, `stars`.

## Service Layer

### `lib/services/review_auth_service.dart`

Password hashing: SHA-256 via `crypto` package.

| Method | description |
|---|---|
| `ValueNotifier<bool> isLoggedIn` | Drives UI |
| `String? currentUsername` | Set on login, cleared on logout |
| `Future<void> register(username, password)` | Hash password → POST `/rest/v1/reviewer_users` (service-role). Throws on 409 (username taken). |
| `Future<void> login(username, password)` | Hash password → GET `/rest/v1/reviewer_users?username=eq.{u}&password_hash=eq.{h}` (service-role). Empty result → throws "Credenziali errate". |
| `void logout()` | Clears state |

Service-role key is used for both register and login (reading `reviewer_users` with anon key would expose all password hashes — service-role keeps this server-side only).

### `lib/services/reviews_service.dart`

| Method | HTTP | Auth | Notes |
|---|---|---|---|
| `Future<List<Review>> tutti()` | GET `/rest/v1/reviews?select=*&order=created_at.desc` | anon | Public read |
| `Future<void> inserisci({name, description, stars})` | POST `/rest/v1/reviews` | service-role | `Prefer: return=minimal` |
| `Future<void> aggiorna({id, description, stars})` | PATCH `/rest/v1/reviews?id=eq.{id}` | service-role | |
| `Future<Review?> mia(String username)` | GET `/rest/v1/reviews?Name=eq.{username}&select=*` | anon | Returns null if no review |

Both services instantiated as globals in `main.dart`:
```dart
final reviewAuthService = ReviewAuthService();
final reviewsService = ReviewsService();
```

## UI — `lib/pages/recensioni_page.dart`

### Page structure

Uses `NavScaffold`. Contains:
1. Heading "Recensioni" (same style as "I miei articoli")
2. `FutureBuilder<List<Review>>` renders review cards
3. A "Lascia una recensione" / "Modifica la tua recensione" `ElevatedButton` at the bottom

### Review card

`Card` showing:
- Row of 5 star icons (filled `Icons.star`, empty `Icons.star_border`), color `Color(0xFF3B7A1D)`
- Reviewer name (bold) + date (`DateFormat('yyyy-MM-dd')`)
- description text

### Button logic

```
isLoggedIn?
  no  → open _AuthDialog → on success → open _ReviewForm
  yes → mia(username) → open _ReviewForm (pre-filled if review exists)
```

Button label:
- Not logged in: "Lascia una recensione"
- Logged in, no review yet: "Lascia una recensione"
- Logged in, review exists: "Modifica la tua recensione"

### Auth dialog (`_AuthDialog`)

`AlertDialog` with two modes toggled by a `TextButton` ("Non hai un account? Registrati" / "Hai già un account? Accedi"):

**Login mode:** username field + password field + "Accedi" button
**Register mode:** username field + password field + confirm password field + "Registrati" button

Inline error text below the form on failure. On success: closes dialog, calls provided `onSuccess` callback.

### Review form

Responsive: bottom sheet (width < 720px) / full-page route (width ≥ 720px) — same pattern as article form.

Contents:
- Row of 5 tappable `IconButton` stars (tap to set rating)
- Multi-line description `TextField`
- "Salva" `ElevatedButton` with `CircularProgressIndicator` while saving

On save:
- If user has no existing review: call `reviewsService.inserisci`
- If user has an existing review: call `reviewsService.aggiorna`
- On success: close form, refresh review list

## Navigation

`lib/widgets/nav_drawer.dart` — add entry:
```dart
ListTile(
  leading: const Icon(Icons.star_outline, color: Color(0xFF3B7A1D)),
  title: const Text('Recensioni', style: TextStyle(color: Color(0xFF3B7A1D))),
  onTap: () => _go(context, '/recensioni'),
),
```

`lib/main.dart` — add route:
```dart
GoRoute(path: '/recensioni', builder: (_, _) => const RecensioniPage()),
```

## Dependencies

Add to `pubspec.yaml`:
```yaml
crypto: ^3.0.0
```

## Security Notes

- SHA-256 is not a password-specific KDF (not bcrypt/argon2) — acceptable for a low-traffic personal site but not suitable for high-value credentials
- `reviewer_users` is read only via service-role key — password hashes are never exposed to the client
- `reviews` is publicly readable (anon key) — no sensitive data

## Testing

- `Review.fromJson` unit tests (all fields, nullable `created_at`)
- `RecensioniPage` widget tests: page renders, button visible, auth dialog opens
- `ReviewAuthService` unit tests: login success, login wrong password, register duplicate username
