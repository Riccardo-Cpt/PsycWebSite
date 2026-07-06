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

**Password:** `admin123`  
*(modificabile in `lib/config/admin_config.dart`)*

Una volta autenticata, la sessione rimane attiva per tutta la navigazione fino al ricaricamento della pagina o al logout manuale.

Il pannello mostra due tab:

### Tab "Blog"

- **Creare** un nuovo articolo (titolo, corpo, immagine opzionale)
- **Modificare** un articolo esistente
- **Eliminare** un articolo (con conferma)

### Tab "Recensioni"

Le recensioni sono divise in due sezioni:

- **Da approvare** — recensioni in attesa. Per ciascuna viene mostrato il nome, cognome ed email del recensore per verificare che abbia effettivamente svolto sedute. Pulsanti: ✓ approva, ✗ rifiuta ed elimina.
- **Approvate** — recensioni visibili al pubblico. Pulsante: cestino rosso per eliminare (con conferma).

### Logout

Nel nav drawer del sito è presente il pulsante **Esci dalla modalità admin** quando la sessione è attiva.

---

## Struttura del database Supabase

### Tabella `articoli`

| Colonna | Tipo | Note |
|---|---|---|
| `id` | int8 | Primary key, auto-increment |
| `titolo` | text | Titolo dell'articolo |
| `corpo` | text | Corpo dell'articolo |
| `pubblicato_at` | timestamptz | Data di pubblicazione |
| `immagine_url` | text | URL immagine (opzionale) |

Accesso in lettura: anon key. Scrittura/eliminazione: service role key.

### Tabella `reviews`

| Colonna | Tipo | Note |
|---|---|---|
| `id` | int8 | Primary key, auto-increment |
| `email` | text | Email del recensore (unique, FK → `reviewer_users.email`) |
| `username` | text | Nome pubblico visualizzato nella recensione |
| `title` | text | Titolo della recensione |
| `description` | text | Testo della recensione |
| `stars` | int4 | Valutazione da 1 a 5 (check constraint) |
| `created_at` | timestamptz | Data di creazione |
| `approved` | boolean | false = in attesa, true = approvata (default false) |

Accesso in lettura pubblico: anon key, filtra `approved=eq.true`. Lettura admin e scrittura/eliminazione: service role key.

**Row Level Security:** RLS deve essere abilitato con la seguente policy:

```sql
CREATE POLICY "public read approved reviews"
ON reviews
FOR SELECT
USING (approved = true);
```

### Tabella `reviewer_users`

| Colonna | Tipo | Note |
|---|---|---|
| `id` | int8 | Auto-increment |
| `email` | text | **Primary key** — email del recensore |
| `username` | text | Nome pubblico (unique, not null) |
| `name` | text | Nome reale (non visibile in UI pubblica) |
| `surname` | text | Cognome reale (non visibile in UI pubblica) |
| `created_at` | timestamptz | Data di registrazione |

### Tabella `email_approval`

| Colonna | Tipo | Note |
|---|---|---|
| `id` | int8 | Auto-increment |
| `email` | text | Email del richiedente |
| `token` | text | Token UUID one-time use |
| `expires_at` | timestamptz | Scadenza del token (1 ora) |

Usata per il flusso magic-link: il token viene generato all'invio del form e cancellato dopo la verifica o alla scadenza.

---

## Flusso recensioni (magic-link)

1. L'utente compila il form con email, username, nome, cognome.
2. La edge function `send-review-magic-link` invia un link di conferma via email.
3. L'utente clicca il link — il token viene verificato da `verify-review-token`.
4. L'utente compila il form con stelle, titolo e descrizione e invia.
5. La edge function `submit-review` salva la recensione (non approvata) e notifica l'admin via email.
6. L'admin accede al pannello `/admin` e approva o rifiuta la recensione.

---

## Edge Functions Supabase

Le edge functions sono in `supabase/functions/`. Richiedono la [Supabase CLI](https://supabase.com/docs/guides/cli).

### Deploy

```bash
supabase login
supabase link --project-ref <project-ref>

supabase functions deploy send-review-magic-link
supabase functions deploy verify-review-token
supabase functions deploy submit-review
```

Il `<project-ref>` si trova in Supabase Dashboard → Project Settings → General → Reference ID.

### Secrets (variabili d'ambiente)

Le edge functions leggono queste variabili da Supabase Secrets:

```bash
supabase secrets set \
  RESEND_API_KEY=re_xxxxxxxxxxxx \
  SITE_URL=https://tuodominio.com \
  RESEND_FROM_EMAIL=noreply@tuodominio.com \
  ADMIN_EMAIL=admin@tuodominio.com
```

| Secret | Descrizione |
|---|---|
| `RESEND_API_KEY` | API key di Resend (vedi sezione sotto) |
| `SITE_URL` | URL pubblico del sito — usato per costruire il magic link |
| `RESEND_FROM_EMAIL` | Indirizzo mittente delle email (deve essere su dominio verificato in Resend) |
| `ADMIN_EMAIL` | Email dell'admin che riceve le notifiche di nuove recensioni |

`SUPABASE_URL` e `SUPABASE_SERVICE_ROLE_KEY` sono iniettati automaticamente da Supabase — non vanno impostati manualmente.

Per verificare i secrets già impostati:

```bash
supabase secrets list
```

---

## Configurazione Resend (invio email)

[Resend](https://resend.com) è il servizio usato per inviare le email transazionali (magic link e notifica admin).

### 1. Ottenere l'API key

1. Registrarsi su [resend.com](https://resend.com) e creare un account.
2. Andare in **API Keys** → **Create API Key**.
3. Copiare la chiave generata (inizia con `re_`) e usarla come valore di `RESEND_API_KEY`.

### 2. Verificare il dominio mittente

Resend richiede di verificare il dominio da cui si inviano le email. **Non è necessario creare una casella email** — basta aggiungere record DNS al proprio dominio.

1. Andare in **Domains** → **Add Domain** nel pannello Resend.
2. Inserire il proprio dominio (es. `tuodominio.com`).
3. Resend mostrerà una serie di record DNS (TXT e MX) da aggiungere nel pannello del proprio registrar di dominio (es. GoDaddy, Namecheap, Cloudflare).
4. Attendere la verifica (da pochi minuti a qualche ora).
5. Una volta verificato, si può usare qualsiasi indirizzo su quel dominio come mittente (es. `noreply@tuodominio.com`).

> **Piano gratuito Resend:** 3.000 email/mese, limite 100/giorno. Sufficiente per un sito con traffico normale. In alternativa al dominio proprio, si può usare `onboarding@resend.dev` solo per test.

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
