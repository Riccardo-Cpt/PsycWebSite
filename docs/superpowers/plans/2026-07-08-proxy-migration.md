# Edge Function Proxy Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate the Flutter Web + Supabase app from direct REST API calls (with exposed keys) to a full Edge Function proxy where the client holds no keys and all sensitive data in the `psyc_app` schema is unreachable from the public API.

**Architecture:** The Flutter client is stripped of all keys and holds only the Supabase project URL. Every data operation routes through one of 9 Deno Edge Functions. Admin operations additionally require a Supabase Auth JWT. The service_role key never leaves server-side secrets.

**Tech Stack:** Flutter Web (Dart), Supabase Edge Functions (Deno/TypeScript), Supabase Auth, Supabase Storage, Supabase PostgreSQL (`psyc_app` schema), Resend API, `supabase_flutter` Dart package, `http` Dart package.

## Global Constraints

- All Edge Functions target `https://deno.land/std@0.168.0/http/server.ts` and `https://esm.sh/@supabase/supabase-js@2` (match existing functions)
- All Edge Functions must check `Origin` header against `ALLOWED_ORIGIN` env var on every non-OPTIONS request; return `403` with empty body on mismatch
- Admin Edge Functions must verify JWT via `supabase.auth.getUser(jwt)` before any DB operation; return `401` on failure
- All tables are in the `psyc_app` schema — queries must use `.schema('psyc_app')` on the Supabase client or explicit schema-qualified table names
- Never return raw error details to the client — log server-side, return generic messages
- No attachment URL or file path is ever stored in `contact_requests`
- Attachment must be deleted from storage regardless of email send outcome (Article 9)
- Flutter SDK: `>=3.44.0`, Dart `^3.12.1`
- `supabase_flutter` version: `^2.0.0`

---

## Pre-Implementation Checklist (manual steps — do before touching code)

- [ ] Rotate `service_role` key: Supabase dashboard → Project Settings → API → Reveal → Regenerate
- [ ] Rotate DB password: Supabase dashboard → Database → Database Settings → Reset database password
- [ ] Enable MFA on Supabase account: supabase.com → Account → Security
- [ ] Restrict DB allowed IPs: Supabase dashboard → Database → Connection Pooling → Allowed IPs → add your IP, remove 0.0.0.0/0
- [ ] Create admin user in Supabase Auth: Supabase dashboard → Authentication → Users → Invite user (use a strong password, not admin123)
- [ ] Set `ALLOWED_ORIGIN` secret: Supabase dashboard → Edge Functions → Secrets → add `ALLOWED_ORIGIN=https://riccardo-cpt.github.io`

---

## File Map

**Created:**
- `supabase/functions/_shared/cors.ts` — shared CORS + origin check helper
- `supabase/functions/_shared/auth.ts` — shared JWT verification helper
- `supabase/functions/_shared/client.ts` — shared Supabase service_role client factory
- `supabase/functions/get-articles/index.ts` — new public function
- `supabase/functions/get-approved-reviews/index.ts` — new public function
- `supabase/functions/admin-articles/index.ts` — new admin function
- `supabase/functions/admin-reviews/index.ts` — new admin function
- `supabase/functions/admin-contact-requests/index.ts` — new admin function
- `supabase/migrations/YYYYMMDD_rls_psyc_app.sql` — RLS policies migration
- `lib/services/admin_contact_service.dart` — new Flutter service

**Modified:**
- `supabase/functions/send-contact-request/index.ts` — Article 9 compliant rewrite
- `supabase/functions/send-review-magic-link/index.ts` — add origin check, schema fix
- `supabase/functions/verify-review-token/index.ts` — add origin check, schema fix
- `supabase/functions/submit-review/index.ts` — add origin check, schema fix
- `lib/config/admin_config.dart` — strip all keys, keep URL + functionsUrl only
- `lib/services/blog_auth_service.dart` — rewrite with Supabase Auth SDK
- `lib/services/articoli_service.dart` — point to Edge Functions, remove keys
- `lib/services/reviews_service.dart` — point to Edge Functions, remove keys
- `lib/services/contact_service.dart` — remove anon key from headers
- `lib/services/review_auth_service.dart` — remove anon key from headers
- `lib/pages/articoli_admin_page.dart` — wire new auth, add logout, use admin services
- `lib/main.dart` — initialize Supabase SDK, remove storageService
- `pubspec.yaml` — add `supabase_flutter: ^2.0.0`

**Deleted:**
- `lib/services/storage_service.dart` — storage now handled server-side

---

## Task 1: Shared Edge Function helpers

**Files:**
- Create: `supabase/functions/_shared/cors.ts`
- Create: `supabase/functions/_shared/auth.ts`
- Create: `supabase/functions/_shared/client.ts`

**Interfaces:**
- Produces:
  - `corsHeaders(origin: string | null): Record<string, string>` — returns CORS headers with exact origin or `*` as fallback
  - `checkOrigin(req: Request): Response | null` — returns `403` Response if origin invalid, `null` if ok
  - `optionsResponse(req: Request): Response` — handles OPTIONS preflight
  - `verifyAdmin(req: Request, supabase: SupabaseClient): Promise<Response | null>` — returns `401` Response if JWT missing/invalid, `null` if ok
  - `makeServiceClient(): SupabaseClient` — creates Supabase client with service_role key, schema set to `psyc_app`

- [ ] **Step 1: Create `_shared/cors.ts`**

```typescript
// supabase/functions/_shared/cors.ts
const ALLOWED_ORIGIN = Deno.env.get('ALLOWED_ORIGIN') ?? '';

export function corsHeaders(origin: string | null): Record<string, string> {
  return {
    'Access-Control-Allow-Origin': origin === ALLOWED_ORIGIN ? ALLOWED_ORIGIN : '',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  };
}

export function checkOrigin(req: Request): Response | null {
  const origin = req.headers.get('origin');
  if (origin !== ALLOWED_ORIGIN) {
    return new Response(null, { status: 403 });
  }
  return null;
}

export function optionsResponse(req: Request): Response {
  const origin = req.headers.get('origin');
  return new Response('ok', { headers: corsHeaders(origin) });
}
```

- [ ] **Step 2: Create `_shared/auth.ts`**

```typescript
// supabase/functions/_shared/auth.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

export async function verifyAdmin(req: Request): Promise<Response | null> {
  const authHeader = req.headers.get('Authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return new Response(null, { status: 401 });
  }
  const jwt = authHeader.replace('Bearer ', '');
  const client = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
  const { data, error } = await client.auth.getUser(jwt);
  if (error || !data.user) {
    return new Response(null, { status: 401 });
  }
  return null;
}
```

- [ ] **Step 3: Create `_shared/client.ts`**

```typescript
// supabase/functions/_shared/client.ts
import { createClient, SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

export function makeServiceClient(): SupabaseClient {
  return createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    db: { schema: 'psyc_app' },
  });
}
```

- [ ] **Step 4: Commit**

```bash
git add supabase/functions/_shared/
git commit -m "feat: add shared Edge Function helpers (cors, auth, client)"
```

---

## Task 2: RLS migration

**Files:**
- Create: `supabase/migrations/20260708000000_rls_psyc_app.sql`

**Interfaces:**
- Produces: all `psyc_app` tables protected with default-deny RLS

