# Pre-Deployment Security Checklist

This file documents manual steps required before going live after the proxy migration.
All automated checks (secret scan, build) have already passed.

---

## Automated checks — DONE

- [x] No `supabaseAnonKey`, `supabaseServiceRoleKey`, `admin123`, `service_role`, or raw JWT secrets in any `lib/**/*.dart` file
- [x] No `StorageService` / `storage_service` references remain in client code
- [x] `flutter build web --release` succeeds (`✓ Built build/web`)

---

## Manual Supabase dashboard steps — REQUIRED before deploy

### 1. Drop `tessera_sanitaria` column (if it still exists)

Open the Supabase SQL Editor for project `snsvamcecgizhecvtpwk` and run:

```sql
SELECT column_name
FROM information_schema.columns
WHERE table_schema = 'psyc_app'
  AND table_name   = 'contact_requests';
```

Expected columns: `id, name, surname, email, title, message, created_at`.

If `tessera_sanitaria` is present, drop it:

```sql
ALTER TABLE psyc_app.contact_requests DROP COLUMN IF EXISTS tessera_sanitaria;
```

### 2. Verify `contact-attachments` bucket is private

Supabase dashboard → Storage → `contact-attachments` → Settings → confirm **"Public bucket"** is **OFF**.

### 3. Verify RLS policies are active

Confirm that Row Level Security is enabled on every table in the `psyc_app` schema:

```sql
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'psyc_app';
```

All rows must show `rowsecurity = true`.

### 4. Confirm Edge Functions are deployed

In the Supabase dashboard → Edge Functions, verify the following functions are present and active:

- `get-articoli`
- `get-reviews`
- `send-contact-request`
- `admin-get-contacts`
- `admin-update-contact`
- `admin-create-articolo`
- `admin-update-articolo`
- `admin-delete-articolo`
- `admin-approve-review`
- `admin-reject-review`

---

## Post-deploy smoke test

Once deployed to <https://riccardo-cpt.github.io/PsycWebSite/>:

- [ ] Articles load on the public home page
- [ ] Reviews load on the public home page
- [ ] `/admin` shows the email + password login form
- [ ] Admin login works with the production admin account
- [ ] Creating / editing / deleting an article works
- [ ] Approving / rejecting a review works
