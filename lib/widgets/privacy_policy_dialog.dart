import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Dialog completo per Informativa sulla Privacy, Conformità Store e Disclaimer Pokémon
class PrivacyPolicyDialog extends StatelessWidget {
  const PrivacyPolicyDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const PrivacyPolicyDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.darkBorder, width: 1.2),
      ),
      title: const Row(
        children: [
          Icon(Icons.policy_outlined, color: AppTheme.ultraBallGold, size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Privacy & Note Legali',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Disclaimer Pokémon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.ultraBallGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.ultraBallGold.withValues(alpha: 0.3)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AVVISO SUI MARCHI REGISTRATI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.ultraBallGold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Pokémon e Pokémon Gioco di Carte Collezionabili (GCC/TCG) sono marchi di Nintendo, Creatures Inc. e Game Freak Inc.\n'
                      'Channel GCC Report è un\'applicazione amatoriale indipendente senza fini commerciali, non affiliata, autorizzata o sponsorizzata da The Pokémon Company o Nintendo.',
                      style: TextStyle(fontSize: 12, color: AppTheme.textPrimary, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              _buildSectionTitle('1. Tipologia di Dati Trattati'),
              _buildSectionBody(
                'L\'applicazione memorizza unicamente i dati inseriti volontariamente dall\'utente: '
                'report delle partite dei tornei, liste mazzi e nomi delle fumetterie/location.',
              ),

              _buildSectionTitle('2. Permessi & Privacy'),
              _buildSectionBody(
                '• NESSUN tracciamento GPS in background.\n'
                '• NESSUN accesso a contatti, galleria, microfono o fotocamera.\n'
                '• L\'avvio del navigatore per le fumetterie utilizza l\'app Google Maps solo su esplicita richiesta dell\'utente.',
              ),

              _buildSectionTitle('3. Memorizzazione e Sincronizzazione Cloud'),
              _buildSectionBody(
                'I dati risiedono in locale sul dispositivo. In caso di autenticazione con Google, Apple o Email, i dati vengono sincronizzati '
                'in modo cifrato per permettere l\'accesso su più dispositivi.',
              ),

              _buildSectionTitle('4. Diritti dell\'Utente (GDPR / CCPA / Store Policy)'),
              _buildSectionBody(
                '• Portabilità: Puoi esportare tutti i tuoi dati in qualsiasi momento in formato JSON tramite il tasto Esporta.\n'
                '• Cancellazione Completa: Tramite la sezione Account puoi eliminare definitivamente e senza recupero il profilo e tutti i dati associati.',
              ),

              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Sviluppato da Antonio Canale\nVersione 1.2.1 - Channel GCC Report',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.ultraBallGold,
            foregroundColor: const Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Ho Capito'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppTheme.ultraBallGold,
        ),
      ),
    );
  }

  Widget _buildSectionBody(String body) {
    return Text(
      body,
      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.35),
    );
  }
}
