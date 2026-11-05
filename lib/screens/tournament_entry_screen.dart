import 'package:flutter/material.dart';
import '../models/deck_model.dart';
import '../models/location_model.dart';
import '../models/match_round.dart';
import '../models/tournament_report.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/final_stats_card.dart';
import '../widgets/match_row_card.dart';
import '../widgets/pokemon_tcg_badge.dart';
import '../widgets/retrospective_card.dart';
import '../widgets/rounds_selector.dart';
import '../widgets/tcg_playmat_background.dart';
import '../widgets/tournament_info_card.dart';

/// Schermata principale per l'inserimento e la gestione del report di un torneo Local Pokémon GCC
class TournamentEntryScreen extends StatefulWidget {
  final TournamentReport? existingReport;

  const TournamentEntryScreen({super.key, this.existingReport});

  @override
  State<TournamentEntryScreen> createState() => _TournamentEntryScreenState();
}

class _TournamentEntryScreenState extends State<TournamentEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  // Dati Mazzi e Location salvati
  List<DeckModel> _savedDecks = [];
  List<LocationModel> _savedLocations = [];

  // Dati Sezione 1: Info Torneo
  late DateTime _selectedDate;
  final TextEditingController _eventTypeController =
      TextEditingController(text: 'Local');
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _deckUsedController = TextEditingController();

  // Dati Sezione 2: Selezione Turni
  int _selectedRounds = 3;

  // Dati Sezione 3: Match dinamici
  final List<MatchRound> _roundsData = [];
  final List<TextEditingController> _opponentControllers = [];

  // Dati Sezione 4: Statistica Finale
  bool _isScoreManual = false;
  final TextEditingController _manualScoreController = TextEditingController();
  final TextEditingController _participantsController = TextEditingController();
  final TextEditingController _placementController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();

  // Dati Sezione 5: Retrospettiva
  final TextEditingController _whatWorkedController = TextEditingController();
  final TextEditingController _toImproveController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initValues();
    _loadSavedOptions();
  }

  Future<void> _loadSavedOptions() async {
    final decks = await StorageService.instance.getDecks();
    final locations = await StorageService.instance.getLocations();
    if (mounted) {
      setState(() {
        _savedDecks = decks;
        _savedLocations = locations;
      });
    }
  }

  void _initValues() {
    if (widget.existingReport != null) {
      final r = widget.existingReport!;
      _selectedDate = r.eventDate;
      _eventTypeController.text = r.eventType;
      _locationController.text = r.location;
      _deckUsedController.text = r.deckUsed;
      _selectedRounds = r.roundsCount;
      _isScoreManual = r.isScoreManual;
      _manualScoreController.text = r.manualScore ?? '';
      _participantsController.text =
          r.participantsCount != null ? r.participantsCount.toString() : '';
      _placementController.text = r.finalPlacement;
      _pointsController.text = r.pointsEarned;
      _whatWorkedController.text = r.whatWorked;
      _toImproveController.text = r.toImprove;

      _updateRoundsCount(_selectedRounds, initialRounds: r.rounds);
    } else {
      _selectedDate = DateTime.now();
      _updateRoundsCount(_selectedRounds);
    }
  }

  /// Aggiorna la lista dei turni dinamici mantenendo i dati già inseriti
  void _updateRoundsCount(int count, {List<MatchRound>? initialRounds}) {
    setState(() {
      _selectedRounds = count;

      while (_roundsData.length < count) {
        final roundIndex = _roundsData.length;
        if (initialRounds != null && roundIndex < initialRounds.length) {
          final initItem = initialRounds[roundIndex];
          _roundsData.add(initItem);
          _opponentControllers.add(TextEditingController(text: initItem.opponentDeck));
        } else {
          _roundsData.add(MatchRound(roundNumber: roundIndex + 1));
          _opponentControllers.add(TextEditingController());
        }
      }

      while (_roundsData.length > count) {
        _roundsData.removeLast();
        final ctrl = _opponentControllers.removeLast();
        ctrl.dispose();
      }
    });
  }

  @override
  void dispose() {
    _eventTypeController.dispose();
    _locationController.dispose();
    _deckUsedController.dispose();
    for (var c in _opponentControllers) {
      c.dispose();
    }
    _manualScoreController.dispose();
    _participantsController.dispose();
    _placementController.dispose();
    _pointsController.dispose();
    _whatWorkedController.dispose();
    _toImproveController.dispose();
    super.dispose();
  }

  int get _calculatedWins =>
      _roundsData.where((r) => r.outcome == MatchOutcome.win).length;

  int get _calculatedLosses =>
      _roundsData.where((r) => r.outcome == MatchOutcome.loss).length;

  int get _calculatedDraws =>
      _roundsData.where((r) => r.outcome == MatchOutcome.draw).length;

  Future<void> _saveTournamentReport() async {
    // Validazione form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Compila tutti i campi obbligatori per continuare.'),
          backgroundColor: AppTheme.lossRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Sincronizza i mazzi avversari inseriti nei controller
    for (int i = 0; i < _roundsData.length; i++) {
      _roundsData[i].opponentDeck = _opponentControllers[i].text.trim();
    }

    final reportId = widget.existingReport?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();

    final report = TournamentReport(
      id: reportId,
      eventDate: _selectedDate,
      eventType: _eventTypeController.text.trim(),
      location: _locationController.text.trim(),
      deckUsed: _deckUsedController.text.trim(),
      roundsCount: _selectedRounds,
      rounds: _roundsData.map((r) => r.copyWith()).toList(),
      isScoreManual: _isScoreManual,
      manualScore: _manualScoreController.text.trim(),
      participantsCount: int.tryParse(_participantsController.text.trim()),
      finalPlacement: _placementController.text.trim(),
      pointsEarned: _pointsController.text.trim(),
      whatWorked: _whatWorkedController.text.trim(),
      toImprove: _toImproveController.text.trim(),
      createdAt: widget.existingReport?.createdAt,
    );

    final success = await StorageService.instance.saveReport(report);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      _showSuccessDialog(report);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Errore durante il salvataggio del report.'),
          backgroundColor: AppTheme.lossRed,
        ),
      );
    }
  }

  void _showSuccessDialog(TournamentReport report) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppTheme.ultraBallGold, width: 1.5),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppTheme.winGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Report Salvato!',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${report.eventType} - ${report.deckUsed}',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Score finale: ${report.finalScoreDisplay} (${report.winRateDisplay} Win Rate)',
                style: const TextStyle(
                  color: AppTheme.winGreenLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              if (report.finalPlacement.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Posizione: ${report.finalPlacement}',
                  style: const TextStyle(color: AppTheme.ultraBallGold, fontSize: 13),
                ),
              ],
              if (report.pointsEarned.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Punti ottenuti: ${report.pointsEarned}',
                  style: const TextStyle(color: AppTheme.ultraBallGold, fontSize: 13),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _resetForm();
              },
              child: const Text('Nuovo Torneo'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Torna allo Storico'),
            ),
          ],
        );
      },
    );
  }

  void _resetForm() {
    setState(() {
      _selectedDate = DateTime.now();
      _eventTypeController.text = 'Local';
      _locationController.clear();
      _deckUsedController.clear();
      _selectedRounds = 3;
      _updateRoundsCount(3);
      _isScoreManual = false;
      _manualScoreController.clear();
      _participantsController.clear();
      _placementController.clear();
      _pointsController.clear();
      _whatWorkedController.clear();
      _toImproveController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PokemonTcgBadge(size: 26),
            const SizedBox(width: 10),
            Text(widget.existingReport != null
                ? 'Modifica Report'
                : 'Nuovo Report Torneo'),
          ],
        ),
      ),
      body: TcgPlaymatBackground(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                MediaQuery.of(context).padding.bottom + 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Sezione Info Torneo (In Alto)
                  TournamentInfoCard(
                    selectedDate: _selectedDate,
                    onDateChanged: (newDate) {
                      setState(() => _selectedDate = newDate);
                    },
                    eventTypeController: _eventTypeController,
                    locationController: _locationController,
                    deckUsedController: _deckUsedController,
                    savedDecks: _savedDecks,
                    savedLocations: _savedLocations,
                  ),
                const SizedBox(height: 14),

                // 2. Sezione Selezione Turni (Menu a tendina 1..8)
                RoundsSelector(
                  selectedRounds: _selectedRounds,
                  onRoundsChanged: (count) {
                    _updateRoundsCount(count);
                  },
                ),
                const SizedBox(height: 14),

                // 3. Sezione Dinamica Match (Generata in base ai turni 1..8)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.sports_esports,
                        color: AppTheme.ultraBallGold,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Partite del Torneo ($_selectedRounds Turni)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Generazione dinamica dei match
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _selectedRounds,
                  itemBuilder: (context, index) {
                    return MatchRowCard(
                      key: ValueKey('round_row_$index'),
                      roundIndex: index,
                      matchRound: _roundsData[index],
                      opponentController: _opponentControllers[index],
                      onOutcomeChanged: (newOutcome) {
                        setState(() {
                          _roundsData[index].outcome = newOutcome;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 14),

                // 4. Sezione Statistica Finale (Subito sotto i match)
                FinalStatsCard(
                  wins: _calculatedWins,
                  losses: _calculatedLosses,
                  draws: _calculatedDraws,
                  isScoreManual: _isScoreManual,
                  onToggleScoreManual: (manual) {
                    setState(() {
                      _isScoreManual = manual;
                      if (manual && _manualScoreController.text.isEmpty) {
                        _manualScoreController.text =
                            '$_calculatedWins - $_calculatedLosses - $_calculatedDraws';
                      }
                    });
                  },
                  manualScoreController: _manualScoreController,
                  participantsController: _participantsController,
                  placementController: _placementController,
                  pointsController: _pointsController,
                ),
                const SizedBox(height: 14),

                // 5. Sezione Retrospettiva (In Basso)
                RetrospectiveCard(
                  whatWorkedController: _whatWorkedController,
                  toImproveController: _toImproveController,
                ),
                const SizedBox(height: 24),

                // 6. Azione Finale: Pulsante principale "Salva Report Torneo"
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveTournamentReport,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_rounded, size: 22),
                  label: Text(
                    _isSaving ? 'Salvataggio in corso...' : 'Salva Report Torneo',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.ultraBallGold,
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 4,
                  ),
                ),
                const SizedBox(height: 18),

                // Footer richiesto
                const Center(
                  child: Text(
                    'Powered By Antonio Canale - BETA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
