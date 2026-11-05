import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Sezione Statistica Finale (subito sotto i match)
/// Include: Score W-L-D (calcolato automaticamente o modificabile), Posizione finale, Punti ottenuti
class FinalStatsCard extends StatelessWidget {
  final int wins;
  final int losses;
  final int draws;
  final bool isScoreManual;
  final ValueChanged<bool> onToggleScoreManual;
  final TextEditingController manualScoreController;
  final TextEditingController participantsController;
  final TextEditingController placementController;
  final TextEditingController pointsController;

  const FinalStatsCard({
    super.key,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.isScoreManual,
    required this.onToggleScoreManual,
    required this.manualScoreController,
    required this.participantsController,
    required this.placementController,
    required this.pointsController,
  });

  static const List<String> participantsPresets = [
    '8',
    '12',
    '16',
    '24',
    '32',
    '64',
  ];

  static const List<String> placementPresets = [
    '1° posto',
    '2° posto',
    'Top 4',
    'Top 8',
  ];

  static const List<String> pointsPresets = [
    '15 CP',
    '10 CP',
    '5 CP',
    '50 Punti Store',
  ];

  @override
  Widget build(BuildContext context) {
    final autoScore = '$wins - $losses - $draws';
    final totalPlayed = wins + losses + draws;
    final winRate = totalPlayed > 0 ? ((wins / totalPlayed) * 100).toStringAsFixed(0) : '0';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con icona coppa
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.winGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.military_tech_outlined,
                    color: AppTheme.winGreenLight,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Statistica Finale',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                // Toggle per modifica manuale dello score
                TextButton.icon(
                  onPressed: () => onToggleScoreManual(!isScoreManual),
                  icon: Icon(
                    isScoreManual ? Icons.auto_mode : Icons.edit,
                    size: 16,
                    color: AppTheme.pokemonBlueLight,
                  ),
                  label: Text(
                    isScoreManual ? 'Auto' : 'Modifica',
                    style: const TextStyle(fontSize: 12, color: AppTheme.pokemonBlueLight),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 1. Score Finale (W - L - D)
            const Text(
              'Score Finale (W - L - D)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),

            if (!isScoreManual)
              // Visualizzazione Automatica dello Score in tempo reale
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.inputFill,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Row(
                  children: [
                    // Badge W
                    _buildPill(
                      label: '$wins W',
                      color: AppTheme.winGreen,
                    ),
                    const SizedBox(width: 8),
                    // Badge L
                    _buildPill(
                      label: '$losses L',
                      color: AppTheme.lossRed,
                    ),
                    const SizedBox(width: 8),
                    // Badge D
                    _buildPill(
                      label: '$draws D',
                      color: AppTheme.drawYellow,
                    ),
                    const Spacer(),
                    // Badge Win Rate
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.pokemonBlueLight.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Win Rate: $winRate%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.pokemonBlueLight,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              // Campo modificabile manualmente
              TextFormField(
                controller: manualScoreController,
                decoration: InputDecoration(
                  hintText: 'es. $autoScore',
                  prefixIcon: const Icon(Icons.edit_note, color: AppTheme.ultraBallGold),
                  helperText: 'Modalità manuale attiva. Score calcolato: $autoScore',
                  helperStyle: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ),
            const SizedBox(height: 18),

            // 2. Numero di Partecipanti
            const Text(
              'Numero di Partecipanti',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: participantsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'es. 16, 24, 32...',
                prefixIcon: Icon(Icons.groups_outlined, color: AppTheme.pokemonBlueLight, size: 20),
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: participantsPresets.map((preset) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ActionChip(
                      label: Text('$preset giocatori'),
                      labelStyle: const TextStyle(fontSize: 12),
                      backgroundColor: AppTheme.darkSurface,
                      onPressed: () {
                        participantsController.text = preset;
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),

            // 3. Posizione Finale
            const Text(
              'Posizione Finale',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: placementController,
              decoration: const InputDecoration(
                hintText: 'es. 2° posto / Top 4',
                prefixIcon: Icon(Icons.emoji_events, color: AppTheme.ultraBallGold, size: 20),
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: placementPresets.map((preset) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ActionChip(
                      label: Text(preset),
                      labelStyle: const TextStyle(fontSize: 12),
                      backgroundColor: AppTheme.darkSurface,
                      onPressed: () {
                        final pCount = participantsController.text.trim();
                        if (pCount.isNotEmpty && !preset.contains('su')) {
                          placementController.text = '$preset (su $pCount)';
                        } else {
                          placementController.text = preset;
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),

            // 3. Punti Ottenuti
            const Text(
              'Punti Ottenuti (CP / Punti Fumetteria)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: pointsController,
              decoration: const InputDecoration(
                hintText: 'es. 15 CP / 50 Punti Negozio',
                prefixIcon: Icon(Icons.stars, color: AppTheme.pokemonBlueLight, size: 20),
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: pointsPresets.map((preset) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ActionChip(
                      label: Text(preset),
                      labelStyle: const TextStyle(fontSize: 12),
                      backgroundColor: AppTheme.darkSurface,
                      onPressed: () {
                        pointsController.text = preset;
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPill({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
