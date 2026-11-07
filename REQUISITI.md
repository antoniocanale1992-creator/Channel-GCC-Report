# Specifiche e Requisiti di Progetto: Channel GCC Report

Documento ufficiale contenente i requisiti utente (funzionali) e i requisiti tecnici (architetturali e di sicurezza) per l'applicazione **Channel GCC Report** (Pokémon TCG Local Tracker).

---

## 1. Visione Generale del Progetto

**Channel GCC Report** è una Progressive Web App (PWA) e applicazione mobile multi-piattaforma creata per i giocatori competitivi e amatoriali del **Gioco di Carte Collezionabili Pokémon (GCC / TCG)**.

L'obiettivo è consentire ai giocatori di:
1. Registrare in modo rapido e guidato ogni torneo disputato (League Challenge, League Cup, tornei amatoriali in fumetteria, Regionali).
2. Tenere traccia del mazzo utilizzato, della location, del piazzamento e dei punteggi Championship Points (CP).
3. Annotare per ciascun turno il mazzo avversario, l'esito della partita e le **considerazioni/impressioni tattiche** di gioco.
4. Funzionare in modalità **Offline-First pura**, garantendo piena usabilità anche all'interno di fumetterie o sale torneo prive di connessione cellulare o Wi-Fi.
5. Sincronizzare i propri dati nel cloud tramite Google Sign-In con isolamento crittografico per singolo utente su Cloud Firestore.
6. Installare l'app su smartphone (iOS e Android) direttamente dal web browser con interfaccia identica ad un'app nativa.

---

## 2. Requisiti Utente & Funzionali

### 2.1 Gestione & Compilazione Report Torneo
- **Data dell'evento**: Selezione tramite DatePicker con default impostato alla data odierna.
- **Tipo di Evento**: Selezione rapida o testo personalizzato (default *"Local"*, con supporto per *"League Challenge"*, *"League Cup"*, *"Prerelease"*, *"Regionals"*).
- **Location / Fumetteria**: Selezione rapida da un elenco di fumetterie precedentemente salvate o inserimento testuale libero.
- **Mazzo Utilizzato**: Selezione rapida da un mazzo registrato nel Deck Manager o inserimento manuale.
- **Selezione Dinamica dei Turni (Svizzera)**:
  - Menu a tendina per selezionare da **1 a 8 turni**.
  - Alla variazione del numero, l'interfaccia aggiorna istantaneamente i campi dei match mantenendo intatti i dati già digitati nei turni precedenti.
- **Campi per Singolo Turno**:
  - Indicazione visiva del turno: *"Turno X"* con badge cromatico.
  - Mazzo avversario: campo di testo con suggerimento (es. *"Gardevoir ex"*, *"Lugia VSTAR"*).
  - Risultato match: tre selettori a cerchio interattivi ad alto contrasto:
    - **[W]** Verde (Vittoria)
    - **[L]** Rosso (Sconfitta)
    - **[D]** Ambra (Pareggio)
  - **Considerazioni per Turno**: Campo testuale multilinea con icona a nuvoletta dedicato a pensieri, errori, giocate chiave o cosa ha funzionato in quel match.
- **Statistica Finale & Posizionamento**:
  - Calcolo automatico dello score $W - L - D$ e della Win Rate in tempo reale.
  - Opzione per forzare uno Score manuale (es. in caso di Bye o squalifiche).
  - Numero di partecipanti e posizione finale raggiunta (es. *"Top 4"* o *"15°"*), con calcolo della posizione relativa (*"15/24"*).
  - Punti ottenuti (CP o crediti negozio).
- **Retrospettiva Finale**:
  - Sezione *"Ha Funzionato"* (punti di forza del mazzo e giocate vincenti).
  - Sezione *"Da Migliorare"* (errori commessi, carte morte o tech da sostituire).

### 2.2 Consultazione & Storico Tornei ("Tornei Disputati")
- **Dashboard Statistiche Globali**:
  - Totale tornei disputati, vittorie complessive, sconfitte, pareggi e Win Rate aggregata percentuale.
