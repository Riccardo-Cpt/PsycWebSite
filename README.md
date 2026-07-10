# Dott. Antonella Petrini — Sito Web

Sito web professionale per la Dott. Antonella Petrini, Psicologa Psicoterapeuta. Sviluppato con Flutter Web e Supabase come backend.

## Pagine pubbliche

| Percorso | Descrizione |
|---|---|
| `/` | Home page con presentazione, valori e ultime recensioni |
| `/chi-sono` | Formazione, specializzazioni ed esperienze della dottoressa |
| `/servizi` | Servizi offerti e aree di intervento |
| `/articoli` | Blog — tutti gli articoli pubblicati |
| `/recensioni` | Recensioni dei clienti — lettura e scrittura |

## Pannello di amministrazione

L'area admin è accessibile digitando manualmente `/admin` nella barra dell'indirizzo del browser. **Non è raggiungibile da nessun link nel sito.**

L'autenticazione usa **Supabase Auth** (email + password). Le credenziali si gestiscono nel Supabase Dashboard → Authentication → Users.

Una volta autenticata, la sessione viene mantenuta tramite refresh token (sopravvive al ricaricamento della pagina). Il JWT scade dopo 1 ora; il refresh token ruota ad ogni utilizzo. Le sessioni possono essere invalidate immediatamente dal Supabase Dashboard.

Il pannello mostra tre tab:

### Tab "Blog"

- **Creare** un nuovo articolo (titolo, corpo, immagine opzionale)
- **Modificare** un articolo esistente
- **Eliminare** un articolo (con conferma)

Upload e cancellazione delle immagini avvengono server-side tramite la Edge Function `admin-articles`.

### Tab "Recensioni"

Le recensioni sono divise in due sezioni:

- **Da approvare** — recensioni in attesa. Per ciascuna viene mostrato il nome, cognome ed email del recensore per verificare che abbia effettivamente svolto sedute. Pulsanti: ✓ approva, ✗ rifiuta ed elimina.
- **Approvate** — recensioni visibili al pubblico. Pulsante: cestino rosso per eliminare (con conferma).

### Tab "Richieste di contatto"

Visualizza le richieste inviate tramite il form di contatto. Mostra: nome, cognome, email, titolo e messaggio. Nessun allegato viene archiviato (vedi sezione GDPR).

### Logout

Nel nav drawer del sito è presente il pulsante **Esci dalla modalità admin** quando la sessione è attiva.

---

## Architettura

Il client Flutter è uno **strato sottile senza chiavi**. Contiene solo l'URL del progetto Supabase (non è un segreto). Tutte le operazioni sui dati passano attraverso Edge Functions.

```
Flutter Client (solo URL — nessuna chiave)
    │
    ├── Supabase Auth SDK (URL only) ──► Supabase Auth  [login/logout/sessione admin]
    │
    └── HTTP calls (+ JWT per route admin)
            │
            ▼
    Supabase Edge Functions (Deno/TypeScript)
        ├── Origin header check (ALLOWED_ORIGIN)
        ├── JWT verification per route admin
        ├── Input validation + limiti di lunghezza
        └── Parameterized queries via service_role key
                │
                ├──► psyc_app schema (Postgres)
                ├──► Supabase Storage (bucket privati)
                └──► Resend API (email)
```

`lib/config/admin_config.dart` contiene solo:

```dart
class AdminConfig {
  static const String supabaseUrl = 'https://snsvamcecgizhecvtpwk.supabase.co';
  static const String functionsUrl = '$supabaseUrl/functions/v1';
  static const String supabaseAnonKey = '...';
}
```

Nessuna `service_role` key nel bundle client. La `service_role` key vive esclusivamente come Supabase project secret.

---

## Struttura del database Supabase

Tutte le tabelle sono nello schema `psyc_app` con **Row Level Security abilitata (default-deny)**. Le Edge Functions accedono tramite `service_role` (bypassa RLS). Il ruolo `anon` ha accesso solo dove esplicitamente concesso.

### Tabella `psyc_app.articoli`

| Colonna | Tipo | Note |
|---|---|---|
| `id` | bigint | Primary key, auto-increment |
| `titolo` | text | Titolo dell'articolo |
| `corpo` | text | Corpo dell'articolo |
| `pubblicato_at` | timestamptz | Data di pubblicazione |
| `immagine_url` | text | URL immagine (opzionale) |

