# Edge Function Proxy Migration Design

**Date:** 2026-07-08  
**Status:** Approved  
**Scope:** Migrate Flutter Web + Supabase app from direct REST API calls to a full Edge Function proxy, eliminating all client-side keys and protecting sensitive personal data stored in the `psyc_app` schema.

---

## Background

The app stores sensitive personal data including tessere sanitarie (national health IDs), patient contact information, and therapy-related reviews in Supabase tables under the `psyc_app` schema. The current architecture exposes both the Supabase anon key and service_role key in the Flutter Web bundle, and makes direct REST calls to the Supabase API. This creates unacceptable GDPR risk — particularly under Article 9 (special category health data).

---

## Immediate Pre-Implementation Actions

These must be completed **before any code changes** to close existing exposure:

1. **Rotate `service_role` key** — in Supabase dashboard → Project Settings → API. The old key (currently committed to git history) becomes immediately invalid.
2. **Rotate DB password** — in Supabase dashboard → Database → Database password.
3. **Enable MFA** on the Supabase account.
4. **Restrict DB allowed IPs** — in Supabase dashboard → Database → Connection Pooling → Allowed IPs. Set to trusted IPs only (e.g. home/office IP). This prevents direct PostgreSQL connections from arbitrary locations.

---

## Architecture

The Flutter client becomes a **keyless thin layer**. It holds only the Supabase project URL, which is needed by the Supabase Auth SDK and is not a secret. All data operations go through Edge Functions. The `service_role` key lives exclusively as a Supabase project secret.

```
Flutter Client (no keys — URL only)
    │
    ├── Supabase Auth SDK (URL only) ──► Supabase Auth  [admin login/logout/session]
    │
    └── HTTP calls (+ JWT for admin routes)
            │
            ▼
    Supabase Edge Functions (Deno/TypeScript)
        ├── Origin header check (ALLOWED_ORIGIN env var)
        ├── JWT verification for admin routes
        ├── Input validation + length limits
        └── Parameterized queries via service_role key
                │
                ├──► psyc_app schema (Postgres)
                ├──► Supabase Storage (private buckets)
                └──► Resend API (email)
```

**Note on origin validation:** The `Origin` header check is a browser-level deterrent (prevents other websites from calling your functions via browser JS). It is not a firewall — non-browser clients can spoof it. The JWT + RLS + private storage combination provides the actual security boundary.

**Future optional layer — Cloudflare:**  
Cloudflare can be placed in front of the Edge Functions as a WAF/rate-limiting layer with zero code changes. It would make origin validation genuinely enforceable at the network level and add DDoS protection. This is a routing change only (DNS → Cloudflare → Supabase). Free tier is sufficient for this use case.

---

## Environment Variables

All secrets live as Supabase project secrets (dashboard → Edge Functions → Secrets). None are in the repository.

| Variable | Purpose | Status |
|---|---|---|
| `SUPABASE_URL` | Supabase project URL | Already set |
| `SUPABASE_SERVICE_ROLE_KEY` | DB access (rotated pre-implementation) | Rotate then confirm |
| `ALLOWED_ORIGIN` | Permitted request origin, e.g. `https://riccardo-cpt.github.io` | New — parameterized for future domain changes |
| `RESEND_API_KEY` | Transactional email | Already set |
| `RESEND_FROM_EMAIL` | Sender address | Already set |
| `ADMIN_EMAIL` | Admin notification recipient | Already set |
| `SITE_URL` | App base URL for magic links | Already set |

---

## Edge Functions

9 functions total. 4 existing functions are refactored; 5 are new.

### Shared behaviour (all functions)

- Check `Origin` header against `ALLOWED_ORIGIN` → `403` on mismatch (no body)
- Validate required fields and enforce length limits before any DB operation
- Never echo sensitive data back to the client
- Log errors server-side only; return generic `500` to client on DB/external service failures
- Return only the minimum fields needed by the client

### Public functions (origin check only, no JWT)

| Function | Method | Replaces | Description |
|---|---|---|---|
| `get-articles` | GET | `GET /rest/v1/articoli` | Returns all articles, or single article if `?id=` param provided |
| `get-approved-reviews` | GET | `GET /rest/v1/reviews?approved=eq.true` | Returns approved reviews only |
| `send-contact-request` | POST | existing | Validates form, uploads attachment to private bucket, emails admin via Resend, inserts record into `psyc_app.contact_requests`. Attachment URL is never returned to client. |
| `send-review-magic-link` | POST | existing | Generates one-time token, stores in `psyc_app.email_approval`, sends magic link email |
| `verify-review-token` | POST | existing | Validates token, enforces 1-hour expiry, deletes on first use |
| `submit-review` | POST | existing | Inserts verified review into `psyc_app.reviews` with `approved=false` |