- [ ] **Step 1: Create migration file**

```sql
-- supabase/migrations/20260708000000_rls_psyc_app.sql

-- Enable RLS on all psyc_app tables
ALTER TABLE psyc_app.articoli ENABLE ROW LEVEL SECURITY;
ALTER TABLE psyc_app.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE psyc_app.reviewer_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE psyc_app.email_approval ENABLE ROW LEVEL SECURITY;
ALTER TABLE psyc_app.contact_requests ENABLE ROW LEVEL SECURITY;

-- Default deny: no existing policies = no access for anon/authenticated roles
-- Explicit policies for service_role are not needed (service_role bypasses RLS)

-- articoli: public can read, nothing else
CREATE POLICY "articoli_public_select"
  ON psyc_app.articoli FOR SELECT
  TO anon
  USING (true);

-- reviews: public can read approved only, nothing else
CREATE POLICY "reviews_public_select"
  ON psyc_app.reviews FOR SELECT
  TO anon
  USING (approved = true);

-- All other tables: no anon access at all (no policy = deny)
-- reviewer_users, email_approval, contact_requests: service_role only (via Edge Functions)
```

- [ ] **Step 2: Apply migration via Supabase dashboard**

Go to Supabase dashboard → SQL Editor → paste the migration content → Run.

Verify: in Table Editor, check that RLS is enabled on each table (padlock icon shown).

- [ ] **Step 3: Commit**

```bash
git add supabase/migrations/20260708000000_rls_psyc_app.sql
git commit -m "feat: enable RLS default-deny on all psyc_app tables"
```

---

## Task 3: Refactor existing Edge Functions (origin check + schema fix)

**Files:**
- Modify: `supabase/functions/send-review-magic-link/index.ts`
- Modify: `supabase/functions/verify-review-token/index.ts`
- Modify: `supabase/functions/submit-review/index.ts`

**Interfaces:**
- Consumes: `checkOrigin`, `optionsResponse`, `corsHeaders` from `../_shared/cors.ts`; `makeServiceClient` from `../_shared/client.ts`

- [ ] **Step 1: Rewrite `send-review-magic-link/index.ts`**

```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { checkOrigin, optionsResponse, corsHeaders } from '../_shared/cors.ts';
import { makeServiceClient } from '../_shared/client.ts';

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')!;
const SITE_URL = Deno.env.get('SITE_URL')!;
const RESEND_FROM_EMAIL = Deno.env.get('RESEND_FROM_EMAIL')!;

serve(async (req) => {
  if (req.method === 'OPTIONS') return optionsResponse(req);
  const originError = checkOrigin(req);
  if (originError) return originError;

  const origin = req.headers.get('origin');
  const headers = { ...corsHeaders(origin), 'Content-Type': 'application/json' };

  try {
    const { email, username, name, surname } = await req.json();
    if (!email || !username || !name || !surname ||
        email.length > 254 || username.length > 50 ||
        name.length > 100 || surname.length > 100) {
      return new Response(JSON.stringify({ error: 'Dati non validi' }), { status: 400, headers });
    }

    const supabase = makeServiceClient();

    const { data: existing } = await supabase
      .from('reviews')
      .select('id')
      .eq('email', email)
      .limit(1);
    if (existing && existing.length > 0) {
      return new Response(JSON.stringify({ error: 'already_reviewed' }), { status: 409, headers });
    }

    const { error: upsertError } = await supabase
      .from('reviewer_users')
      .upsert({ email, username, name, surname }, { onConflict: 'email' });
    if (upsertError) throw upsertError;

    await supabase.from('email_approval').delete().eq('email', email);

    const token = crypto.randomUUID() + '-' + crypto.randomUUID();
    const expiresAt = new Date(Date.now() + 60 * 60 * 1000);
    const { error: insertError } = await supabase.from('email_approval').insert({
      email,
      token,
      expires_at: expiresAt.toISOString(),
    });
    if (insertError) throw insertError;

    const magicLink = `${SITE_URL}/recensioni?token=${token}`;
    await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: { Authorization: `Bearer ${RESEND_API_KEY}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        from: RESEND_FROM_EMAIL,
        to: email,
        subject: 'Conferma la tua email per inviare la recensione',
        html: `<p>Ciao ${name},</p><p>Clicca il link per confermare la tua email e inviare la recensione. Valido 1 ora.</p><p><a href="${magicLink}">${magicLink}</a></p><p>Se non hai richiesto questo link, ignoralo.</p>`,
      }),
    }).catch(() => {});

    return new Response(JSON.stringify({ ok: true }), { headers });
  } catch (_) {
    return new Response(JSON.stringify({ error: 'Errore interno' }), { status: 500, headers });
  }
});
```

- [ ] **Step 2: Rewrite `verify-review-token/index.ts`**

```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { checkOrigin, optionsResponse, corsHeaders } from '../_shared/cors.ts';
import { makeServiceClient } from '../_shared/client.ts';

serve(async (req) => {
  if (req.method === 'OPTIONS') return optionsResponse(req);
  const originError = checkOrigin(req);
  if (originError) return originError;

  const origin = req.headers.get('origin');
  const headers = { ...corsHeaders(origin), 'Content-Type': 'application/json' };

  try {
    const { token } = await req.json();
    if (!token || typeof token !== 'string' || token.length > 200) {
      return new Response(JSON.stringify({ error: 'Token non valido' }), { status: 400, headers });
    }

    const supabase = makeServiceClient();

    const { data: rows, error } = await supabase
      .from('email_approval')
      .select('email, expires_at')
      .eq('token', token)
      .limit(1);
    if (error) throw error;

    if (!rows || rows.length === 0) {
      return new Response(JSON.stringify({ error: 'Token non valido' }), { status: 400, headers });
    }

    const row = rows[0];
    if (new Date(row.expires_at) < new Date()) {
      await supabase.from('email_approval').delete().eq('token', token);
      return new Response(JSON.stringify({ error: 'Token scaduto' }), { status: 400, headers });
    }

    await supabase.from('email_approval').delete().eq('token', token);

    const { data: users, error: userError } = await supabase
      .from('reviewer_users')
      .select('username, name')
      .eq('email', row.email)
      .limit(1);
    if (userError) throw userError;

    const user = users?.[0];
    return new Response(
      JSON.stringify({ email: row.email, username: user?.username ?? '', name: user?.name ?? '' }),
      { headers },
    );
  } catch (_) {
    return new Response(JSON.stringify({ error: 'Errore interno' }), { status: 500, headers });
  }
});
```

- [ ] **Step 3: Rewrite `submit-review/index.ts`**

```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { checkOrigin, optionsResponse, corsHeaders } from '../_shared/cors.ts';
import { makeServiceClient } from '../_shared/client.ts';

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')!;
const RESEND_FROM_EMAIL = Deno.env.get('RESEND_FROM_EMAIL')!;
const ADMIN_EMAIL = Deno.env.get('ADMIN_EMAIL')!;

