# ⚡ Pokémon GCC Local Tracker (Mobile App)

Applicazione mobile nativa sviluppata in **Flutter & Dart** con interfaccia in lingua italiana, specificamente creata per i giocatori del **Gioco di Carte Collezionabili (GCC) Pokémon** che partecipano a tornei "Local" in fumetteria (*League Challenge*, *League Cup*, tornei amatoriali e pre-release).

---

## 🎨 Tema e Design Pokémon TCG

L'interfaccia adotta un design moderno, pulito e scuro (stile *Ultra Pro Deck Box* e tavoli di gioco da torneo) con accenti cromatici ispirati alle Energie e dinamiche Pokémon:
- 🟢 **[W] Vittoria**: Verde Energia Erba (`#16A34A` / `#22C55E`)
- 🔴 **[L] Sconfitta**: Rosso Energia Fuoco / Pokédex (`#DC2626` / `#EF4444`)
- 🟡 **[D] Pareggio**: Giallo/Ambra Energia Lampo (`#D97706` / `#F59E0B`)
- 🔵 **Lega & Brand**: Blu Pokémon (`#1D4ED8` / `#3B82F6`) ed oro Ultra Ball (`#F59E0B`)

---

## 📱 Struttura e Flusso dell'Interfaccia

1. **Sezione Info Torneo (In Alto)**:
   - **Data dell'evento**: DatePicker con calendario localizzato in italiano (`it_IT`) e pulsante di cambio rapido.
   - **Tipo di Evento**: Campo di testo con chip di selezione rapida (*League Challenge*, *League Cup*, *Torneo Amatoriale*, *Pre-Release*, *Special Event*).
   - **Mazzo Utilizzato**: Campo di testo con suggerimenti rapidi per i principali mazzi del meta attuale (*Charizard ex / Pidgeot ex*, *Gardevoir ex*, *Dragapult ex*, *Miraidon ex*, *Raging Bolt ex*, *Lugia VSTAR*, ecc.).

2. **Sezione Selezione Turni (Menu a tendina)**:
   - Dropdown da **1 ad 8 turni** (formato svizzera standard).
   - Cambio reattivo: la modifica del numero di turni espande o riduce la lista preservando i mazzi e i risultati già inseriti.

3. **Sezione Dinamica Match (Generata in base ai turni 1..8)**:
   - Ciascuna riga è disposta orizzontalmente (`Row`):
     - **Parte Sinistra**: Etichetta `"vs"` affiancata dal campo di testo per specificare il mazzo dell'avversario.
     - **Parte Destra**: Etichetta `"Risultato"` con 3 cerchi selezionabili ad accesso esclusivo:
       - **[W]** (Verde per Vittoria)
       - **[L]** (Rosso per Sconfitta)
       - **[D]** (Giallo/Ambra per Pareggio)
     - Toccando un cerchio si seleziona il risultato deselezionando gli altri; toccando nuovamente il cerchio attivo è possibile annullare la selezione.

4. **Sezione Statistica Finale (Immediatamente sotto i match)**:
   - **Score Finale (W - L - D)**: Calcolato **automaticamente in tempo reale** in base ai pallini selezionati (es. `3 - 1 - 0`), con calcolo della percentuale di Win Rate. Include un pulsante *"Modifica / Auto"* per inserire manualmente score speciali (es. Bye in Top Cut).
   - **Posizione Finale**: Campo con chip veloci (*1° posto*, *2° posto*, *Top 4*, *Top 8*).
   - **Punti Ottenuti**: Campo per Championship Points o premi del negozio (*15 CP*, *10 CP*, *50 Punti Store*).

5. **Sezione Retrospettiva (In Basso)**:
   - Due box di testo multilinea (TextArea) ampi, spaziosi e distinti:
     - 🚀 **"Ha funzionato"**: Per annotare punti di forza del mazzo, buone combo e partenze vincenti.
     - ⚠️ **"Da migliorare"**: Per annotare misplay, carte morte e cambi da effettuare nella decklist per il prossimo evento.

6. **Azione Finale & Storico**:
   - Pulsante evidente in fondo: **"Salva Report Torneo"**.
   - Validazione dei campi obbligatori.
   - Salvataggio locale persistente su memoria del dispositivo.
   - Schermata **"Storico Tornei"** consultabile tramite l'icona in alto a destra, con record carriera aggregato, winrate globale, dettagli di ciascun match ed opzioni di modifica o eliminazione.

