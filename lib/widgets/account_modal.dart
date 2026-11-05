import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';

/// Modale di Gestione Account & Sincronizzazione Cloud (Google, Apple, Email, Ospite)
class AccountModal extends StatefulWidget {
  final VoidCallback onStateChanged;

  const AccountModal({super.key, required this.onStateChanged});

  static Future<void> show(BuildContext context, {required VoidCallback onStateChanged}) {
    return showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: AppTheme.darkSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        side: BorderSide(color: AppTheme.darkBorder, width: 1.2),
      ),
      builder: (ctx) => AccountModal(onStateChanged: onStateChanged),
    );
  }

  @override
  State<AccountModal> createState() => _AccountModalState();
}

class _AccountModalState extends State<AccountModal> {
  bool _isProcessing = false;

  Future<void> _handleGoogleLogin() async {
    setState(() => _isProcessing = true);
    try {
      final profile = await AuthService.instance.loginWithGoogleNative();
      if (profile != null) {
        await SyncService.instance.syncNow();
        if (mounted) {
          setState(() => _isProcessing = false);
          widget.onStateChanged();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Accesso completato con ${profile.email}! Sincronizzazione cloud attiva.'),
              backgroundColor: AppTheme.winGreen,
            ),
          );
        }
        return;
      }
      // Se l'utente ha annullato la selezione account
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      debugPrint('Google Sign-In nativo non disponibile o interrotto: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        await _promptGmailAddressDialog();
      }
    }
  }

  Future<void> _promptGmailAddressDialog() async {
    final emailCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.darkBorder),
        ),
        title: const Row(
          children: [
            Icon(Icons.g_mobiledata_rounded, color: Color(0xFFEA4335), size: 30),
            SizedBox(width: 8),
            Text('Account Gmail', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18)),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Inserisci il tuo indirizzo Gmail personale per salvare e sincronizzare in cloud tutti i tuoi tornei e mazzi.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Il tuo indirizzo Gmail *',
                  hintText: 'es. tuo.nome@gmail.com',
                  prefixIcon: Icon(Icons.email_outlined, color: AppTheme.ultraBallGold, size: 18),
                ),
                validator: (val) {
                  final text = val?.trim() ?? '';
                  if (text.isEmpty) return 'Inserisci la tua email Gmail';
                  if (!text.contains('@') || !text.contains('.')) return 'Inserisci un\'email valida';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome Allenatore (Opzionale)',
                  hintText: 'es. Mario',
                  prefixIcon: Icon(Icons.person_outline, color: AppTheme.ultraBallGold, size: 18),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annulla')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.ultraBallGold,
              foregroundColor: const Color(0xFF0F172A),
            ),
            onPressed: () {
              if (formKey.currentState?.validate() == true) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Conferma & Accedi'),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      setState(() => _isProcessing = true);
      final profile = await AuthService.instance.loginWithGoogle(
        email: emailCtrl.text.trim(),
        displayName: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : null,
      );
      await SyncService.instance.syncNow();
      if (mounted) {
        setState(() => _isProcessing = false);
        widget.onStateChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Accesso completato con ${profile.email}! Sincronizzazione cloud attiva.'),
            backgroundColor: AppTheme.winGreen,
          ),
        );
      }
    }
  }

  Future<void> _handleAppleLogin() async {
    final emailCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.darkBorder),
        ),
        title: const Row(
          children: [
            Icon(Icons.apple_rounded, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text('Accedi con Apple ID', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18)),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Inserisci la tua email Apple ID (iCloud) per sincronizzare il tuo profilo in cloud.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Apple ID Email *',
                  hintText: 'es. nome@icloud.com',
                  prefixIcon: Icon(Icons.alternate_email, color: AppTheme.ultraBallGold, size: 18),
                ),
                validator: (val) {
                  final text = val?.trim() ?? '';
                  if (text.isEmpty || !text.contains('@')) return 'Inserisci un\'email valida';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome Visualizzato (Opzionale)',
                  hintText: 'es. Antonio',
                  prefixIcon: Icon(Icons.person_outline, color: AppTheme.ultraBallGold, size: 18),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annulla')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F172A),
            ),
            onPressed: () {
              if (formKey.currentState?.validate() == true) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Accedi con Apple'),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      setState(() => _isProcessing = true);
      final profile = await AuthService.instance.loginWithApple(
        email: emailCtrl.text.trim(),
        displayName: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : null,
      );
      await SyncService.instance.syncNow();
      if (mounted) {
        setState(() => _isProcessing = false);
        widget.onStateChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Accesso con Apple completato con ${profile.email}! Dati sincronizzati in cloud.'),
            backgroundColor: AppTheme.winGreen,
          ),
        );
      }
    }
  }

  Future<void> _handleEmailLogin() async {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.darkBorder),
        ),
        title: const Text('Accedi con Email', style: TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Indirizzo Email *', hintText: 'es. nome@dominio.it'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password *', hintText: 'Minimo 6 caratteri'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annulla')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.ultraBallGold,
              foregroundColor: const Color(0xFF0F172A),
            ),
            onPressed: () {
              if (emailCtrl.text.trim().isNotEmpty && passCtrl.text.trim().length >= 6) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Accedi'),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      setState(() => _isProcessing = true);
      await AuthService.instance.loginWithEmail(emailCtrl.text.trim(), passCtrl.text);
      await SyncService.instance.syncNow();
      if (mounted) {
        setState(() => _isProcessing = false);
        widget.onStateChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Accesso effettuato con successo!'),
            backgroundColor: AppTheme.winGreen,
          ),
        );
      }
    }
  }

  Future<void> _handleSyncNow() async {
    setState(() => _isProcessing = true);
    final success = await SyncService.instance.syncNow();
    if (mounted) {
      setState(() => _isProcessing = false);
      final msg = SyncService.instance.lastSyncMessage.isNotEmpty
          ? SyncService.instance.lastSyncMessage
          : (success ? 'Sincronizzazione cloud completata!' : 'Errore durante la sincronizzazione.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: success ? AppTheme.winGreen : AppTheme.lossRed,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.instance.logout();
    if (mounted) {
      widget.onStateChanged();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disconnessione effettuata. Modalità locale attiva.')),
      );
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.lossRed),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.lossRed, size: 22),
            SizedBox(width: 8),
            Text('Elimina Account & Dati', style: TextStyle(color: AppTheme.lossRedLight)),
          ],
        ),
        content: const Text(
          'Questa azione è irreversibile. Eliminerà permanentemente il tuo profilo e tutti i dati memorizzati sia localmente che nel cloud.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annulla')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.lossRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Elimina Tutto', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isProcessing = true);
      await AuthService.instance.deleteAccountAndData();
      if (mounted) {
        setState(() => _isProcessing = false);
        widget.onStateChanged();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account e tutti i dati associati sono stati eliminati.'),
            backgroundColor: AppTheme.lossRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final isLogged = user != null && !user.isAnonymous;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.darkBorder,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          if (isLogged) _buildAuthenticatedView(user) else _buildLoginView(),
        ],
      ),
    );
  }

  Widget _buildLoginView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.ultraBallGold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_sync_rounded, color: AppTheme.ultraBallGold, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Accedi & Sincronizza',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  Text(
                    'Salva i tuoi tornei in cloud e accedi da qualsiasi smartphone',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Bottone Google
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0F172A),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.g_mobiledata_rounded, size: 28, color: Color(0xFFEA4335)),
          label: const Text('Accedi con Google', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          onPressed: _isProcessing ? null : _handleGoogleLogin,
        ),
        const SizedBox(height: 4),

        Center(
          child: TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.ultraBallGold,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            ),
            icon: const Icon(Icons.edit_note_rounded, size: 16),
            label: const Text(
              'Oppure inserisci la tua Gmail manualmente',
              style: TextStyle(fontSize: 12, decoration: TextDecoration.underline),
            ),
            onPressed: _isProcessing ? null : _promptGmailAddressDialog,
          ),
        ),
        const SizedBox(height: 6),

        // Bottone Apple
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E293B),
            foregroundColor: Colors.white,
            side: const BorderSide(color: AppTheme.darkBorder),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          icon: const Icon(Icons.apple_rounded, size: 22, color: Colors.white),
          label: const Text('Accedi con Apple ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          onPressed: _isProcessing ? null : _handleAppleLogin,
        ),
        const SizedBox(height: 10),

        // Bottone Email
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.textPrimary,
            side: const BorderSide(color: AppTheme.darkBorder),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.email_outlined, size: 20, color: AppTheme.ultraBallGold),
          label: const Text('Accedi con Email & Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          onPressed: _isProcessing ? null : _handleEmailLogin,
        ),
        const SizedBox(height: 12),

        // Nota offline first
        const Center(
          child: Text(
            'L\'app funziona sempre anche offline in modalità locale.',
            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthenticatedView(UserProfile user) {
    final lastSync = user.lastSyncAt;
    final lastSyncStr = lastSync != null ? DateFormat('dd/MM HH:mm').format(lastSync) : 'Mai';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Scheda profilo utente
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.inputFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.ultraBallGold.withValues(alpha: 0.2),
                child: Text(
                  user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'A',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.ultraBallGold, fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                    ),
                    if (user.email.isNotEmpty)
                      Text(user.email, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.darkSurface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Provider: ${user.providerDisplayName}',
                        style: const TextStyle(fontSize: 11, color: AppTheme.ultraBallGold, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Box Stato Sincronizzazione Cloud
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.cloud_done_rounded, color: AppTheme.winGreenLight, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sincronizzazione Cloud Attiva', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('Ultimo sync: $lastSyncStr', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.ultraBallGold,
                  foregroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: _isProcessing ? null : _handleSyncNow,
                child: _isProcessing
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Sync Ora', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Disconnetti
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.textPrimary,
            side: const BorderSide(color: AppTheme.darkBorder),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: const Text('Disconnetti'),
          onPressed: _isProcessing ? null : _handleLogout,
        ),
        const SizedBox(height: 8),

        // Elimina account e dati (Mandatorio Store)
        TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: AppTheme.lossRedLight),
          icon: const Icon(Icons.delete_forever_rounded, size: 18),
          label: const Text('Elimina Account e Dati Cloud (GDPR / Store Compliance)'),
          onPressed: _isProcessing ? null : _handleDeleteAccount,
        ),
      ],
    );
  }
}