serve(async (req) => {
  if (req.method === 'OPTIONS') return optionsResponse(req);
  const originError = checkOrigin(req);
  if (originError) return originError;

  const origin = req.headers.get('origin');
  const headers = { ...corsHeaders(origin), 'Content-Type': 'application/json' };

  try {
    const { email, title, description, stars } = await req.json();
    if (!email || !title || !description || !stars ||
        email.length > 254 || title.length > 200 ||
        description.length > 2000 || typeof stars !== 'number' ||
        stars < 1 || stars > 5) {
      return new Response(JSON.stringify({ error: 'Dati non validi' }), { status: 400, headers });
    }

    const supabase = makeServiceClient();

    const { data: users, error: userError } = await supabase
      .from('reviewer_users')
      .select('username, name, surname')
      .eq('email', email)
      .limit(1);
    if (userError) throw userError;
    if (!users || users.length === 0) {
      return new Response(JSON.stringify({ error: 'Utente non trovato' }), { status: 404, headers });
    }
    const user = users[0];

    const { error: insertError } = await supabase.from('reviews').insert({
      email,
      username: user.username,
      title,
      description,
      stars,
      approved: false,
    });
    if (insertError) {
      if (insertError.code === '23505') {
        return new Response(JSON.stringify({ error: 'duplicate' }), { status: 409, headers });
      }
      throw insertError;
    }

    fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: { Authorization: `Bearer ${RESEND_API_KEY}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        from: RESEND_FROM_EMAIL,
        to: ADMIN_EMAIL,
        subject: 'Nuova recensione in attesa di approvazione',
        html: `<p>Nuova recensione da approvare.</p><ul><li><strong>Username:</strong> ${user.username}</li><li><strong>Stelle:</strong> ${stars}/5</li><li><strong>Titolo:</strong> ${title}</li></ul><blockquote>${description}</blockquote>`,
      }),
    }).catch(() => {});

    return new Response(JSON.stringify({ ok: true }), { headers });
  } catch (_) {
    return new Response(JSON.stringify({ error: 'Errore interno' }), { status: 500, headers });
  }
});
```

- [ ] **Step 4: Commit**

```bash
git add supabase/functions/send-review-magic-link/index.ts \
        supabase/functions/verify-review-token/index.ts \
        supabase/functions/submit-review/index.ts
git commit -m "feat: add origin check and schema fix to existing Edge Functions"
```

---

## Task 4: Rewrite `send-contact-request` (Article 9 compliant)

**Files:**
- Modify: `supabase/functions/send-contact-request/index.ts`

**Interfaces:**
- Consumes: `checkOrigin`, `optionsResponse`, `corsHeaders` from `../_shared/cors.ts`; `makeServiceClient` from `../_shared/client.ts`
- Key behaviour: upload → email → **always delete** → insert record (no attachment reference)

- [ ] **Step 1: Rewrite `send-contact-request/index.ts`**

```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { checkOrigin, optionsResponse, corsHeaders } from '../_shared/cors.ts';
import { makeServiceClient } from '../_shared/client.ts';

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')!;
const RESEND_FROM_EMAIL = Deno.env.get('RESEND_FROM_EMAIL')!;
const ADMIN_EMAIL = Deno.env.get('ADMIN_EMAIL')!;
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

serve(async (req) => {
  if (req.method === 'OPTIONS') return optionsResponse(req);
  const originError = checkOrigin(req);
  if (originError) return originError;

  const origin = req.headers.get('origin');
  const headers = { ...corsHeaders(origin), 'Content-Type': 'application/json' };

  try {
    const { name, surname, email, title, message, tesseraBase64, tesseraFileName } = await req.json();

    if (!name || !surname || !email || !title || !message || !tesseraBase64 || !tesseraFileName ||
        name.length > 100 || surname.length > 100 || email.length > 254 ||
        title.length > 200 || message.length > 5000 || tesseraFileName.length > 255) {
      return new Response(JSON.stringify({ error: 'Dati non validi' }), { status: 400, headers });
    }

    const supabase = makeServiceClient();

    // Decode and upload attachment to private staging area
    const fileBytes = Uint8Array.from(atob(tesseraBase64), c => c.charCodeAt(0));
    const ext = tesseraFileName.split('.').pop() ?? 'bin';
    const storagePath = `tessere/${crypto.randomUUID()}.${ext}`;
    const mimeTypes: Record<string, string> = {
      pdf: 'application/pdf', jpg: 'image/jpeg', jpeg: 'image/jpeg', png: 'image/png',
    };
    const contentType = mimeTypes[ext.toLowerCase()] ?? 'application/octet-stream';

    // Use raw storage client (not schema-scoped) for storage operations
    const { createClient } = await import('https://esm.sh/@supabase/supabase-js@2');
    const storageClient = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    const { error: uploadError } = await storageClient.storage
      .from('contact-attachments')
      .upload(storagePath, fileBytes, { contentType, upsert: false });
    if (uploadError) throw uploadError;

    // Email attachment to admin — capture outcome but do not throw
    let emailOk = false;
    try {
      const emailRes = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: { Authorization: `Bearer ${RESEND_API_KEY}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({
          from: RESEND_FROM_EMAIL,
          to: ADMIN_EMAIL,
          subject: 'Nuova richiesta di primo colloquio',
          html: `<p>Nuova richiesta di colloquio.</p><ul><li><strong>Nome:</strong> ${name} ${surname}</li><li><strong>Email:</strong> ${email}</li><li><strong>Oggetto:</strong> ${title}</li></ul><blockquote>${message}</blockquote>`,
          attachments: [{
            filename: tesseraFileName,
            content: tesseraBase64,
          }],
        }),
      });
      emailOk = emailRes.ok;
    } catch (_) {
      emailOk = false;
    }

    // Article 9: always delete from storage regardless of email outcome
    const { error: deleteError } = await storageClient.storage
      .from('contact-attachments')
      .remove([storagePath]);
    if (deleteError) {
      // Log orphan — do not expose to client
      console.error('ORPHAN_FILE:', storagePath, deleteError.message);
    }

    if (!emailOk) {
      // Notify admin of failure without attachment
      fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: { Authorization: `Bearer ${RESEND_API_KEY}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({
          from: RESEND_FROM_EMAIL,
          to: ADMIN_EMAIL,
          subject: '[ATTENZIONE] Richiesta colloquio ricevuta — allegato non consegnato',
          html: `<p><strong>Attenzione:</strong> una richiesta di colloquio è stata ricevuta ma l'allegato (tessera sanitaria) non è stato consegnato per un errore tecnico.</p><ul><li><strong>Nome:</strong> ${name} ${surname}</li><li><strong>Email:</strong> ${email}</li></ul><p>Contattare il paziente per richiedere nuovamente il documento.</p>`,
        }),
      }).catch(() => {});
    }

    // Insert record — no attachment reference stored (Article 9 compliance)
    const { error: insertError } = await supabase
      .from('contact_requests')
      .insert({ name, surname, email, title, message });
    if (insertError) throw insertError;

    return new Response(JSON.stringify({ ok: true }), { headers });
  } catch (_) {
    return new Response(JSON.stringify({ error: 'Errore interno' }), { status: 500, headers });
  }
});
```

- [ ] **Step 2: Commit**

```bash
git add supabase/functions/send-contact-request/index.ts
git commit -m "feat: Article 9 compliant send-contact-request (transient attachment, always deleted)"
```

---

## Task 5: New public Edge Functions (`get-articles`, `get-approved-reviews`)

**Files:**
- Create: `supabase/functions/get-articles/index.ts`
- Create: `supabase/functions/get-approved-reviews/index.ts`

**Interfaces:**
- Consumes: `checkOrigin`, `optionsResponse`, `corsHeaders` from `../_shared/cors.ts`; `makeServiceClient` from `../_shared/client.ts`
- `get-articles`: `GET /functions/v1/get-articles` → `[{id, titolo, corpo, pubblicato_at, immagine_url}]`; with `?id=N` → single object or 404
- `get-approved-reviews`: `GET /functions/v1/get-approved-reviews` → `[{id, username, title, description, stars, created_at}]`

- [ ] **Step 1: Create `get-articles/index.ts`**

```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { checkOrigin, optionsResponse, corsHeaders } from '../_shared/cors.ts';
import { makeServiceClient } from '../_shared/client.ts';

