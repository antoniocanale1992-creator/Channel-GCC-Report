import 'package:flutter/material.dart';
import '../models/match_round.dart';
import '../theme/app_theme.dart';

/// Riga orizzontale per un singolo match del torneo
/// Parte sinistra: Label "vs" + campo di testo mazzo avversario
/// Parte destra: Label "Risultato" + 3 cerchi selezionabili [W] [L] [D]
class MatchRowCard extends StatelessWidget {
  final int roundIndex; // 0-based
  final MatchRound matchRound;
  final TextEditingController opponentController;
  final ValueChanged<MatchOutcome> onOutcomeChanged;

  const MatchRowCard({
    super.key,
    required this.roundIndex,
    required this.matchRound,
    required this.opponentController,
    required this.onOutcomeChanged,
  });

  Widget _buildResultCircle({
    required BuildContext context,
    required String code,
    required String tooltip,
    required Color activeColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? activeColor : AppTheme.inputFill,
            border: Border.all(
              color: isSelected ? activeColor : AppTheme.darkBorder,
              width: isSelected ? 2.0 : 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: Text(
            code,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roundNumber = roundIndex + 1;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intestazione piccola Turno
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.pokemonBlueLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Turno $roundNumber',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.pokemonBlueLight,
                    ),
                  ),
                ),
                const Spacer(),
                if (matchRound.isPlayed)
                  Text(
                    matchRound.outcome.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: matchRound.isWin
                          ? AppTheme.winGreenLight
                          : (matchRound.isLoss
                              ? AppTheme.lossRedLight
                              : AppTheme.drawYellowLight),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Disposizione orizzontale (Row) richiesta:
            // Sinistra: "vs" + Mazzo Avversario
            // Destra: "Risultato" + [W] [L] [D]
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // PARTE SINISTRA: "vs" + TextField mazzo avversario
                const Text(
                  'vs',
                  style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: opponentController,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Mazzo avversario (es. Lugia, Gardevoir...)',
                      hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // PARTE DESTRA: Label "Risultato" + 3 Cerchi [W] [L] [D]
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Risultato',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // [W] - Verde (Vittoria)
                        _buildResultCircle(
                          context: context,
                          code: 'W',
                          tooltip: 'Vittoria',
                          activeColor: AppTheme.winGreen,
                          isSelected: matchRound.outcome == MatchOutcome.win,
                          onTap: () {
                            if (matchRound.outcome == MatchOutcome.win) {
                              onOutcomeChanged(MatchOutcome.none);
                            } else {
                              onOutcomeChanged(MatchOutcome.win);
                            }
                          },
                        ),
                        const SizedBox(width: 6),

                        // [L] - Rosso (Sconfitta)
                        _buildResultCircle(
                          context: context,
                          code: 'L',
                          tooltip: 'Sconfitta',
                          activeColor: AppTheme.lossRed,
                          isSelected: matchRound.outcome == MatchOutcome.loss,
                          onTap: () {
                            if (matchRound.outcome == MatchOutcome.loss) {
                              onOutcomeChanged(MatchOutcome.none);
                            } else {
                              onOutcomeChanged(MatchOutcome.loss);
                            }
                          },
                        ),
                        const SizedBox(width: 6),

                        // [D] - Giallo/Ambra (Pareggio)
                        _buildResultCircle(
                          context: context,
                          code: 'D',
                          tooltip: 'Pareggio',
                          activeColor: AppTheme.drawYellow,
                          isSelected: matchRound.outcome == MatchOutcome.draw,
                          onTap: () {
                            if (matchRound.outcome == MatchOutcome.draw) {
                              onOutcomeChanged(MatchOutcome.none);
                            } else {
                              onOutcomeChanged(MatchOutcome.draw);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