- **Ispezione Torneo Disputato**:
  - Scheda espandibile (ExpansionTile) per ciascun torneo con badge cromatico del mazzo, data, location, piazzamento e score con color-coding intelligente (Verde per Top 8 o WR > 60%, Giallo per 40-60%, Rosso per < 40%).
- **Dropdown Considerazioni per Turno**:
  - Per garantire la massima pulizia visiva, le considerazioni scritte per ogni turno non occupano spazio fisso: sono visualizzabili al tocco tramite un apposito pulsante con icona a nuvoletta e freccia dropdown. Se un turno non ha considerazioni, la riga rimane compatta.
- **Azioni sul Report**: Modifica completa con ripopolamento dei campi o eliminazione con dialog di conferma.

### 2.3 Gestione Mazzi (Deck Manager)
- Creazione, modifica ed eliminazione mazzi.
- Supporto per incollare decklist complete in formato ufficiale Pokémon TCG (Pokémon / Allenatori / Energie).
- Calcolo automatico e conteggio delle carte del mazzo (obiettivo standard 60 carte).

### 2.4 Gestione Location & Fumetterie (Location Manager)
- Salvataggio delle fumetterie preferite con nome, tipologia e indirizzo.
- Avvio rapido della navigazione stradale su Google Maps tramite intent esplicito.

### 2.5 Esportazione, Backup & Condivisione
- **Backup JSON**: Esportazione strutturata di tutti i dati per conservazione locale o trasferimento su altro dispositivo.
- **Ripristino JSON**: Importazione sicura con validazione schema e conferma preventiva.
- **Riepilogo Testuale WhatsApp**: Generazione di un testo formattato completo di emoji, record carriera, elenco tornei, note dei turni e mazzi, pronto per la condivisione nelle chat o sui social.

### 2.6 Privacy, GDPR & Diritti dell'Utente
- Accessibile dal link *"Privacy Policy & Note Legali Store"* nel footer.
- **Diritto di Accesso e Portabilità (Art. 20 GDPR)**: Esportazione completa in un clic.
- **Diritto all'Oblio (Art. 17 GDPR)**: Tasto *"Elimina Account e Dati"* nella modale profilo, che cancella in modo permanente sia l'account cloud che tutti i record locali su SharedPreferences.

---

## 3. Requisiti Tecnici & Architettura di Sistema

### 3.1 Stack Tecnologico
- **Framework**: Flutter 3.x (Web, Android, iOS)
- **Linguaggio**: Dart 3.x
- **Storage Locale**: `shared_preferences` (IndexedDB / LocalStorage su Web, SharedPreferences su Android, NSUserDefaults su iOS)
- **Cloud Backend**: Google Firebase
  - **Firebase Authentication**: `firebase_auth`, `google_sign_in`
  - **Cloud Firestore**: `cloud_firestore`
  - **Firebase Hosting**: Distribuzione Single Page Application (SPA) su rete CDN globale Google
- **Iconografia & Grafica**: Material Icons + Canvas vettoriale personalizzato (`PokemonTcgBadge`)

### 3.2 Modalità Offline-First
- L'applicazione memorizza sempre prima in locale su `StorageService`.
- Se l'utente non è autenticato o il dispositivo è privo di connessione, tutte le operazioni di scrittura e lettura funzionano regolarmente senza generare errori bloccanti.
- In presenza di connessione e utente loggato, `SyncService` invia automaticamente una copia cifrata al database Cloud Firestore.

### 3.3 Autenticazione Universale Google
- **Ambiente Web / PWA**: Utilizzo del flusso nativo `FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider())`, garantendo compatibilità con browser mobile (Safari su iOS, Chrome su Android) senza richiedere certificati SHA o bundle app.
- **Ambiente Mobile Nativo**: Utilizzo di `GoogleSignIn.signIn()` con scambio di credenziali OAuth `GoogleAuthProvider.credential(...)`.
- **Sicurezza Client**: Accesso sicuro a `FirebaseAuth` tramite getter incapsulato con fallback su ID locale in ambienti di test o offline.