serve(async (req) => {
  if (req.method === 'OPTIONS') return optionsResponse(req);
  const originError = checkOrigin(req);
  if (originError) return originError;

  const origin = req.headers.get('origin');
  const headers = { ...corsHeaders(origin), 'Content-Type': 'application/json' };

  try {
    const url = new URL(req.url);
    const id = url.searchParams.get('id');
    const supabase = makeServiceClient();

    if (id) {
      const { data, error } = await supabase
        .from('articoli')
        .select('id, titolo, corpo, pubblicato_at, immagine_url')
        .eq('id', Number(id))
        .limit(1);
      if (error) throw error;
      if (!data || data.length === 0) {
        return new Response(JSON.stringify({ error: 'Non trovato' }), { status: 404, headers });
      }
      return new Response(JSON.stringify(data[0]), { headers });
    }

    const { data, error } = await supabase
      .from('articoli')
      .select('id, titolo, corpo, pubblicato_at, immagine_url')
      .order('pubblicato_at', { ascending: false });
    if (error) throw error;
    return new Response(JSON.stringify(data ?? []), { headers });
  } catch (_) {
    return new Response(JSON.stringify({ error: 'Errore interno' }), { status: 500, headers });
  }
});
```

- [ ] **Step 2: Create `get-approved-reviews/index.ts`**

```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { checkOrigin, optionsResponse, corsHeaders } from '../_shared/cors.ts';
import { makeServiceClient } from '../_shared/client.ts';

serve(async (req) => {
  if (req.method === 'OPTIONS') return optionsResponse(req);
  const originError = checkOrigin(req);
  if (originError) return originError;

  const origin = req.headers.get('origin');
  const headers = { ...corsHeaders(origin), 'Content-Type': 'application/json' };

  try {
    const supabase = makeServiceClient();
    const { data, error } = await supabase
      .from('reviews')
      .select('id, username, title, description, stars, created_at')
      .eq('approved', true)
      .order('created_at', { ascending: false });
    if (error) throw error;
    return new Response(JSON.stringify(data ?? []), { headers });
  } catch (_) {
    return new Response(JSON.stringify({ error: 'Errore interno' }), { status: 500, headers });
  }
});
```

- [ ] **Step 3: Commit**

```bash
git add supabase/functions/get-articles/index.ts \
        supabase/functions/get-approved-reviews/index.ts
git commit -m "feat: add get-articles and get-approved-reviews Edge Functions"
```

---

## Task 6: New admin Edge Functions (`admin-articles`, `admin-reviews`, `admin-contact-requests`)

**Files:**
- Create: `supabase/functions/admin-articles/index.ts`
- Create: `supabase/functions/admin-reviews/index.ts`
- Create: `supabase/functions/admin-contact-requests/index.ts`

**Interfaces:**
- Consumes: `checkOrigin`, `optionsResponse`, `corsHeaders`; `verifyAdmin` from `../_shared/auth.ts`; `makeServiceClient`
- `admin-articles` POST body: `{ action: 'list' | 'create' | 'update' | 'delete' | 'upload-image' | 'delete-image', ...fields }`
- `admin-reviews` POST body: `{ action: 'list' | 'approve' | 'delete', id?: number }`
- `admin-contact-requests` POST body: `{ action: 'list' }`

- [ ] **Step 1: Create `admin-articles/index.ts`**

```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { checkOrigin, optionsResponse, corsHeaders } from '../_shared/cors.ts';
import { verifyAdmin } from '../_shared/auth.ts';
import { makeServiceClient } from '../_shared/client.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

serve(async (req) => {
  if (req.method === 'OPTIONS') return optionsResponse(req);
  const originError = checkOrigin(req);
  if (originError) return originError;
  const authError = await verifyAdmin(req);
  if (authError) return authError;

  const origin = req.headers.get('origin');
  const headers = { ...corsHeaders(origin), 'Content-Type': 'application/json' };

  try {
    const body = await req.json();
    const { action } = body;
    const supabase = makeServiceClient();
    const storageClient = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    if (action === 'list') {
      const { data, error } = await supabase
        .from('articoli')
        .select('id, titolo, corpo, pubblicato_at, immagine_url')
        .order('pubblicato_at', { ascending: false });
      if (error) throw error;
      return new Response(JSON.stringify(data ?? []), { headers });
    }

    if (action === 'create') {
      const { titolo, corpo, immagine_url } = body;
      if (!titolo || !corpo || titolo.length > 500 || corpo.length > 100000) {
        return new Response(JSON.stringify({ error: 'Dati non validi' }), { status: 400, headers });
      }
      const { data, error } = await supabase
        .from('articoli')
        .insert({ titolo, corpo, pubblicato_at: new Date().toISOString(), immagine_url: immagine_url ?? null })
        .select('id, titolo, corpo, pubblicato_at, immagine_url');
      if (error) throw error;
      return new Response(JSON.stringify(data![0]), { headers });
    }

    if (action === 'update') {
      const { id, titolo, corpo, immagine_url } = body;
      if (!id || !titolo || !corpo || titolo.length > 500 || corpo.length > 100000) {
        return new Response(JSON.stringify({ error: 'Dati non validi' }), { status: 400, headers });
      }
      const { error } = await supabase
        .from('articoli')
        .update({ titolo, corpo, immagine_url: immagine_url ?? null })
        .eq('id', Number(id));
      if (error) throw error;
      return new Response(JSON.stringify({ ok: true }), { headers });
    }

    if (action === 'delete') {
      const { id } = body;
      if (!id) return new Response(JSON.stringify({ error: 'id mancante' }), { status: 400, headers });
      const { error } = await supabase.from('articoli').delete().eq('id', Number(id));
      if (error) throw error;
      return new Response(JSON.stringify({ ok: true }), { headers });
    }

    if (action === 'upload-image') {
      const { imageBase64, mimeType } = body;
      if (!imageBase64 || !mimeType) {
        return new Response(JSON.stringify({ error: 'Dati non validi' }), { status: 400, headers });
      }
      const ext = mimeType.split('/')[1] ?? 'jpg';
      const filename = `${crypto.randomUUID()}.${ext}`;
      const bytes = Uint8Array.from(atob(imageBase64), c => c.charCodeAt(0));
      const { error } = await storageClient.storage
        .from('articoli-images')
        .upload(filename, bytes, { contentType: mimeType });
      if (error) throw error;
      const { data: urlData } = storageClient.storage
        .from('articoli-images')
        .getPublicUrl(filename);
      return new Response(JSON.stringify({ url: urlData.publicUrl }), { headers });
    }

    if (action === 'delete-image') {
      const { url } = body;
      if (!url) return new Response(JSON.stringify({ error: 'url mancante' }), { status: 400, headers });
      const prefix = `${SUPABASE_URL}/storage/v1/object/public/articoli-images/`;
      if (!url.startsWith(prefix)) {
        return new Response(JSON.stringify({ error: 'url non valido' }), { status: 400, headers });
      }
      const filename = url.substring(prefix.length);
      const { error } = await storageClient.storage.from('articoli-images').remove([filename]);
      if (error) throw error;
      return new Response(JSON.stringify({ ok: true }), { headers });
    }

    return new Response(JSON.stringify({ error: 'Azione non valida' }), { status: 400, headers });
  } catch (_) {
    return new Response(JSON.stringify({ error: 'Errore interno' }), { status: 500, headers });
  }
});
```

- [ ] **Step 2: Create `admin-reviews/index.ts`**

```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { checkOrigin, optionsResponse, corsHeaders } from '../_shared/cors.ts';
import { verifyAdmin } from '../_shared/auth.ts';
import { makeServiceClient } from '../_shared/client.ts';

