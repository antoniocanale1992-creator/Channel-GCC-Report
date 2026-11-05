import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/match_round.dart';
import '../models/tournament_report.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/account_modal.dart';
import '../widgets/export_data_dialog.dart';
import '../widgets/pokemon_tcg_badge.dart';
import '../widgets/privacy_policy_dialog.dart';
import '../widgets/tcg_playmat_background.dart';
import 'deck_manager_screen.dart';
import 'location_manager_screen.dart';
import 'tournament_entry_screen.dart';

/// Schermata dello storico dei tornei Pokémon GCC salvati
class TournamentHistoryScreen extends StatefulWidget {
  const TournamentHistoryScreen({super.key});

  @override
  State<TournamentHistoryScreen> createState() => _TournamentHistoryScreenState();
}

class _TournamentHistoryScreenState extends State<TournamentHistoryScreen> {
  List<TournamentReport> _reports = [];
  int _decksCount = 0;
  int _locationsCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    AuthService.instance.init();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    final reports = await StorageService.instance.getReports();
    final decks = await StorageService.instance.getDecks();
    final locations = await StorageService.instance.getLocations();
    if (mounted) {
      setState(() {
        _reports = reports;
        _decksCount = decks.length;
        _locationsCount = locations.length;
        _isLoading = false;
      });
    }
  }

  Future<void> _openDeckManager() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DeckManagerScreen()),
    );
    _loadReports();
  }

  Future<void> _openLocationManager() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LocationManagerScreen()),
    );
    _loadReports();
  }

  Future<void> _deleteReport(TournamentReport report) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Text('Elimina Report', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Sei sicuro di voler eliminare il report del ${DateFormat('dd/MM/yyyy').format(report.eventDate)} (${report.deckUsed})?',
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
      await StorageService.instance.deleteReport(report.id);
      _loadReports();
    }
  }

  Future<void> _openEntryScreen([TournamentReport? report]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TournamentEntryScreen(existingReport: report),
      ),
    );
    _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    // Statistiche generali aggregate
    final totalTournaments = _reports.length;
    final totalWins = _reports.fold<int>(0, (sum, r) => sum + r.winsCount);
    final totalLosses = _reports.fold<int>(0, (sum, r) => sum + r.lossesCount);
    final totalDraws = _reports.fold<int>(0, (sum, r) => sum + r.drawsCount);
    final totalMatches = totalWins + totalLosses + totalDraws;
    final overallWinRate = totalMatches > 0
        ? ((totalWins / totalMatches) * 100).toStringAsFixed(0)
        : '0';

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 14,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PokemonTcgBadge(size: 26),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Channel GCC Report',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Tasto Esportazione Dati (vicino al +, icona download non invasiva)
          IconButton(
            icon: const Icon(Icons.download_rounded, size: 24, color: AppTheme.ultraBallGold),
            tooltip: 'Esporta Dati',
            onPressed: () => ExportDataDialog.show(context, onDataRestored: _loadReports),
          ),
          // Tasto Account & Sincronizzazione Cloud
          ValueListenableBuilder(
            valueListenable: AuthService.instance.currentUserNotifier,
            builder: (context, user, _) {
              final isAuth = user != null && !user.isAnonymous;
              return IconButton(
                icon: isAuth
                    ? CircleAvatar(
                        radius: 13,
                        backgroundColor: AppTheme.ultraBallGold,
                        child: Text(
                          user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'A',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                      )
                    : const Icon(Icons.cloud_outlined, size: 23, color: AppTheme.textSecondary),
                tooltip: isAuth ? 'Account: ${user.displayName}' : 'Accedi & Cloud Sync',
                onPressed: () => AccountModal.show(context, onStateChanged: _loadReports),
              );
            },
          ),
          // Tasto Nuovo Report (+)
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 28, color: AppTheme.ultraBallGold),
            tooltip: 'Nuovo Report',
            onPressed: () => _openEntryScreen(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: TcgPlaymatBackground(
        child: SafeArea(
          bottom: true,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _reports.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadReports,
                      child: ListView(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 12,
                          bottom: MediaQuery.of(context).padding.bottom + 36,
                        ),
                        children: [
                          // Sezione Quick Actions: Mazzi & Location
                          _buildQuickActionsBar(),
                          const SizedBox(height: 12),

                          // Card statistiche aggregate
                          _buildAggregateStatsCard(
                            totalTournaments: totalTournaments,
                            totalWins: totalWins,
                            totalLosses: totalLosses,
                            totalDraws: totalDraws,
                            winRate: overallWinRate,
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'Tornei Disputati',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Lista dei tornei salvati
                          ..._reports.map((report) => _buildReportItem(report)),

                          // Footer richiesto con Privacy & Note Legali
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Center(
                              child: Column(
                                children: [
                                  const Text(
                                    'Powered By Antonio Canale - BETA',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textMuted,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: () => PrivacyPolicyDialog.show(context),
                                    borderRadius: BorderRadius.circular(6),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: Text(
                                        'Privacy Policy & Note Legali Store',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textMuted,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 36,
      ),
      child: Column(
        children: [
          _buildQuickActionsBar(),
          const SizedBox(height: 48),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
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
                      Icons.folder_open_rounded,
                      size: 56,
                      color: AppTheme.ultraBallGold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Nessun Torneo Registrato',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Compila la schermata di inserimento per salvare il tuo primo report di un torneo Local in fumetteria!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.ultraBallGold,
                      foregroundColor: const Color(0xFF0F172A),
                    ),
                    onPressed: () => _openEntryScreen(),
                    icon: const Icon(Icons.add),
                    label: const Text('Compila Nuovo Report', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 36),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Powered By Antonio Canale - BETA',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () => PrivacyPolicyDialog.show(context),
                          borderRadius: BorderRadius.circular(6),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text(
                              'Privacy Policy & Note Legali Store',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textMuted,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsBar() {
    return Row(
      children: [
        // Tasto I Miei Mazzi
        Expanded(
          child: InkWell(
            onTap: _openDeckManager,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.darkBorder, width: 1.2),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppTheme.ultraBallGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.style_rounded, color: AppTheme.ultraBallGold, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mazzi',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '$_decksCount ${_decksCount == 1 ? 'mazzo' : 'mazzi'}',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Tasto Location
        Expanded(
          child: InkWell(
            onTap: _openLocationManager,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.darkBorder, width: 1.2),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppTheme.pokedexRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.storefront_rounded, color: AppTheme.pokedexRed, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '$_locationsCount ${_locationsCount == 1 ? 'sede' : 'sedi'}',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeckStatsModal(BuildContext context) {
    if (_reports.isEmpty) return;

    // Raggruppa i mazzi utilizzati calcolando frequenza e record
    final Map<String, _DeckAggregateStats> statsMap = {};
    for (final report in _reports) {
      final deck = report.deckUsed.trim().isNotEmpty
          ? report.deckUsed.trim()
          : 'Mazzo non specificato';

      final stat = statsMap.putIfAbsent(
        deck,
        () => _DeckAggregateStats(deckName: deck),
      );
      stat.count++;
      stat.wins += report.winsCount;
      stat.losses += report.lossesCount;
      stat.draws += report.drawsCount;
    }

    final sortedStats = statsMap.values.toList()
      ..sort((a, b) {
        final cmp = b.count.compareTo(a.count);
        if (cmp != 0) return cmp;
        return b.winRate.compareTo(a.winRate);
      });

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: AppTheme.darkSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppTheme.darkBorder, width: 1.5),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 12.0,
                bottom: MediaQuery.of(ctx).padding.bottom + 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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

                  // Header modale
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.ultraBallGold.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.pie_chart_rounded,
                          color: AppTheme.ultraBallGold,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mazzi Utilizzati nei Tornei',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              '${_reports.length} tornei registrati in totale',
                              style: const TextStyle(
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
                  const Divider(color: AppTheme.darkBorder, height: 1),
                  const SizedBox(height: 12),

                  // Lista mazzi
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: sortedStats.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, index) {
                        final item = sortedStats[index];
                        final usagePercent = (item.count / _reports.length) * 100;
                        final wrColor = TournamentReport.getWinRateColor(item.winRate);

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.darkCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.darkBorder,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.deckName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.ultraBallGold.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppTheme.ultraBallGold.withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Text(
                                      '${item.count} ${item.count == 1 ? 'torneo' : 'tornei'} (${usagePercent.toStringAsFixed(1)}%)',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.ultraBallGold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Barra di percentuale
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: usagePercent / 100,
                                  minHeight: 6,
                                  backgroundColor: AppTheme.inputFill,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppTheme.ultraBallGold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Record e Win Rate specifico mazzo
                              Row(
                                children: [
                                  Text(
                                    'Record: ${item.wins}-${item.losses}-${item.draws}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Win Rate: ${item.winRate.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: wrColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAggregateStatsCard({
    required int totalTournaments,
    required int totalWins,
    required int totalLosses,
    required int totalDraws,
    required String winRate,
  }) {
    final wrDouble = double.tryParse(winRate) ?? 0.0;
    final wrColor = TournamentReport.getWinRateColor(wrDouble);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.query_stats, color: AppTheme.ultraBallGold, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Riepilogo Tornei',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.ultraBallGold,
                    backgroundColor: AppTheme.ultraBallGold.withValues(alpha: 0.12),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: AppTheme.ultraBallGold.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.pie_chart_rounded, size: 16),
                  label: const Text(
                    '% Mazzi',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _reports.isEmpty ? null : () => _showDeckStatsModal(context),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatMiniCol('Tornei', '$totalTournaments', AppTheme.ultraBallGold),
                _buildStatMiniCol('Record', '$totalWins-$totalLosses-$totalDraws', AppTheme.textPrimary),
                _buildStatMiniCol('Win Rate', '$winRate%', wrColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatMiniCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildReportItem(TournamentReport report) {
    final dateStr = DateFormat('dd/MM/yyyy', 'it_IT').format(report.eventDate);

    final locationText = report.location.isNotEmpty ? ' @ ${report.location}' : '';
    final placementText = report.relativePlacementDisplay.isNotEmpty ? ' • Pos: ${report.relativePlacementDisplay}' : '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const PokemonTcgBadge(size: 42),
        title: Text(
          report.deckUsed.isNotEmpty ? report.deckUsed : 'Mazzo non specificato',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            '$dateStr • ${report.eventType}$locationText$placementText',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.inputFill,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: report.scoreColor.withValues(alpha: 0.6),
              width: 1.2,
            ),
          ),
          child: Text(
            report.finalScoreDisplay,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: report.scoreColor,
            ),
          ),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          const Divider(color: AppTheme.darkBorder),
          // Dettaglio Posizione, Negozio e Punti
          Row(
            children: [
              if (report.relativePlacementDisplay.isNotEmpty) ...[
                const Icon(Icons.emoji_events, size: 16, color: AppTheme.ultraBallGold),
                const SizedBox(width: 4),
                Text(
                  'Pos: ${report.relativePlacementDisplay}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(width: 12),
              ],
              if (report.location.isNotEmpty) ...[
                const Icon(Icons.storefront, size: 16, color: AppTheme.pokemonBlueLight),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    report.location,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (report.pointsEarned.isNotEmpty) ...[
                const Icon(Icons.stars, size: 16, color: AppTheme.pokemonBlueLight),
                const SizedBox(width: 4),
                Text(
                  report.pointsEarned,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(width: 12),
              ],
              const Spacer(),
              Text(
                'Win Rate: ${report.winRateDisplay}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Elenco Match disputati
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Partite disputate:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
            ),
          ),
          const SizedBox(height: 6),
          ...report.rounds.map((round) {
            Color outcomeColor = AppTheme.textSecondary;
            if (round.outcome == MatchOutcome.win) outcomeColor = AppTheme.winGreenLight;
            if (round.outcome == MatchOutcome.loss) outcomeColor = AppTheme.lossRedLight;
            if (round.outcome == MatchOutcome.draw) outcomeColor = AppTheme.drawYellowLight;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              child: Row(
                children: [
                  Text(
                    'T${round.roundNumber}: vs ',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                  Expanded(
                    child: Text(
                      round.opponentDeck.isNotEmpty ? round.opponentDeck : '(Mazzo non indicato)',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: outcomeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: outcomeColor, width: 1),
                    ),
                    child: Text(
                      round.outcome.code,
                      style: TextStyle(color: outcomeColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),

          // Retrospettiva
          if (report.whatWorked.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.winGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.winGreen.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ha funzionato:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.winGreenLight),
                  ),
                  const SizedBox(height: 4),
                  Text(report.whatWorked, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          if (report.toImprove.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.lossRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.lossRed.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Da migliorare:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.lossRedLight),
                  ),
                  const SizedBox(height: 4),
                  Text(report.toImprove, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Azioni sul report (Modifica / Elimina)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Modifica'),
                onPressed: () => _openEntryScreen(report),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: AppTheme.lossRedLight),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Elimina'),
                onPressed: () => _deleteReport(report),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeckAggregateStats {
  final String deckName;
  int count = 0;
  int wins = 0;
  int losses = 0;
  int draws = 0;

  _DeckAggregateStats({required this.deckName});

  double get winRate {
    final total = wins + losses + draws;
    if (total == 0) return 0.0;
    return (wins / total) * 100;
  }
}
