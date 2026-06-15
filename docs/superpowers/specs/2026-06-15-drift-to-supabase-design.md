# Design: Drift → Supabase Migration

## Overview

Replace the local Drift/SQLite database with Supabase (PostgreSQL REST API + Storage bucket) for the `articoli` feature. Images move from `bytea` in the database to a Supabase Storage bucket to stay within the free tier's 5 GB/month bandwidth limit at ~50 views/day.

## Architecture

**Approach:** Thin HTTP service layer using the `http` package. No Supabase Flutter SDK. No realtime. Fetch-on-load only (no streaming).

**Read operations:** anon key, public  
**Write operations:** service-role key, behind UI password gate

## Configuration — `lib/config/admin_config.dart`

All Supabase parameters centralised here:

```dart
class AdminConfig {
  static const String password = 'admin123';
  static const String supabaseUrl = 'https://snsvamcecgizhecvtpwk.supabase.co';
  static const String supabaseAnonKey = 'F6092D47-06DF-4FEF-86CB-10312D4B87CC';
  static const String supabaseServiceRoleKey = '<service_role_key>';
  static const String supabaseRestUrl = '$supabaseUrl/rest/v1';
  static const String supabaseStorageUrl = '$supabaseUrl/storage/v1';
  static const String articoliBucket = 'articoli-images';
}
```

## Data Model — `lib/models/articolo.dart`

Plain Dart class replacing Drift-generated `ArticoliData`:

| Field | Type | Notes |
|---|---|---|
| `id` | `int` | |
| `titolo` | `String` | |
| `corpo` | `String` | |
| `pubblicatoAt` | `DateTime` | from `timestamptz`, used for display and ordering |
| `immagineUrl` | `String?` | public URL from storage bucket |

`dataPubblicazione` is dropped — UI derives display string from `pubblicatoAt` via `DateFormat('yyyy-MM-dd')`.

## Supabase DDL (already applied)

```sql
create table articoli (
  id bigint generated always as identity primary key,
  titolo text not null,
  corpo text not null,
  pubblicato_at timestampt,
  immagine_url text
);
```

## Service Layer

### `lib/services/articoli_service.dart`

| Method | HTTP | Auth | Notes |
|---|---|---|---|
| `tutti()` | GET `/rest/v1/articoli?select=*&order=pubblicato_at.desc` | anon | Returns `List<Articolo>` |
| `inserisci(titolo, corpo, immagineUrl)` | POST `/rest/v1/articoli` | service-role | `Prefer: return=representation` |
| `aggiorna(id, titolo, corpo, immagineUrl)` | PATCH `/rest/v1/articoli?id=eq.{id}` | service-role | |
| `cancella(id)` | DELETE `/rest/v1/articoli?id=eq.{id}` | service-role | |

### `lib/services/storage_service.dart`

| Method | HTTP | Auth | Notes |
|---|---|---|---|
| `uploadImmagine(bytes, mime)` | POST `/storage/v1/object/articoli-images/{uuid}` | service-role | Returns public URL |
| `deleteImmagine(url)` | DELETE `/storage/v1/object/articoli-images/{filename}` | service-role | Extracts filename from URL |

Both instantiated as globals in `main.dart`.

## UI Changes

### `ArticoliPage`
- `StreamBuilder<List<ArticoliData>>` → `FutureBuilder<List<Articolo>>`
- `Image.memory(a.immagine!)` → `Image.network(a.immagineUrl!)`
- `a.dataPubblicazione` → `DateFormat('yyyy-MM-dd').format(a.pubblicatoAt)`

### `ArticoliAdminPage`
- Same `FutureBuilder` swap; `setState` after each mutation to refresh list
- Save flow: upload image (if new) → get URL → insert/update row
- Delete flow: delete storage image (if present) → delete row
- `ArticoliCompanion` removed; plain parameters passed to service

## Removed

- `lib/database/` directory (all Drift files)
- `drift`, `drift_flutter`, `drift_dev`, `sqlite3_flutter_libs`, `build_runner` from `pubspec.yaml`
- Generated files: `app_database.g.dart`, `articoli_dao.g.dart`
- `web/sqlite3.wasm`, `web/drift_worker.js` (if present)

## Added

- `http: ^1.2.0` to dependencies
- `intl: ^0.20.0` to dependencies
- `lib/models/articolo.dart`
- `lib/services/articoli_service.dart`
- `lib/services/storage_service.dart`

## Branch

All changes on branch `feature/supabase-migration`.

## Security Note

Service-role key is stored in source code. Acceptable for this use case (private low-traffic site, simple password gate). Key does not rotate automatically.