serve(async (req) => {
  if (req.method === 'OPTIONS') return optionsResponse(req);
  const originError = checkOrigin(req);
  if (originError) return originError;
  const authError = await verifyAdmin(req);
  if (authError) return authError;

  const origin = req.headers.get('origin');
  const headers = { ...corsHeaders(origin), 'Content-Type': 'application/json' };

  try {
    const { action, id } = await req.json();
    const supabase = makeServiceClient();

    if (action === 'list') {
      const { data, error } = await supabase
        .from('reviews')
        .select('id, username, email, title, description, stars, approved, created_at')
        .order('created_at', { ascending: false });
      if (error) throw error;
      return new Response(JSON.stringify(data ?? []), { headers });
    }

    if (action === 'approve') {
      if (!id) return new Response(JSON.stringify({ error: 'id mancante' }), { status: 400, headers });
      const { error } = await supabase.from('reviews').update({ approved: true }).eq('id', Number(id));
      if (error) throw error;
      return new Response(JSON.stringify({ ok: true }), { headers });
    }

    if (action === 'delete') {
      if (!id) return new Response(JSON.stringify({ error: 'id mancante' }), { status: 400, headers });
      const { error } = await supabase.from('reviews').delete().eq('id', Number(id));
      if (error) throw error;
      return new Response(JSON.stringify({ ok: true }), { headers });
    }

    return new Response(JSON.stringify({ error: 'Azione non valida' }), { status: 400, headers });
  } catch (_) {
    return new Response(JSON.stringify({ error: 'Errore interno' }), { status: 500, headers });
  }
});
```

- [ ] **Step 3: Create `admin-contact-requests/index.ts`**

```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { checkOrigin, optionsResponse, corsHeaders } from '../_shared/cors.ts';
import { verifyAdmin } from '../_shared/auth.ts';
import { makeServiceClient } from '../_shared/client.ts';

serve(async (req) => {
  if (req.method === 'OPTIONS') return optionsResponse(req);
  const originError = checkOrigin(req);
  if (originError) return originError;
  const authError = await verifyAdmin(req);
  if (authError) return authError;

  const origin = req.headers.get('origin');
  const headers = { ...corsHeaders(origin), 'Content-Type': 'application/json' };

  try {
    const { action } = await req.json();

    if (action === 'list') {
      const supabase = makeServiceClient();
      const { data, error } = await supabase
        .from('contact_requests')
        .select('id, name, surname, email, title, message, created_at')
        .order('created_at', { ascending: false });
      if (error) throw error;
      return new Response(JSON.stringify(data ?? []), { headers });
    }

    return new Response(JSON.stringify({ error: 'Azione non valida' }), { status: 400, headers });
  } catch (_) {
    return new Response(JSON.stringify({ error: 'Errore interno' }), { status: 500, headers });
  }
});
```

- [ ] **Step 4: Commit**

```bash
git add supabase/functions/admin-articles/index.ts \
        supabase/functions/admin-reviews/index.ts \
        supabase/functions/admin-contact-requests/index.ts
git commit -m "feat: add admin-articles, admin-reviews, admin-contact-requests Edge Functions"
```

---

## Task 7: Deploy all Edge Functions

All functions must be deployed to Supabase before the Flutter client is updated.

- [ ] **Step 1: Install Supabase CLI if not present**

```bash
npm install -g supabase
```

- [ ] **Step 2: Login and link project**

```bash
supabase login
supabase link --project-ref snsvamcecgizhecvtpwk
```

- [ ] **Step 3: Deploy all functions**

```bash
supabase functions deploy get-articles
supabase functions deploy get-approved-reviews
supabase functions deploy send-contact-request
supabase functions deploy send-review-magic-link
supabase functions deploy verify-review-token
supabase functions deploy submit-review
supabase functions deploy admin-articles
supabase functions deploy admin-reviews
supabase functions deploy admin-contact-requests
```

Expected output for each: `Deployed Function <name> on project snsvamcecgizhecvtpwk`

- [ ] **Step 4: Set `ALLOWED_ORIGIN` secret (if not already done in pre-implementation checklist)**

```bash
supabase secrets set ALLOWED_ORIGIN=https://riccardo-cpt.github.io
```

- [ ] **Step 5: Smoke-test public functions**

```bash
curl -H "Origin: https://riccardo-cpt.github.io" \
  https://snsvamcecgizhecvtpwk.supabase.co/functions/v1/get-articles
# Expected: JSON array of articles

curl -H "Origin: https://evil.com" \
  https://snsvamcecgizhecvtpwk.supabase.co/functions/v1/get-articles
# Expected: HTTP 403, empty body
```

- [ ] **Step 6: Commit**

```bash
git commit --allow-empty -m "chore: deploy all Edge Functions to Supabase"
```

---

## Task 8: Flutter — add `supabase_flutter`, update `admin_config.dart`

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/config/admin_config.dart`

**Interfaces:**
- Produces: `AdminConfig.supabaseUrl` (String), `AdminConfig.functionsUrl` (String)

- [ ] **Step 1: Add `supabase_flutter` to `pubspec.yaml`**

In `pubspec.yaml`, under `dependencies:`, add after `http: ^1.2.0`:

```yaml
  supabase_flutter: ^2.0.0
```

- [ ] **Step 2: Run `flutter pub get`**

```bash
flutter pub get
```

Expected: resolves without errors, `supabase_flutter` appears in `.dart_tool/package_config.json`.

- [ ] **Step 3: Rewrite `lib/config/admin_config.dart`**

Replace entire file content with:

