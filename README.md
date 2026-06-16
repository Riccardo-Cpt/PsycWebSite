# Dr.ssa Maria Bianchi — Sito Web

Sito web professionale per la Dr.ssa Maria Bianchi, Psicologa e Psicoterapeuta. Sviluppato con Flutter Web e Supabase come backend.

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
| `username` | text | Username del recensore (FK → `reviewer_users.username`) |
| `title` | text | Titolo della recensione (not null) |
| `description` | text | Testo della recensione |
| `stars` | int4 | Valutazione da 1 a 5 (check constraint) |
| `created_at` | timestamptz | Data di creazione |
| `approved` | boolean | false = in attesa di approvazione, true = approvata (default false) |

Accesso in lettura pubblico: anon key, filtra `approved=eq.true`. Lettura admin e scrittura/eliminazione: service role key.

**Row Level Security:** RLS deve essere abilitato con la seguente policy affinché le recensioni approvate siano visibili pubblicamente:

```sql
CREATE POLICY "public read approved reviews"
ON reviews
FOR SELECT
USING (approved = true);
```

Senza questa policy, Supabase restituisce un array vuoto alle chiamate con anon key anche se esistono record approvati.

### Tabella `reviewer_users`

| Colonna | Tipo | Note |
|---|---|---|
| `id` | int8 | Primary key (composita con `username`) |
| `username` | text | Username univoco (unique + not null) |
| `name` | text | Nome reale del recensore (non visibile in UI pubblica) |
| `surname` | text | Cognome reale del recensore (non visibile in UI pubblica) |
| `email` | text | Email del recensore (non visibile in UI pubblica) |
| `password_hash` | text | Hash SHA-256 della password |
| `created_at` | timestamptz | Data di registrazione |

Accesso completo: service role key. I campi `name`, `surname`, `email` vengono mostrati solo all'admin nel pannello di approvazione recensioni.

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