### 3.4 Isolamento Dati Cloud Firestore
Ogni documento appartiene strettamente all'utente titolare:
```text
users/{userId}/tornei/{torneoId}
users/{userId}/mazzi/{mazzoId}
users/{userId}/locations/{locationId}
```
L'accesso è regolato dalle regole di sicurezza pubblicate su Firebase (`firestore.rules`):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /config/app_status {
      allow read: if true;
      allow write: if false;
    }
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### 3.5 Remote Kill Switch di Emergenza
- Lettura asincrona e non bloccante all'avvio su `config/app_status`.
- Proprietà controllate:
  - `is_active` (`bool`): se `false`, l'app blocca l'accesso e visualizza `MaintenanceScreen`.
  - `maintenance_message` (`string`): messaggio personalizzato mostrato all'utente.
- Timeout di salvaguardia di 4 secondi per impedire schermate bianche se offline o in presenza di connettività instabile.

### 3.6 Progressive Web App (PWA)
- **Manifest (`web/manifest.json`)**:
  - `name`: *"Channel GCC Report"*
  - `short_name`: *"Channel GCC"*
  - `display`: *"standalone"* (assenza di barre del browser e comandi di sistema)
  - `orientation`: *"portrait"*
  - `theme_color` e `background_color`: `"#0F172A"`
- **Icone PWA**:
  - Allineate al 100% all'icona ufficiale dell'APK Android (`Icon-192.png`, `Icon-512.png`, maskable 192/512 e `favicon.png`).
- **Supporto iOS Safari**:
  - Meta tag `apple-mobile-web-app-capable`, status bar `black-translucent`, touch icon dedicata.
- **Service Worker**: Caching delle risorse statiche con `flutter_service_worker.js`.

---

## 4. Design System & Identità Visiva

| Elemento | Valore HEX / Stile | Utilizzo |
| :--- | :--- | :--- |
| **Sfondo Primario** | `#0F172A` (Slate 900) | Background dell'app, schermata di caricamento e manifest |
| **Superficie Card** | `#1E293B` (Slate 800) | Sfondo di card, form e dialog |
| **Accento Primario** | `#F59E0B` (Ultra Ball Gold) | Pulsanti principali, icone evidenziate, badge e bordi attivi |
| **Accento Secondario**| `#38BDF8` (Electric Blue) | Dettagli location, intestazioni turni e badge |
| **Vittoria [W]** | `#22C55E` (Win Green) | Badge vittoria, score positivo e Top 8 |
| **Sconfitta [L]** | `#EF4444` (Loss Red) | Badge sconfitta, score negativo ed eliminazione dati |
| **Pareggio [D]** | `#FBBF24` (Draw Yellow) | Badge pareggio e score neutro |
| **Testo Primario** | `#F8FAFC` (Slate 50) | Titoli principali e valori numerici |
| **Testo Secondario**| `#94A3B8` (Slate 400) | Etichette di supporto, date e note |

---

## 5. Deployment & Release

### Produzione Live
- **URL PWA Ufficiale**: [https://channel-gcc-report.web.app](https://channel-gcc-report.web.app)
- **URL Alternativo**: [https://channel-gcc-report.firebaseapp.com](https://channel-gcc-report.firebaseapp.com)

### Procedura di Rilascio Rapido (PowerShell / One-Click)
1. Eseguire il file batch:
   ```cmd
   PUBBLICA_PWA.bat
   ```
2. Oppure da terminale:
   ```powershell
   flutter build web --release
   firebase deploy --only hosting,firestore:rules
   ```

### CI/CD Automation
- Workflow GitHub Actions in `.github/workflows/deploy_web.yml` configurato su runner Linux `ubuntu-latest` per la compilazione e il deployment continuo ad ogni push sul branch `main`.