```dart
class AdminConfig {
  static const String supabaseUrl = 'https://snsvamcecgizhecvtpwk.supabase.co';
  static const String functionsUrl = '$supabaseUrl/functions/v1';
}
```

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/config/admin_config.dart
git commit -m "feat: add supabase_flutter, strip keys from AdminConfig"
```

---

## Task 9: Flutter — rewrite `BlogAuthService` with Supabase Auth SDK

**Files:**
- Modify: `lib/services/blog_auth_service.dart`
- Modify: `lib/main.dart`

**Interfaces:**
- Produces:
  - `BlogAuthService.initialize()` — `Future<void>`, initializes Supabase SDK (call once in `main()`)
  - `BlogAuthService.signIn(email: String, password: String)` — `Future<void>`, throws on failure
  - `BlogAuthService.signOut()` — `Future<void>`
  - `BlogAuthService.currentJwt` — `String?`, returns current session JWT or null
  - `BlogAuthService.isAdmin` — `ValueNotifier<bool>`, true when session active

- [ ] **Step 1: Rewrite `lib/services/blog_auth_service.dart`**

```dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/admin_config.dart';

class BlogAuthService {
  final ValueNotifier<bool> isAdmin = ValueNotifier(false);

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AdminConfig.supabaseUrl,
      anonKey: '',
    );
    // Restore session on hot reload / page refresh
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      _instance?.isAdmin.value = true;
    }
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _instance?.isAdmin.value = data.session != null;
    });
  }

  static BlogAuthService? _instance;

  BlogAuthService() {
    _instance = this;
  }

  Future<void> signIn({required String email, required String password}) async {
    final response = await Supabase.instance.client.auth
        .signInWithPassword(email: email, password: password);
    if (response.session == null) {
      throw Exception('Credenziali non valide');
    }
    isAdmin.value = true;
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    isAdmin.value = false;
  }

  String? get currentJwt =>
      Supabase.instance.client.auth.currentSession?.accessToken;
}
```

- [ ] **Step 2: Update `lib/main.dart` to initialize Supabase and remove `storageService`**

Replace the `main()` function and service globals block:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'dart:js_interop';
import 'pages/home_page.dart';
import 'pages/servizi_page.dart';
import 'pages/articoli_page.dart';
import 'pages/articoli_admin_page.dart';
import 'pages/approccio_terapeutico_page.dart';
import 'pages/psicoterapia_page.dart';
import 'pages/figure_professionali_page.dart';
import 'pages/disturbi_page.dart';
import 'pages/privacy_page.dart';
import 'pages/faq_page.dart';
import 'pages/chi_sono_page.dart';
import 'pages/recensioni_page.dart';
import 'widgets/nav_bar.dart';
import 'services/articoli_service.dart';
import 'services/blog_auth_service.dart';
import 'services/review_auth_service.dart';
import 'services/reviews_service.dart';
import 'services/contact_service.dart';
import 'services/admin_contact_service.dart';

const _siteName = 'Dott. Antonella Petrini — Psicologa e Psicoterapeuta';

const _pageTitles = {
  '/': 'Psicologa e Psicoterapeuta a Firenze | $_siteName',
  '/servizi': 'Servizi di psicoterapia | $_siteName',
  '/chi-sono': 'Chi sono | $_siteName',
  '/approccio-terapeutico': 'Approccio terapeutico | $_siteName',
  '/psicoterapia': 'Psicoterapia | $_siteName',
  '/disturbi': 'Disturbi trattati | $_siteName',
  '/figure-professionali': 'Psicologo, psicoterapeuta e psichiatra | $_siteName',
  '/faq': 'Domande frequenti | $_siteName',
  '/articoli': 'Articoli | $_siteName',
  '/recensioni': 'Recensioni | $_siteName',
  '/privacy': 'Privacy e consenso informato | $_siteName',
};

@JS('document.title')
external set _documentTitle(String value);

final articoliService = ArticoliService();
final blogAuthService = BlogAuthService();
final reviewAuthService = ReviewAuthService();
final reviewsService = ReviewsService();
final contactService = ContactService();
final adminContactService = AdminContactService();

final _router = GoRouter(
  observers: [_TitleObserver()],
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
    GoRoute(path: '/approccio-terapeutico', builder: (_, _) => const ApproccioTerapeuticoPage()),
    GoRoute(path: '/psicoterapia', builder: (_, _) => const PsicoterapiaPage()),
    GoRoute(path: '/disturbi', builder: (_, _) => const DisturbPage()),
    GoRoute(path: '/figure-professionali', builder: (_, _) => const FigureProfessionaliPage()),
    GoRoute(path: '/privacy', builder: (_, _) => const PrivacyPage()),
    GoRoute(path: '/faq', builder: (_, _) => const FaqPage()),
  ],
);

void main() async {
  usePathUrlStrategy();
  await BlogAuthService.initialize();
  runApp(const PsicApp());
}

class _TitleObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) => _update(route);

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) => _update(newRoute);

  void _update(Route? route) {
    final path = route?.settings.name ?? '/';
    _documentTitle = _pageTitles[path] ?? _siteName;
  }
}

class PsicApp extends StatelessWidget {
  const PsicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Dott. Antonella Petrini — Psicologa Psicoterapeuta',
      routerConfig: _router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF93a996)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/services/blog_auth_service.dart lib/main.dart
git commit -m "feat: rewrite BlogAuthService with Supabase Auth SDK, async main init"
```

---

## Task 10: Flutter — update `ArticoliService` and `ReviewsService`

**Files:**
- Modify: `lib/services/articoli_service.dart`
- Modify: `lib/services/reviews_service.dart`

**Interfaces:**
- Consumes: `AdminConfig.functionsUrl`, `blogAuthService.currentJwt` from `BlogAuthService`
- `ArticoliService.tutti()` — `Future<List<Articolo>>`, calls `GET /functions/v1/get-articles`
- `ArticoliService.inserisci(titolo, corpo, imageBytes?, imageMime?)` — `Future<Articolo>`, calls `admin-articles` with action `upload-image` then `create`
- `ArticoliService.aggiorna(id, titolo, corpo, imageBytes?, imageMime?, removeImage)` — `Future<void>`
- `ArticoliService.cancella(id, immagineUrl?)` — `Future<void>`, deletes image then article
- `ReviewsService.tutti()` — `Future<List<Review>>`, calls `get-approved-reviews`
- `ReviewsService.tuttiAdmin()` — `Future<List<Review>>`, calls `admin-reviews` with action `list`
- `ReviewsService.approva(id)` — `Future<void>`
- `ReviewsService.cancella(id)` — `Future<void>`

- [ ] **Step 1: Rewrite `lib/services/articoli_service.dart`**

