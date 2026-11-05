import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/export_service.dart';
import '../theme/app_theme.dart';

/// Modale per l'esportazione e il ripristino dei dati dell'app (JSON / Testo / Backup)
class ExportDataDialog extends StatefulWidget {
  final VoidCallback onDataRestored;

  const ExportDataDialog({super.key, required this.onDataRestored});

  static Future<void> show(BuildContext context, {required VoidCallback onDataRestored}) {
    return showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: AppTheme.darkSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        side: BorderSide(color: AppTheme.darkBorder, width: 1.2),
      ),
      builder: (ctx) => ExportDataDialog(onDataRestored: onDataRestored),
    );
  }

  @override
  State<ExportDataDialog> createState() => _ExportDataDialogState();
}

class _ExportDataDialogState extends State<ExportDataDialog> {
  bool _isLoading = true;
  Map<String, dynamic>? _backupData;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final data = await ExportService.instance.generateBackupData();
    if (mounted) {
      setState(() {
        _backupData = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _copyJsonBackup() async {
    final jsonStr = await ExportService.instance.exportBackupJson();
    await Clipboard.setData(ClipboardData(text: jsonStr));
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text('Backup JSON copiato negli appunti! Puoi salvarlo o inviarlo.'),
              ),
            ],
          ),
          backgroundColor: AppTheme.winGreen,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _copyTextSummary() async {
    final textSummary = await ExportService.instance.exportTextSummary();
    await Clipboard.setData(ClipboardData(text: textSummary));
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text('Riepilogo testuale copiato! Pronto da incollare in chat o note.'),
              ),
            ],
          ),
          backgroundColor: AppTheme.winGreen,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _openRestoreDialog() async {
    final textController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.darkBorder),
        ),
        title: const Row(
          children: [
            Icon(Icons.restore_page_rounded, color: AppTheme.ultraBallGold, size: 22),
            SizedBox(width: 8),
            Text('Ripristina da Backup', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Incolla il testo del file JSON di backup precedentemente esportato:',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: textController,
              maxLines: 6,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              decoration: const InputDecoration(
                hintText: '{\n  "appName": "Channel GCC Report",\n  ...\n}',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.ultraBallGold,
              foregroundColor: const Color(0xFF0F172A),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ripristina Dati'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final raw = textController.text.trim();
      final result = await ExportService.instance.restoreFromBackupJson(raw);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.success
                  ? 'Ripristinati ${result.tournamentsCount} tornei, ${result.decksCount} mazzi, ${result.locationsCount} location!'
                  : result.message,
            ),
            backgroundColor: result.success ? AppTheme.winGreen : AppTheme.lossRed,
            duration: const Duration(seconds: 4),
          ),
        );
        if (result.success) {
          widget.onDataRestored();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = _backupData?['stats'] as Map<String, dynamic>?;
    final totalT = stats?['totalTournaments'] ?? 0;
    final totalD = stats?['totalDecks'] ?? 0;
    final totalL = stats?['totalLocations'] ?? 0;

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

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.ultraBallGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.download_for_offline_rounded,
                  color: AppTheme.ultraBallGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Esporta & Backup Dati',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Salva o condividi tutti i tuoi tornei, mazzi e location',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Badge Statistiche
          if (!_isLoading) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatMini('Tornei', '$totalT', AppTheme.ultraBallGold),
                  Container(width: 1, height: 26, color: AppTheme.darkBorder),
                  _buildStatMini('Mazzi', '$totalD', AppTheme.textPrimary),
                  Container(width: 1, height: 26, color: AppTheme.darkBorder),
                  _buildStatMini('Location', '$totalL', AppTheme.pokedexRed),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          // Azione 1: Copia Backup JSON
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.ultraBallGold,
              foregroundColor: const Color(0xFF0F172A),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.code_rounded, size: 20),
            label: const Text(
              'Copia Backup JSON Completo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            onPressed: _isLoading ? null : _copyJsonBackup,
          ),
          const SizedBox(height: 10),

          // Azione 2: Copia Riepilogo Testuale
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textPrimary,
              side: const BorderSide(color: AppTheme.darkBorder, width: 1.2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.text_snippet_outlined, size: 20, color: AppTheme.ultraBallGold),
            label: const Text(
              'Copia Riepilogo Testuale (per Chat o Note)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            onPressed: _isLoading ? null : _copyTextSummary,
          ),
          const SizedBox(height: 10),

          // Azione 3: Ripristina da Backup
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            icon: const Icon(Icons.restore_page_outlined, size: 18),
            label: const Text('Hai un backup precedente? Ripristina dati'),
            onPressed: _openRestoreDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildStatMini(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
