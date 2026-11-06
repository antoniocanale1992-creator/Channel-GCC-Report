import 'package:flutter/material.dart';
import '../services/kill_switch_service.dart';
import '../theme/app_theme.dart';
import '../widgets/tcg_playmat_background.dart';

/// Schermata a tutto schermo di blocco manutenzione (Kill Switch)
class MaintenanceScreen extends StatefulWidget {
  final String message;
  final VoidCallback onRetry;

  const MaintenanceScreen({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  bool _isChecking = false;

  Future<void> _handleRetry() async {
    setState(() => _isChecking = true);
    final status = await KillSwitchService.instance.checkAppStatus();
    if (mounted) {
      setState(() => _isChecking = false);
      if (status.isActive) {
        widget.onRetry();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('L\'applicazione è ancora in manutenzione. Torneremo online a breve!'),
            backgroundColor: AppTheme.drawYellow,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: TcgPlaymatBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icona grande con stile Ultra Ball / Avviso
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.ultraBallGold.withValues(alpha: 0.15),
                      border: Border.all(color: AppTheme.ultraBallGold, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.ultraBallGold.withValues(alpha: 0.25),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.build_circle_outlined,
                      size: 48,
                      color: AppTheme.ultraBallGold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Titolo
                  const Text(
                    'Manutenzione in Corso',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Card Messaggio da Firestore
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.darkBorder),
                    ),
                    child: Text(
                      widget.message.isNotEmpty
                          ? widget.message
                          : 'I server sono attualmente in aggiornamento tecnico per migliorare le funzionalità del tracciatore. Riprova tra qualche minuto.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Bottone Riprova
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.ultraBallGold,
                        foregroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isChecking ? null : _handleRetry,
                      icon: _isChecking
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh_rounded, size: 20),
                      label: Text(
                        _isChecking ? 'Verifica in corso...' : 'Verifica di nuovo',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tag informativo
                  const Text(
                    'Pokémon TCG Local Tracker • Sistema di Protezione Remoto',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
