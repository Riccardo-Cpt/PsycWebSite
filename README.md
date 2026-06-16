# Dr.ssa Maria Bianchi — Sito Web

Sito web professionale per la Dr.ssa Maria Bianchi, Psicologa e Psicoterapeuta. Sviluppato con Flutter Web e Supabase come backend.

## Pagine pubbliche

| Percorso | Descrizione |
|---|---|
| `/` | Home page con presentazione, valori e ultimo articolo del blog |
| `/servizi` | Servizi offerti |
| `/articoli` | Blog — tutti gli articoli pubblicati |
| `/recensioni` | Recensioni dei clienti — lettura e scrittura |

## Pannello di amministrazione

L'area admin è accessibile digitando manualmente `/admin` nella barra dell'indirizzo del browser. **Non è raggiungibile da nessun link nel sito.**

**Password:** `admin123`  
*(modificabile in `lib/config/admin_config.dart`)*

Una volta autenticato, la sessione rimane attiva per tutta la navigazione fino al ricaricamento della pagina o al logout manuale.

### Gestione articoli del blog

1. Accedere a `/admin` e inserire la password.
2. Dal pannello, cliccare **Gestisci blog** per andare alla pagina `/articoli`.
3. In alternativa, navigare direttamente a `/articoli/admin`.

Dalla sezione **Blog** del pannello admin è possibile:
- **Creare** un nuovo articolo (titolo, corpo, immagine opzionale)
- **Modificare** un articolo esistente
- **Eliminare** un articolo (con conferma)

### Gestione recensioni

1. Accedere a `/admin` e inserire la password.
2. Dal pannello, cliccare **Gestisci recensioni** per andare alla pagina `/recensioni`.

Con la sessione admin attiva, su ogni recensione appare un pulsante **cestino rosso** per eliminarla (con conferma).

### Logout

Dal pannello `/admin`, cliccare **Esci dalla modalità admin** in fondo alla pagina.

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
