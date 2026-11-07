import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon_gcc_tracker/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Verifica renderizzazione completa di tutte le sezioni del report torneo',
      (WidgetTester tester) async {
    // Imposta una dimensione tipica di smartphone moderno
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Carica l'applicazione
    await tester.pumpWidget(const PokemonGccTrackerApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verifica schermata iniziale: Storico Tornei con titolo Channel GCC Report
    expect(find.text('Channel GCC Report'), findsOneWidget);

    // Verifica presenza della barra azioni rapide Mazzi e Location
    expect(find.text('Mazzi'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);

    // Verifica presenza del tasto Esporta Dati nell'AppBar
    expect(find.byTooltip('Esporta Dati'), findsOneWidget);

    // Verifica link Privacy Policy & Note Legali Store
    expect(find.text('Privacy Policy & Note Legali Store'), findsOneWidget);

    // Tocca il pulsante '+' in alto a destra per creare un nuovo report
    await tester.tap(find.byTooltip('Nuovo Report'));
    await tester.pumpAndSettle();

    // 1. Verifica Sezione Info Torneo
    expect(find.text('Info Torneo'), findsOneWidget);
    expect(find.text("Data dell'evento"), findsOneWidget);
    expect(find.text('Tipo di Evento'), findsOneWidget);
    expect(find.text('Location (Fumetteria / Negozio)'), findsOneWidget);
    expect(find.text('Mazzo Utilizzato'), findsOneWidget);

    // 2. Verifica Sezione Selezione Turni
    expect(find.text('Numero di Turni (Svizzera)'), findsOneWidget);

    // 3. Verifica Sezione Dinamica Match (default 3 turni)
    expect(find.text('Turno 1'), findsOneWidget);
    expect(find.text('Turno 2'), findsOneWidget);
    expect(find.text('Turno 3'), findsOneWidget);
    expect(find.text('vs'), findsNWidgets(3));
    expect(find.text('Risultato'), findsNWidgets(3));
    expect(find.text('W'), findsNWidgets(3));
    expect(find.text('L'), findsNWidgets(3));
    expect(find.text('D'), findsNWidgets(3));
    expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsNWidgets(3));

    // 4. Verifica Sezione Statistica Finale
    expect(find.text('Statistica Finale'), findsOneWidget);
    expect(find.text('Score Finale (W - L - D)'), findsOneWidget);
    expect(find.text('Numero di Partecipanti'), findsOneWidget);
    expect(find.text('Posizione Finale'), findsOneWidget);
    expect(find.text('Punti Ottenuti (CP / Punti Fumetteria)'), findsOneWidget);

    // 5. Verifica Sezione Retrospettiva
    expect(find.text('Ha funzionato'), findsOneWidget);
    expect(find.text('Da migliorare'), findsOneWidget);

    // 6. Verifica Footer
    expect(find.text('Powered By Antonio Canale - BETA'), findsOneWidget);

    // 6. Verifica Pulsante Salva Report Torneo
    expect(find.text('Salva Report Torneo'), findsOneWidget);

    // Test interazione con chip [W] del Turno 1
    final firstWChip = find.text('W').first;
    await tester.ensureVisible(firstWChip);
    await tester.pumpAndSettle();
    await tester.tap(firstWChip);
    await tester.pumpAndSettle();

    // Lo score automatico riflette la vittoria
    expect(find.text('1 W'), findsOneWidget);
    expect(find.text('0 L'), findsOneWidget);
    expect(find.text('0 D'), findsOneWidget);
    expect(find.text('Win Rate: 100%'), findsOneWidget);
  });
}