---

## 📂 Architettura del Codice

```
lib/
├── main.dart                          # Inizializzazione, localizzazione italiana (it_IT), routing
├── theme/
│   └── app_theme.dart                 # Palette TCG, stili Material 3 e chip W/L/D
├── models/
│   ├── match_round.dart               # Modello del singolo turno e enum MatchOutcome (W, L, D, none)
│   └── tournament_report.dart         # Modello del report torneo con serializzazione JSON e calcolo score
├── services/
│   └── storage_service.dart           # Persistenza locale con SharedPreferences
├── widgets/
│   ├── tournament_info_card.dart      # Sezione 1: Data, Tipo Evento, Mazzo Usato
│   ├── rounds_selector.dart           # Sezione 2: Dropdown 1..8 turni
│   ├── match_row_card.dart            # Sezione 3: Riga turno "vs" + chip [W] [L] [D]
│   ├── final_stats_card.dart          # Sezione 4: Score W-L-D live, Posizione, Punti
│   └── retrospective_card.dart        # Sezione 5: Box multilinea "Ha funzionato" e "Da migliorare"
└── screens/
    ├── tournament_entry_screen.dart   # Schermata principale di inserimento report
    └── tournament_history_screen.dart # Schermata dello storico dei tornei salvati
```

---

## 🚀 Istruzioni per Avviare l'App in Sviluppo

1. Assicurati di avere un dispositivo Android collegato via USB (con *Debug USB* attivo) o un emulatore avviato.
2. Esegui:
   ```bash
   flutter run
   ```
3. Seleziona il dispositivo di destinazione (oppure Chrome per test su browser web).

---

## 📦 Istruzioni per la Build dell'APK Android (Flutter)

### Prerequisito (Licenze Android SDK):
Se non l'hai già fatto in precedenza, accetta le licenze dell'Android SDK:
```bash
flutter doctor --android-licenses
```
*(Premi `y` per ciascuna licenza richiesta).*

### 1. Build APK Release (File Unico Universale)
Genera un file APK completo e autonomo, installabile su qualsiasi smartphone o tablet Android:
```bash
flutter build apk --release
```

Al termine della compilazione, il file APK pronto per l'installazione si troverà in:
```
build/app/outputs/flutter-apk/app-release.apk
```

### 2. Build APK Ottimizzati per Architettura (Split per ABI)
Se desideri APK più leggeri suddivisi per CPU del dispositivo (es. ARM a 64 bit):
```bash
flutter build apk --split-per-abi
```
Questo comando genererà tre file in `build/app/outputs/flutter-apk/`:
- `app-arm64-v8a-release.apk` (per la maggior parte degli smartphone moderni)
- `app-armeabi-v7a-release.apk` (per dispositivi a 32 bit più datati)
- `app-x86_64-release.apk` (per emulatori PC)

### 3. Come Installare l'APK sul Telefono
- **Metodo Diretto via ADB (cavo USB)**:
  ```bash
  adb install -r build/app/outputs/flutter-apk/app-release.apk
  ```
- **Metodo Manuale**:
  Invia il file `app-release.apk` al tuo smartphone (tramite cavo USB, Google Drive, WhatsApp o Telegram) e aprilo sul telefono per installarlo (consenti l'installazione da "Origini sconosciute" se richiesto da Android).

---

## 🔄 Nota Alternativa: Configurazione ed Esportazione in React Native (Expo)

Se per future esigenze volessi sviluppare l'equivalente anche in React Native (Expo):
1. Inizializzazione progetto:
   ```bash
   npx create-expo-app pokemon-gcc-tracker --template blank-typescript
   ```
2. Build APK Android tramite Expo Application Services (EAS):
   ```bash
   npm install -g eas-cli
   eas login
   eas build:configure
   eas build -p android --profile preview
   ```
   L'APK verrà compilato nel cloud di Expo e ti fornirà un link diretto e un QR Code per scaricarlo sul telefono.

---

## ✅ Verifica e Test

Il progetto è verificato e coperto da test automatizzati:
- `flutter analyze` : **0 errori, 0 warning**
- `flutter test` : **Tutti i test superati (unitari e di interfaccia grafica)**
