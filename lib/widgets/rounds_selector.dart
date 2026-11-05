import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Sezione per la selezione del numero di turni del torneo (da 1 ad 8)
class RoundsSelector extends StatelessWidget {
  final int selectedRounds;
  final ValueChanged<int> onRoundsChanged;

  const RoundsSelector({
    super.key,
    required this.selectedRounds,
    required this.onRoundsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.ultraBallGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.format_list_numbered,
                    color: AppTheme.ultraBallGold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Numero di Turni (Svizzera)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Seleziona da 1 a 8 turni per generare i match',
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
            const SizedBox(height: 16),

            // Dropdown menu a tendina
            DropdownButtonFormField<int>(
              key: ValueKey('rounds_dropdown_$selectedRounds'),
              initialValue: selectedRounds,
              decoration: InputDecoration(
                labelText: 'Numero di Turni',
                prefixIcon: const Icon(Icons.sports_esports_outlined, color: AppTheme.pokemonBlueLight),
                helperText: selectedRounds <= 3
                    ? 'Formato veloce (Torneo serale)'
                    : (selectedRounds <= 5 ? 'Formato standard Local (16-32 giocatori)' : 'Formato esteso / League Cup'),
                helperStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
              ),
              dropdownColor: AppTheme.darkSurface,
              icon: const Icon(Icons.arrow_drop_down, color: AppTheme.pokemonBlueLight),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              items: List.generate(8, (index) {
                final roundNum = index + 1;
                return DropdownMenuItem<int>(
                  value: roundNum,
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppTheme.pokemonBlueLight.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$roundNum',
                          style: const TextStyle(
                            color: AppTheme.pokemonBlueLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        roundNum == 1 ? '1 Turno' : '$roundNum Turni',
                        style: const TextStyle(color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                );
              }),
              onChanged: (newVal) {
                if (newVal != null && newVal != selectedRounds) {
                  onRoundsChanged(newVal);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