```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/admin_config.dart';
import '../models/articolo.dart';
import '../main.dart';

class ArticoliService {
  Future<List<Articolo>>? overrideForTest;

  Map<String, String> get _publicHeaders => const {
        'Content-Type': 'application/json',
      };

  Map<String, String> get _adminHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${blogAuthService.currentJwt ?? ''}',
      };

  Future<List<Articolo>> tutti() async {
    if (overrideForTest != null) return overrideForTest!;
    final uri = Uri.parse('${AdminConfig.functionsUrl}/get-articles');
    final response = await http.get(uri, headers: _publicHeaders);
    if (response.statusCode != 200) {
      throw Exception('Errore nel recupero degli articoli');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => Articolo.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Articolo> inserisci({
    required String titolo,
    required String corpo,
    Uint8List? imageBytes,
    String? imageMime,
  }) async {
    String? immagineUrl;
    if (imageBytes != null && imageMime != null) {
      immagineUrl = await _uploadImage(imageBytes, imageMime);
    }
    final uri = Uri.parse('${AdminConfig.functionsUrl}/admin-articles');
    final response = await http.post(uri,
        headers: _adminHeaders,
        body: jsonEncode({
          'action': 'create',
          'titolo': titolo,
          'corpo': corpo,
          if (immagineUrl != null) 'immagine_url': immagineUrl,
        }));
    if (response.statusCode != 200) {
      throw Exception('Errore nel salvataggio');
    }
    return Articolo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> aggiorna({
    required int id,
    required String titolo,
    required String corpo,
    Uint8List? newImageBytes,
    String? newImageMime,
    String? existingImageUrl,
    bool removeImage = false,
  }) async {
    String? immagineUrl = removeImage ? null : existingImageUrl;
    if (newImageBytes != null && newImageMime != null) {
      if (existingImageUrl != null) await _deleteImage(existingImageUrl);
      immagineUrl = await _uploadImage(newImageBytes, newImageMime);
    } else if (removeImage && existingImageUrl != null) {
      await _deleteImage(existingImageUrl);
    }
    final uri = Uri.parse('${AdminConfig.functionsUrl}/admin-articles');
    final response = await http.post(uri,
        headers: _adminHeaders,
        body: jsonEncode({
          'action': 'update',
          'id': id,
          'titolo': titolo,
          'corpo': corpo,
          'immagine_url': immagineUrl,
        }));
    if (response.statusCode != 200) {
      throw Exception('Errore nella modifica');
    }
  }

  Future<void> cancella(int id, {String? immagineUrl}) async {
    if (immagineUrl != null) await _deleteImage(immagineUrl);
    final uri = Uri.parse('${AdminConfig.functionsUrl}/admin-articles');
    final response = await http.post(uri,
        headers: _adminHeaders,
        body: jsonEncode({'action': 'delete', 'id': id}));
    if (response.statusCode != 200) {
      throw Exception('Errore nell\'eliminazione');
    }
  }

  Future<String> _uploadImage(Uint8List bytes, String mime) async {
    final uri = Uri.parse('${AdminConfig.functionsUrl}/admin-articles');
    final response = await http.post(uri,
        headers: _adminHeaders,
        body: jsonEncode({
          'action': 'upload-image',
          'imageBase64': base64Encode(bytes),
          'mimeType': mime,
        }));
    if (response.statusCode != 200) throw Exception('Errore nel caricamento immagine');
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['url'] as String;
  }

  Future<void> _deleteImage(String url) async {
    final uri = Uri.parse('${AdminConfig.functionsUrl}/admin-articles');
    await http.post(uri,
        headers: _adminHeaders,
        body: jsonEncode({'action': 'delete-image', 'url': url}));
  }
}
```

- [ ] **Step 2: Rewrite `lib/services/reviews_service.dart`**

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/admin_config.dart';
import '../models/review.dart';
import '../main.dart';

class ReviewsService {
  Future<List<Review>>? overrideForTest;

  Map<String, String> get _publicHeaders => const {
        'Content-Type': 'application/json',
      };