Policy RLS: `anon` può fare `SELECT` (tutti gli articoli). Scrittura/eliminazione: `service_role` via Edge Function.

### Tabella `psyc_app.reviews`

| Colonna | Tipo | Note |
|---|---|---|
| `id` | bigint | Primary key, auto-increment |
| `email` | text | Email del recensore (unique, FK → `reviewer_users.email`) |
| `username` | text | Nome pubblico visualizzato nella recensione |
| `title` | text | Titolo della recensione |
| `description` | text | Testo della recensione |
| `stars` | int4 | Valutazione da 1 a 5 (check constraint) |
| `created_at` | timestamptz | Data di creazione |
| `approved` | boolean | false = in attesa, true = approvata (default false) |

Policy RLS: `anon` può fare `SELECT` dove `approved = true`. Tutto il resto: `service_role` via Edge Function.

### Tabella `psyc_app.reviewer_users`

| Colonna | Tipo | Note |
|---|---|---|
| `id` | bigint | Auto-increment |
| `email` | text | **Primary key** — email del recensore |
| `username` | text | Nome pubblico (unique, not null) |
| `name` | text | Nome reale (non visibile in UI pubblica) |
| `surname` | text | Cognome reale (non visibile in UI pubblica) |
| `created_at` | timestamptz | Data di registrazione |

Nessun accesso `anon`. Solo `service_role` via Edge Function.

### Tabella `psyc_app.email_approval`

| Colonna | Tipo | Note |
|---|---|---|
| `id` | bigint | Auto-increment |
| `email` | text | Email del richiedente |
| `token` | text | Token UUID one-time use |
| `expires_at` | timestamptz | Scadenza del token (1 ora) |

Usata per il flusso magic-link. Il token viene cancellato al primo utilizzo o alla scadenza. Nessun accesso `anon`.

### Tabella `psyc_app.contact_requests`

| Colonna | Tipo | Note |
|---|---|---|
| `id` | bigint | Primary key, auto-increment |
| `name` | text | Nome del richiedente |
| `surname` | text | Cognome del richiedente |
| `email` | text | Email di contatto |
| `title` | text | Oggetto della richiesta |
| `message` | text | Testo del messaggio |
| `created_at` | timestamptz | Data di invio |

Nessuna colonna per allegati o URL. Nessun accesso `anon`. Solo `service_role` via Edge Function.

---

## Flusso recensioni (magic-link)

1. L'utente compila il form con email, username, nome, cognome.
2. La Edge Function `send-review-magic-link` invia un link di conferma via email.
3. L'utente clicca il link — il token viene verificato da `verify-review-token` (scade dopo 1 ora, cancellato al primo uso).
4. L'utente compila il form con stelle, titolo e descrizione e invia.
5. La Edge Function `submit-review` salva la recensione (non approvata) e notifica l'admin via email.
6. L'admin accede al pannello `/admin` e approva o rifiuta la recensione.

---

## Flusso richiesta di contatto (GDPR Article 9)

Il form di contatto permette l'allegato della tessera sanitaria (dato sanitario speciale ex art. 9 GDPR). Il trattamento è **transiente**:

1. L'allegato viene caricato nel bucket privato `contact-attachments` (nessun URL pubblico).
2. Viene inviato come allegato all'email admin tramite Resend (HTTPS).
3. L'allegato viene **eliminato immediatamente dallo storage** — indipendentemente dall'esito dell'invio email.
4. Il record salvato in `contact_requests` contiene solo: nome, cognome, email, titolo, messaggio — **nessun riferimento all'allegato**.

Il bucket `contact-attachments` deve essere vuoto a riposo. Qualsiasi file trovato è un orfano da un cleanup fallito e va eliminato manualmente.

---

## Edge Functions Supabase