### Admin functions (origin check + JWT verification)

JWT is verified via `supabase.auth.getUser(jwt)` on every call. Invalid or expired JWT → `401`.

| Function | Method | Replaces | Description |
|---|---|---|---|
| `admin-articles` | POST | direct REST CRUD + StorageService | Create, update, delete articles; handles image upload/delete to `articoli-images` bucket server-side |
| `admin-reviews` | POST | direct REST CRUD | Read all reviews, approve review, delete review |
| `admin-contact-requests` | POST | none (new) | Read contact requests — returns form fields only, never attachment URLs |

---

## Flutter Client Changes

### `lib/config/admin_config.dart` — after migration

```dart
class AdminConfig {
  static const String supabaseUrl = 'https://snsvamcecgizhecvtpwk.supabase.co';
  static const String functionsUrl = '$supabaseUrl/functions/v1';
}
```

All keys and the hardcoded password are removed.

### Authentication — `BlogAuthService`

Rewritten to use the Supabase Auth SDK:

- `signIn(email, password)` → calls `supabase.auth.signInWithPassword()`
- Returns a JWT stored and managed by the SDK (survives page refresh via session restore)
- `signOut()` → calls `supabase.auth.signOut()`
- Admin UI reads `supabase.auth.currentSession` to determine auth state
- JWT is attached to admin Edge Function calls as `Authorization: Bearer <jwt>`

JWT lifecycle:
- Expires after 1 hour (Supabase Auth default, configurable)
- Refresh tokens rotate on each use
- Sessions can be invalidated immediately from Supabase dashboard
- JWT is signed with `JWT_SECRET` held only inside Supabase — cannot be forged externally

### Service layer changes

| Service | Change |
|---|---|
| `ArticoliService` | HTTP calls point to `get-articles` and `admin-articles` Edge Functions |
| `ReviewsService` | Points to `get-approved-reviews` and `admin-reviews` |
| `StorageService` | **Deleted** — upload/delete handled server-side inside `admin-articles` |
| `BlogAuthService` | **Rewritten** — Supabase Auth SDK replaces client-side password check |
| `AdminContactService` | **New** — calls `admin-contact-requests` |

### `pubspec.yaml` dependency

Add `supabase_flutter` package. The `http` package is retained for Edge Function calls.

---

## Database Hardening

### Row Level Security

RLS is enabled on all `psyc_app` tables with **default-deny** — no access unless explicitly granted.

| Table | Anon policy | Authenticated admin policy |
|---|---|---|
| `articoli` | `SELECT` only | Full CRUD |
| `reviews` | `SELECT` where `approved = true` | Full CRUD |
| `reviewer_users` | No access | No access (Edge Function service_role only) |
| `email_approval` | No access | No access (Edge Function service_role only) |
| `contact_requests` | No access | No access (Edge Function service_role only) |

### Storage

- `articoli-images` — remains accessible for public image display; write/delete restricted to service_role
- `contact-attachments` — **private bucket**; no public URLs; attachment emailed directly, never retrieved by client

### Query safety

All Edge Functions use the Supabase JS client with parameterized queries — no string concatenation in SQL. This prevents SQL injection at the code level in addition to RLS at the policy level.

---

## Error Handling

| Condition | Response | Detail logged |
|---|---|---|
| Origin mismatch | `403` (no body) | Server-side only |
| Missing/invalid JWT (admin routes) | `401` | Server-side only |
| Validation failure | `400` with generic message | Server-side only |
| DB error | `500` with generic message | Server-side only |
| External service error (Resend) | `500` with generic message | Server-side only |

Flutter client shows generic user-facing error messages for all non-2xx responses. Raw error details are never surfaced in the UI.

---

## What This Does Not Protect Against

- **Stolen Supabase dashboard credentials** — mitigated by MFA (see pre-implementation actions)
- **Stolen JWT from browser memory** — mitigated by 1-hour expiry and session invalidation
- **Spoofed Origin header from non-browser clients** — origin check is a deterrent only; JWT + RLS is the real boundary
- **Network-level DDoS** — mitigated in future by optional Cloudflare layer

---

## Out of Scope

- Cloudflare WAF integration (documented as future optional routing change)
- Patient portal or multi-user auth (single admin only)
- Audit logging of admin actions (not required at this stage)