  Map<String, String> get _adminHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${blogAuthService.currentJwt ?? ''}',
      };

  Future<List<Review>> tutti() async {
    if (overrideForTest != null) return overrideForTest!;
    final uri = Uri.parse('${AdminConfig.functionsUrl}/get-approved-reviews');
    final response = await http.get(uri, headers: _publicHeaders);
    if (response.statusCode != 200) throw Exception('Errore nel recupero delle recensioni');
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Review>> tuttiAdmin() async {
    final uri = Uri.parse('${AdminConfig.functionsUrl}/admin-reviews');
    final response = await http.post(uri,
        headers: _adminHeaders,
        body: jsonEncode({'action': 'list'}));
    if (response.statusCode != 200) throw Exception('Errore nel recupero delle recensioni');
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> inserisci({
    required String email,
    required String title,
    required String description,
    required int stars,
  }) async {
    final uri = Uri.parse('${AdminConfig.functionsUrl}/submit-review');
    final response = await http.post(uri,
        headers: _publicHeaders,
        body: jsonEncode({'email': email, 'title': title, 'description': description, 'stars': stars}));
    if (response.statusCode != 200) {
      String? errorCode;
      try {
        errorCode = (jsonDecode(response.body) as Map<String, dynamic>)['error'] as String?;
      } catch (_) {}
      if (errorCode == 'duplicate') {
        throw Exception('Hai già inviato una recensione.');
      }
      throw Exception('Errore: riprova più tardi.');
    }
  }

  Future<void> approva(int id) async {
    final uri = Uri.parse('${AdminConfig.functionsUrl}/admin-reviews');
    final response = await http.post(uri,
        headers: _adminHeaders,
        body: jsonEncode({'action': 'approve', 'id': id}));
    if (response.statusCode != 200) throw Exception('Errore nell\'approvazione');
  }

  Future<void> cancella(int id) async {
    final uri = Uri.parse('${AdminConfig.functionsUrl}/admin-reviews');
    final response = await http.post(uri,
        headers: _adminHeaders,
        body: jsonEncode({'action': 'delete', 'id': id}));
    if (response.statusCode != 200) throw Exception('Errore nell\'eliminazione');
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/services/articoli_service.dart lib/services/reviews_service.dart
git commit -m "feat: migrate ArticoliService and ReviewsService to Edge Function proxy"
```

---

## Task 11: Flutter — remove anon key from `ContactService` and `ReviewAuthService`, create `AdminContactService`

**Files:**
- Modify: `lib/services/contact_service.dart`
- Modify: `lib/services/review_auth_service.dart`
- Create: `lib/services/admin_contact_service.dart`
- Delete: `lib/services/storage_service.dart`

**Interfaces:**
- `AdminContactService.lista()` — `Future<List<Map<String, dynamic>>>`, calls `admin-contact-requests` with action `list`

- [ ] **Step 1: Update `lib/services/contact_service.dart`** (remove anon key from headers)

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/admin_config.dart';

class ContactService {
  Future<void> invia({
    required String name,
    required String surname,
    required String email,
    required String title,
    required String message,
    required String tesseraBase64,
    required String tesseraFileName,
  }) async {
    final uri = Uri.parse('${AdminConfig.functionsUrl}/send-contact-request');
    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'surname': surname,
        'email': email,
        'title': title,
        'message': message,
        'tesseraBase64': tesseraBase64,
        'tesseraFileName': tesseraFileName,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Errore nell\'invio: riprova più tardi.');
    }
  }
}
```

- [ ] **Step 2: Update `lib/services/review_auth_service.dart`** (remove anon key from headers)

Replace the headers in `sendMagicLink` and `verifyToken` — change:
```dart
headers: {
  'Authorization': 'Bearer ${AdminConfig.supabaseAnonKey}',
  'Content-Type': 'application/json',
},
```
to:
```dart
headers: const {'Content-Type': 'application/json'},
```

Do this for both the `sendMagicLink` call and the `verifyToken` call. Also update the URI to use `AdminConfig.functionsUrl`:
- `'${AdminConfig.supabaseUrl}/functions/v1/send-review-magic-link'` → `'${AdminConfig.functionsUrl}/send-review-magic-link'`
- `'${AdminConfig.supabaseUrl}/functions/v1/verify-review-token'` → `'${AdminConfig.functionsUrl}/verify-review-token'`

- [ ] **Step 3: Create `lib/services/admin_contact_service.dart`**

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/admin_config.dart';
import '../main.dart';

class AdminContactService {
  Map<String, String> get _adminHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${blogAuthService.currentJwt ?? ''}',
      };

  Future<List<Map<String, dynamic>>> lista() async {
    final uri = Uri.parse('${AdminConfig.functionsUrl}/admin-contact-requests');
    final response = await http.post(uri,
        headers: _adminHeaders,
        body: jsonEncode({'action': 'list'}));
    if (response.statusCode != 200) throw Exception('Errore nel recupero');
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }
}
```

- [ ] **Step 4: Delete `lib/services/storage_service.dart`**

```bash
rm lib/services/storage_service.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/services/contact_service.dart \
        lib/services/review_auth_service.dart \
        lib/services/admin_contact_service.dart
git rm lib/services/storage_service.dart
git commit -m "feat: remove anon keys from services, add AdminContactService, delete StorageService"
```

---

## Task 12: Flutter — update admin page (`articoli_admin_page.dart`)

**Files:**
- Modify: `lib/pages/articoli_admin_page.dart`

**Key changes:**
- `_PasswordGate` → `_LoginGate`: replace password field with email + password fields, call `blogAuthService.signIn()`
- Add logout button to `_AdminPanel`
- `_ArticoloFormState._save()`: pass `imageBytes`/`imageMime` to `articoliService.inserisci`/`aggiorna` instead of calling `storageService`
- `_ArticoliTabState._confirmDelete()`: pass `immagineUrl` to `articoliService.cancella()`
- `_RecensioniTab`: no changes needed (already calls `reviewsService.tuttiAdmin()`, `approva()`, `cancella()`)

- [ ] **Step 1: Replace `_PasswordGate` with `_LoginGate`**

Find and replace the entire `_PasswordGate` class and `_PasswordGateState` class (lines 29–95) with:

```dart
class _LoginGate extends StatefulWidget {
  const _LoginGate();

  @override
  State<_LoginGate> createState() => _LoginGateState();
}

class _LoginGateState extends State<_LoginGate> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await blogAuthService.signIn(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credenziali non valide')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
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
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  onSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  onSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 16),
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Accedi', style: TextStyle(fontSize: 16)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Update `ArticoliAdminPage.build()` to reference `_LoginGate`**

Change:
```dart
isAdmin ? const _AdminPanel() : const _PasswordGate(),
```
to:
```dart
isAdmin ? const _AdminPanel() : const _LoginGate(),
```

- [ ] **Step 3: Add logout button to `_AdminPanel`**

Replace the `_AdminPanel.build()` method with:

```dart
@override
Widget build(BuildContext context) {
  return DefaultTabController(
    length: 2,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: TabBar(
                labelColor: AppColors.primary,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: 'Blog'),
                  Tab(text: 'Recensioni'),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Esci',
              onPressed: () => blogAuthService.signOut(),
            ),
          ],
        ),
        const Expanded(
          child: TabBarView(
            children: [
              _ArticoliTab(),
              _RecensioniTab(),
            ],
          ),
        ),
      ],
    ),
  );
}
```

- [ ] **Step 4: Update `_ArticoliTabState._confirmDelete()` to pass `immagineUrl`**

Change:
```dart
if (articolo.immagineUrl != null) {
  await storageService.deleteImmagine(articolo.immagineUrl!);
}
await articoliService.cancella(articolo.id);
```
to:
```dart
await articoliService.cancella(articolo.id, immagineUrl: articolo.immagineUrl);
```

- [ ] **Step 5: Update `_ArticoloFormState._save()` to pass image bytes instead of calling `storageService`**

Replace the `_save()` method body's image handling block. Change the `_save()` method to:

```dart
Future<void> _save() async {
  if (_titoloCtrl.text.trim().isEmpty || _corpoCtrl.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Titolo e corpo sono obbligatori')),
    );
    return;
  }
  setState(() => _saving = true);
  try {
    if (widget.articolo == null) {
      await articoliService.inserisci(
        titolo: _titoloCtrl.text.trim(),
        corpo: _corpoCtrl.text.trim(),
        imageBytes: _newImageBytes,
        imageMime: _newImageMime,
      );
    } else {
      await articoliService.aggiorna(
        id: widget.articolo!.id,
        titolo: _titoloCtrl.text.trim(),
        corpo: _corpoCtrl.text.trim(),
        newImageBytes: _newImageBytes,
        newImageMime: _newImageMime,
        existingImageUrl: widget.articolo!.immagineUrl,
        removeImage: _removeImage,
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
```

- [ ] **Step 6: Remove `storageService` import from `articoli_admin_page.dart`**

The file imports services via `../main.dart` — remove the `storageService` usage (already done in steps above). Verify no remaining references to `storageService` exist in the file.

- [ ] **Step 7: Build and check for compile errors**

```bash
flutter build web --release 2>&1 | head -50
```

Expected: no errors. Fix any type mismatches before proceeding.

- [ ] **Step 8: Commit**

```bash
git add lib/pages/articoli_admin_page.dart
git commit -m "feat: replace password gate with Supabase Auth login, update admin image handling"
```

---

## Task 13: Final cleanup and verification

**Files:**
- Verify all files compile and no references to removed keys remain

- [ ] **Step 1: Check no secrets remain in tracked files**

```bash
grep -r "supabaseAnonKey\|supabaseServiceRoleKey\|admin123\|service_role\|eyJhbGci" lib/ --include="*.dart"
```

Expected: no output. If anything found, remove it.

- [ ] **Step 2: Check no references to deleted `StorageService` remain**

```bash
grep -r "storageService\|StorageService\|storage_service" lib/ --include="*.dart"
```

Expected: no output.

- [ ] **Step 3: Full release build**

```bash
flutter build web --release
```

Expected: `✓ Built build/web` with no errors.

- [ ] **Step 4: Verify `contact_requests` table has no `tessera_sanitaria` column**

Run in Supabase SQL Editor:
```sql
SELECT column_name FROM information_schema.columns
WHERE table_schema = 'psyc_app' AND table_name = 'contact_requests';
```

Expected columns: `id, name, surname, email, title, message, created_at`. If `tessera_sanitaria` exists, drop it:
```sql
ALTER TABLE psyc_app.contact_requests DROP COLUMN IF EXISTS tessera_sanitaria;
```

- [ ] **Step 5: Verify `contact-attachments` bucket is private**

In Supabase dashboard → Storage → `contact-attachments` → Settings → ensure "Public bucket" is OFF.

- [ ] **Step 6: Final commit**

```bash
git add -A
git commit -m "chore: final cleanup — verify no secrets in bundle, drop tessera_sanitaria column"
```

- [ ] **Step 7: Push and verify CI passes**

```bash
git push origin main
```

Monitor GitHub Actions deploy. Once deployed, open `https://riccardo-cpt.github.io/PsycWebSite/` and verify:
- Articles load on the public page
- Reviews load on the public page
- `/admin` shows email + password login form
- Login with the admin account created in pre-implementation checklist works
- Creating/editing/deleting an article works
- Approving/rejecting a review works
