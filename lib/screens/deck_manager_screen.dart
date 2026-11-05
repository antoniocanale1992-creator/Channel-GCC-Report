import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/deck_model.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/deck_emblem_badge.dart';
import '../widgets/tcg_playmat_background.dart';

/// Schermata per la gestione e consultazione dei propri mazzi Pokémon GCC
/// Include copia rapida della decklist per l'esportazione verso app esterne (PTCG Live, Limitless, ecc.)
class DeckManagerScreen extends StatefulWidget {
  const DeckManagerScreen({super.key});

  @override
  State<DeckManagerScreen> createState() => _DeckManagerScreenState();
}

class _DeckManagerScreenState extends State<DeckManagerScreen> {
  List<DeckModel> _decks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    setState(() => _isLoading = true);
    final list = await StorageService.instance.getDecks();
    if (mounted) {
      setState(() {
        _decks = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteDeck(DeckModel deck) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.darkBorder),
        ),
        title: const Text('Elimina Mazzo', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Sei sicuro di voler eliminare "${deck.name}"?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.lossRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.instance.deleteDeck(deck.id);
      _loadDecks();
    }
  }

  void _copyDecklist(DeckModel deck) {
    if (deck.decklist.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Questo mazzo non contiene ancora una lista testuale.'),
          backgroundColor: AppTheme.drawYellow,
        ),
      );
      return;
    }

    Clipboard.setData(ClipboardData(text: deck.decklist));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Lista di "${deck.name}" copiata! Pronta per PTCG Live o app esterne.',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.winGreen,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _openDeckDialog([DeckModel? existing]) async {
    final titleController = TextEditingController(text: existing?.name ?? '');
    final listController = TextEditingController(text: existing?.decklist ?? '');
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: AppTheme.darkSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        side: BorderSide(color: AppTheme.darkBorder, width: 1.2),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  Row(
                    children: [
                      const Icon(Icons.style_rounded, color: AppTheme.ultraBallGold, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        existing != null ? 'Modifica Mazzo' : 'Nuovo Mazzo',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Titolo mazzo
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Titolo Mazzo *',
                      hintText: 'Es. Slowking SCR / Mega Kangaskhan ex',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Inserisci un titolo per il mazzo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Header campo Lista con bottone incolla
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Lista Mazzo (Formato PTCG / Limitless)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.content_paste, size: 16),
                        label: const Text('Incolla', style: TextStyle(fontSize: 12)),
                        onPressed: () async {
                          final data = await Clipboard.getData(Clipboard.kTextPlain);
                          if (data?.text != null && data!.text!.isNotEmpty) {
                            listController.text = data.text!;
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Campo testo decklist
                  TextFormField(
                    controller: listController,
                    maxLines: 9,
                    minLines: 5,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: AppTheme.textPrimary,
                      height: 1.4,
                    ),
                    decoration: const InputDecoration(
                      hintText:
                          'Pokémon: 22\n4 Slowpoke SCR 57\n4 Mega Kangaskhan ex MEG 104\n\nTrainer: 28\n4 Ultra Ball MEG 131\n\nEnergy: 10\n4 Psychic Energy MEE 13',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 18),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.ultraBallGold,
                      foregroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;

                      final name = titleController.text.trim();
                      final list = listController.text.trim();

                      final deck = DeckModel(
                        id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        decklist: list,
                        createdAt: existing?.createdAt,
                        updatedAt: DateTime.now(),
                      );

                      await StorageService.instance.saveDeck(deck);
                      if (ctx.mounted) Navigator.pop(ctx);
                      _loadDecks();
                    },
                    child: Text(
                      existing != null ? 'Salva Modifiche' : 'Aggiungi Mazzo',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('I Miei Mazzi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.ultraBallGold, size: 28),
            tooltip: 'Aggiungi Mazzo',
            onPressed: () => _openDeckDialog(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: TcgPlaymatBackground(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _decks.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        12,
                        16,
                        MediaQuery.of(context).padding.bottom + 24,
                      ),
                      itemCount: _decks.length,
                      itemBuilder: (context, index) {
                        final deck = _decks[index];
                        return _buildDeckCard(deck, index + 1);
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.ultraBallGold.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.style_rounded,
                size: 56,
                color: AppTheme.ultraBallGold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nessun Mazzo Salvato',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aggiungi i tuoi mazzi con titolo e decklist per poterli selezionare velocemente nei report torneo ed esportarli con un tocco!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.ultraBallGold,
                foregroundColor: const Color(0xFF0F172A),
              ),
              onPressed: () => _openDeckDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi Primo Mazzo', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeckCard(DeckModel deck, int index) {
    final hasDecklist = deck.decklist.trim().isNotEmpty;
    final totalCards = deck.totalCardsCount;
    final dateStr = DateFormat('dd/MM/yyyy').format(deck.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: DeckEmblemBadge(index: index),
        title: Text(
          deck.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Text(
                hasDecklist
                    ? (totalCards > 0 ? '$totalCards carte' : '${deck.linesCount} righe lista')
                    : 'Lista non inserita',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
              const SizedBox(width: 8),
              Text('• $dateStr', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy_rounded, color: AppTheme.ultraBallGold, size: 22),
          tooltip: 'Copia Lista Mazzo',
          onPressed: () => _copyDecklist(deck),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          const Divider(color: AppTheme.darkBorder),
          if (hasDecklist) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.inputFill,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: SelectableText(
                deck.decklist,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: AppTheme.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copia Lista'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.ultraBallGold,
                  side: const BorderSide(color: AppTheme.ultraBallGold),
                ),
                onPressed: () => _copyDecklist(deck),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Modifica'),
                onPressed: () => _openDeckDialog(deck),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: AppTheme.lossRedLight),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Elimina'),
                onPressed: () => _deleteDeck(deck),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
