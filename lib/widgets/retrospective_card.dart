import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Sezione Retrospettiva con due box di testo multilinea distinti, alti e ben spaziati:
/// 1. "Ha funzionato" (punti di forza, buone combo, matchup favorevoli)
/// 2. "Da migliorare" (misplay, modifiche decklist, carte da tagliare/sostituire)
class RetrospectiveCard extends StatelessWidget {
  final TextEditingController whatWorkedController;
  final TextEditingController toImproveController;

  const RetrospectiveCard({
    super.key,
    required this.whatWorkedController,
    required this.toImproveController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titolo sezione
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.pokemonBlueLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.psychology_outlined,
                    color: AppTheme.pokemonBlueLight,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Retrospettiva & Note',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Analizza le partite per migliorare nei prossimi tornei',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // BOX 1: "Ha funzionato"
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.winGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Ha funzionato',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.winGreenLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Punti di forza del mazzo, combo vincenti, buone partenze, sinergie efficaci...',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: whatWorkedController,
              minLines: 4,
              maxLines: 8,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(fontSize: 14, height: 1.4),
              decoration: InputDecoration(
                hintText: 'Scrivi cosa ha girato bene nel torneo...\nes. Ottime partenze con Pidgeot ex; buona gestione delle risorse contro mazzi controllo; la tech card ha chiuso la partita al turno 3.',
                hintMaxLines: 4,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.winGreenLight, width: 1.8),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // BOX 2: "Da migliorare"
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.lossRedLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.priority_high, size: 14, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Da migliorare',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.lossRedLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Errori di gioco (misplay), carte morte in mano, cambi da fare nella decklist...',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: toImproveController,
              minLines: 4,
              maxLines: 8,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(fontSize: 14, height: 1.4),
              decoration: InputDecoration(
                hintText: 'Scrivi cosa non ha funzionato o dove puoi migliorare...\nes. Misplay al turno 2 non considerando la ritirata avversaria; 2 carte morte contro Dragapult; aggiungere 1 Scambio o 1 Recupero di Energia.',
                hintMaxLines: 4,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.lossRedLight, width: 1.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