Le Edge Functions sono in `supabase/functions/`. Richiedono la [Supabase CLI](https://supabase.com/docs/guides/cli).

### Funzioni pubbliche (origin check, nessun JWT)

| Function | Method | Descrizione |
|---|---|---|
| `get-articles` | GET | Restituisce tutti gli articoli, o uno singolo se `?id=` fornito |
| `get-approved-reviews` | GET | Restituisce solo le recensioni approvate |
| `send-contact-request` | POST | Valida il form, invia email admin con allegato, elimina allegato, salva record |
| `send-review-magic-link` | POST | Genera token one-time, invia magic link via email |
| `verify-review-token` | POST | Valida token, applica scadenza 1 ora, cancella al primo uso |
| `submit-review` | POST | Inserisce recensione non approvata in `psyc_app.reviews` |

### Funzioni admin (origin check + JWT verification)

Il JWT viene verificato via `supabase.auth.getUser(jwt)` ad ogni chiamata. JWT non valido o scaduto → `401`.

| Function | Method | Descrizione |
|---|---|---|
| `admin-articles` | POST | Create/update/delete articoli; gestisce upload/delete immagini server-side |
| `admin-reviews` | POST | Legge tutte le recensioni, approva, elimina |
| `admin-contact-requests` | POST | Legge le richieste di contatto (solo campi form, mai URL allegati) |

### Comportamento comune (tutte le funzioni)

- Verifica header `Origin` contro `ALLOWED_ORIGIN` → `403` senza corpo se mismatch
- Valida i campi obbligatori e applica limiti di lunghezza prima di qualsiasi operazione DB
- Non restituisce mai dati sensibili al client
- Log errori solo server-side; restituisce `500` generico al client per errori DB/servizi esterni

### Deploy

```bash
supabase login
supabase link --project-ref snsvamcecgizhecvtpwk

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

---

## Secrets (variabili d'ambiente)

Tutti i segreti vivono come Supabase project secrets (Dashboard → Edge Functions → Secrets). Nessuno è nel repository.

```bash
supabase secrets set \
  SUPABASE_SERVICE_ROLE_KEY=<service_role_key> \
  ALLOWED_ORIGIN=https://riccardo-cpt.github.io \
  RESEND_API_KEY=re_xxxxxxxxxxxx \
  SITE_URL=https://riccardo-cpt.github.io \
  RESEND_FROM_EMAIL=noreply@tuodominio.com \
  ADMIN_EMAIL=admin@tuodominio.com
```

| Secret | Descrizione |
|---|---|
| `SUPABASE_SERVICE_ROLE_KEY` | Chiave di accesso DB — ruotare prima del deploy |
| `ALLOWED_ORIGIN` | Origine consentita per le richieste (es. `https://riccardo-cpt.github.io`) |
| `RESEND_API_KEY` | API key di Resend |
| `SITE_URL` | URL pubblico del sito — usato per costruire il magic link |
| `RESEND_FROM_EMAIL` | Indirizzo mittente (deve essere su dominio verificato in Resend) |
| `ADMIN_EMAIL` | Email dell'admin che riceve le notifiche |

`SUPABASE_URL` è iniettato automaticamente da Supabase — non va impostato manualmente.

Per verificare i secrets già impostati:

```bash
supabase secrets list
```

---

## Configurazione Resend (invio email)

[Resend](https://resend.com) è il servizio usato per inviare le email transazionali (magic link, notifica recensione, notifica richiesta di contatto).

### 1. Ottenere l'API key

1. Registrarsi su [resend.com](https://resend.com) e creare un account.
2. Andare in **API Keys** → **Create API Key**.
3. Copiare la chiave generata (inizia con `re_`) e usarla come valore di `RESEND_API_KEY`.

### 2. Verificare il dominio mittente

Resend richiede di verificare il dominio da cui si inviano le email.

1. Andare in **Domains** → **Add Domain** nel pannello Resend.
2. Inserire il proprio dominio.
3. Aggiungere i record DNS (TXT e MX) indicati nel pannello del registrar.
4. Attendere la verifica (da pochi minuti a qualche ora).

> **Piano gratuito Resend:** 3.000 email/mese, limite 100/giorno. Sufficiente per un sito con traffico normale.

---

## Sviluppo locale

```bash
flutter pub get
flutter run -d chrome
```

Per build di produzione:

```bash
flutter build web
```

Le Edge Functions in locale richiedono [Supabase CLI](https://supabase.com/docs/guides/cli) e Docker:

```bash
supabase start
supabase functions serve
```
