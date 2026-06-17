# Review Submission Redesign — Spec

## Goal

Replace the current login/register + mailto-notification flow with a password-free, magic-link-verified review submission process. Users fill a public form, verify their email via a one-time link, then submit their review. The admin receives an email notification and approves/rejects from the existing admin console.

---

## Database Schema

### `reviewer_users`
```sql
create table reviewer_users (
  id bigint generated always as identity,
  username text unique not null,
  name text not null,
  surname text not null,
  email text not null,
  created_at timestamptz default now(),
  primary key (email)
);
```

### `reviews`
```sql
create table reviews (
  id bigint generated always as identity,
  email text unique not null references reviewer_users (email),
  username text not null,
  title text not null,
  description text not null,
  created_at timestamptz default now(),
  stars int not null check (stars >= 1 and stars <= 5),
  approved boolean default false
);

CREATE POLICY "public read approved reviews"
ON reviews
FOR SELECT
USING (approved = true);
```

### `email_approval`
```sql
CREATE TABLE email_approval (
  id bigint generated always as identity,
  email text not null,
  token text,
  expires_at timestamptz
);
```
Reused for magic-link tokens (replaces `password_resets`). One row per pending verification; old token deleted before new one is inserted.

### Migrations from old schema
- `reviewer_users`: drop `password_hash` column; `email` becomes primary key.
- `reviews`: drop old `username` FK; add `email` (unique FK → `reviewer_users.email`); add `username` (denormalized display name).
- Drop `password_resets` table.

---

## Data Flow

```
User                Flutter App              Edge Functions           Supabase DB
 │  click button         │                        │                       │
 │──────────────────────▶│                        │                       │
 │  step 1 form:         │                        │                       │
 │  email, username,     │                        │                       │
 │  name, surname        │                        │                       │
 │──────────────────────▶│                        │                       │
 │                       │── send-review-magic-link ──────────────────▶  │
 │                       │                        │  upsert reviewer_users│
 │                       │                        │  (email as PK)        │
 │                       │                        │  store token in       │
 │                       │                        │  email_approval       │
 │                       │                        │── Resend → user email │
 │  "Check your email"   │                        │                       │
 │◀──────────────────────│                        │                       │
 │  click magic link     │                        │                       │
 │  (?token=xxx)         │                        │                       │
 │──────────────────────▶│── verify-review-token ──────────────────────▶ │
 │                       │                        │  check expiry         │
 │                       │                        │  delete token         │
 │                       │                        │  return email+username│
 │  review form unlocks  │                        │                       │
 │  stars, title, desc   │                        │                       │
 │──────────────────────▶│── submit-review ─────────────────────────────▶│
 │                       │                        │  insert reviews row   │
 │                       │                        │── Resend → admin email│
 │  "Grazie!"            │                        │                       │
 │◀──────────────────────│                        │                       │
```

---

## Edge Functions

### `send-review-magic-link`
- **Input**: `{ email, username, name, surname }` — all mandatory
- Upserts `reviewer_users` by email (creates or updates username/name/surname)
- Deletes any existing token for this email in `email_approval`
- Generates UUID token, inserts into `email_approval` with 1-hour expiry
- Sends email via Resend to user with link `{SITE_URL}/#/recensioni?token=xxx`
- Always returns `{ ok: true }` (avoid email enumeration)
- Env vars: `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `RESEND_API_KEY`, `SITE_URL`, `RESEND_FROM_EMAIL`, `ADMIN_EMAIL`

### `verify-review-token`
- **Input**: `{ token }`
- Looks up token in `email_approval`, checks not expired
- Deletes the token (one-time use)
- Returns `{ email, username, name }` on success, `{ error: "..." }` on invalid/expired

### `submit-review`
- **Input**: `{ email, title, description, stars }` — email from verified token held in Flutter state
- Inserts row into `reviews` (`email`, `username` looked up from `reviewer_users`, `title`, `description`, `stars`, `approved: false`)
- Sends email via Resend to admin with full details (name, surname, email, username, review content)
- Returns `{ ok: true }`
- On DB conflict (email already has a review): returns `{ error: "duplicate" }`

---

## Flutter App Changes

### `review_auth_service.dart` — full replacement
Remove: login, register, logout, password hashing, `isLoggedIn` ValueNotifier.
Add:
- `sendMagicLink(email, username, name, surname)` → calls `send-review-magic-link` edge function
- `verifyToken(token)` → calls `verify-review-token`, stores `currentEmail`, `currentUsername`, `currentName` in memory
- `isVerified` ValueNotifier (replaces `isLoggedIn`)

### `reviews_service.dart` — partial changes
- `inserisci()`: replaced by call to `submit-review` edge function (no direct REST insert, no `_notificaAdmin`)
- Remove `mia()` method (no per-user editing)
- Remove `aggiorna()` method (no editing after submission)
- Keep: `tutti()`, `tuttiAdmin()`, `approva()`, `cancella()`

### `recensioni_page.dart` — significant changes
- Remove `_AuthDialog` (login/register dialog)
- Remove logout button
- Replace `_onButtonTap` with two-step flow:
  - **Step 1**: identity form (email, username, name, surname) → "Invia link di conferma"
  - **Step 2**: unlocked after token verification — review form (stars, title, description) → "Invia recensione"
- Token is read from URL on page load; if present, `verifyToken()` is called automatically

### `main.dart` — URL token handling
- On app init, parse URL query params for `token`
- If found, call `reviewAuthService.verifyToken(token)` before rendering
- Navigate to recensioni page with form pre-unlocked

### Files to delete
- `lib/pages/reset_password_page.dart`
- `lib/services/password_reset_service.dart`
- `supabase/functions/reset-password/` (entire folder)

---

## Error Handling

| Scenario | Behavior |
|---|---|
| Expired/invalid token | Flutter shows "Link non valido o scaduto. Richiedi un nuovo link." + back to step 1 |
| Second magic link request | Old token deleted, new one issued |
| Duplicate review (same email) | Flutter shows "Hai già inviato una recensione. Puoi contattarci per modificarla." |
| Edge function 500 | Flutter shows SnackBar "Errore: riprova più tardi." |
| Admin email send failure | Review is still saved; admin can see it in the console |

---

## What Does NOT Change

- Admin console login and approval/rejection flow (`articoli_admin_page.dart`, `blog_auth_service.dart`)
- `Review` model class (minor: `username` now comes from `reviews` directly, not joined from `reviewer_users`)
- `tutti()` and admin review listing/approval/deletion in `reviews_service.dart`
- RLS policy structure — anon key safe for approved-only public reads
- Resend as email provider
