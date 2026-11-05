import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/deck_model.dart';
import '../models/location_model.dart';
import '../models/tournament_report.dart';
import 'storage_service.dart';

/// Risultato di un'operazione di ripristino/importazione
class RestoreResult {
  final bool success;
  final String message;
  final int tournamentsCount;
  final int decksCount;
  final int locationsCount;

  RestoreResult({
    required this.success,
    required this.message,
    this.tournamentsCount = 0,
    this.decksCount = 0,
    this.locationsCount = 0,
  });
}

/// Servizio per l'esportazione completa dei dati dell'app (JSON, testo, backup & restore)
class ExportService {
  static const String appIdentifier = 'Channel GCC Report';
  static const String schemaVersion = '1.2';

  static ExportService? _instance;
  ExportService._();
  static ExportService get instance => _instance ??= ExportService._();

  /// Genera la mappa JSON strutturata contenente tutti i tornei, mazzi e location
  Future<Map<String, dynamic>> generateBackupData() async {
    final storage = StorageService.instance;
    final reports = await storage.getReports();
    final decks = await storage.getDecks();
    final locations = await storage.getLocations();

    return {
      'appName': appIdentifier,
      'schemaVersion': schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'stats': {
        'totalTournaments': reports.length,
        'totalDecks': decks.length,
        'totalLocations': locations.length,
      },
      'tournaments': reports.map((r) => r.toJson()).toList(),
      'decks': decks.map((d) => d.toJson()).toList(),
      'locations': locations.map((l) => l.toJson()).toList(),
    };
  }

  /// Restituisce il backup completo in formato stringa JSON formattata
  Future<String> exportBackupJson() async {
    final data = await generateBackupData();
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }

  /// Genera un riepilogo testuale formattato e condivisibile (es. chat WhatsApp / note)
  Future<String> exportTextSummary() async {
    final storage = StorageService.instance;
    final reports = await storage.getReports();
    final decks = await storage.getDecks();
    final locations = await storage.getLocations();

    final buffer = StringBuffer();
    final nowStr = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    buffer.writeln('====================================');
    buffer.writeln('⚡ CHANNEL GCC REPORT - RIEPILOGO DATI');
    buffer.writeln('Esportato il: $nowStr');
    buffer.writeln('====================================\n');

    // Statistiche generali
    int totalWins = 0;
    int totalLosses = 0;
    int totalDraws = 0;
    for (final r in reports) {
      totalWins += r.winsCount;
      totalLosses += r.lossesCount;
      totalDraws += r.drawsCount;
    }
    final totalGames = totalWins + totalLosses + totalDraws;
    final wr = totalGames > 0 ? (totalWins / totalGames * 100).toStringAsFixed(1) : '0.0';

    buffer.writeln('📊 RIEPILOGO CARRIERA:');
    buffer.writeln('• Tornei disputati: ${reports.length}');
    buffer.writeln('• Record complessivo: $totalWins W - $totalLosses L - $totalDraws D');
    buffer.writeln('• Win Rate globale: $wr%\n');

    // Elenco Tornei
    if (reports.isNotEmpty) {
      buffer.writeln('🏆 TORNEI DISPUTATI:');
      for (final r in reports) {
        final dStr = DateFormat('dd/MM/yyyy').format(r.eventDate);
        final loc = r.location.isNotEmpty ? ' @ ${r.location}' : '';
        final pos = r.relativePlacementDisplay.isNotEmpty ? ' [Pos: ${r.relativePlacementDisplay}]' : '';
        final pts = r.pointsEarned.isNotEmpty ? ' (${r.pointsEarned})' : '';
        buffer.writeln('• $dStr: ${r.eventType}$loc');
        buffer.writeln('  Mazzo: ${r.deckUsed}');
        buffer.writeln('  Risultato: ${r.finalScoreDisplay} (WR: ${r.winRateDisplay})$pos$pts');
        if (r.whatWorked.isNotEmpty) buffer.writeln('  + Funzionato: ${r.whatWorked}');
        if (r.toImprove.isNotEmpty) buffer.writeln('  - Da migliorare: ${r.toImprove}');
        buffer.writeln('');
      }
    }

    // Elenco Mazzi
    if (decks.isNotEmpty) {
      buffer.writeln('🎴 I MIEI MAZZI REGISTRATI (${decks.length}):');
      for (int i = 0; i < decks.length; i++) {
        final d = decks[i];
        final cards = d.totalCardsCount > 0 ? ' (${d.totalCardsCount} carte)' : '';
        buffer.writeln('  #${i + 1} ${d.name}$cards');
      }
      buffer.writeln('');
    }

    // Elenco Location
    if (locations.isNotEmpty) {
      buffer.writeln('📍 LOCATION & FUMETTERIE (${locations.length}):');
      for (final l in locations) {
        final addr = l.address.isNotEmpty ? ' - ${l.address}' : '';
        buffer.writeln('• ${l.name} [${l.type}]$addr');
      }
      buffer.writeln('');
    }

    buffer.writeln('Powered By Antonio Canale - Channel GCC Report');
    return buffer.toString();
  }

  /// Ripristina / importa un pacchetto di dati JSON
  Future<RestoreResult> restoreFromBackupJson(String rawJson, {bool overwrite = true}) async {
    try {
      if (rawJson.trim().isEmpty) {
        return RestoreResult(success: false, message: 'Il testo JSON fornito è vuoto.');
      }

      final dynamic decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) {
        return RestoreResult(success: false, message: 'Formato JSON non valido (richiesta mappa principale).');
      }

      final rawTournaments = decoded['tournaments'] as List<dynamic>? ?? [];
      final rawDecks = decoded['decks'] as List<dynamic>? ?? [];
      final rawLocations = decoded['locations'] as List<dynamic>? ?? [];

      final storage = StorageService.instance;

      if (overwrite) {
        await storage.clearAll();
      }

      int tCount = 0;
      for (final item in rawTournaments) {
        if (item is Map<String, dynamic>) {
          final report = TournamentReport.fromJson(item);
          await storage.saveReport(report);
          tCount++;
        }
      }

      int dCount = 0;
      for (final item in rawDecks) {
        if (item is Map<String, dynamic>) {
          final deck = DeckModel.fromJson(item);
          await storage.saveDeck(deck);
          dCount++;
        }
      }

      int lCount = 0;
      for (final item in rawLocations) {
        if (item is Map<String, dynamic>) {
          final loc = LocationModel.fromJson(item);
          await storage.saveLocation(loc);
          lCount++;
        }
      }

      return RestoreResult(
        success: true,
        message: 'Ripristino completato con successo!',
        tournamentsCount: tCount,
        decksCount: dCount,
        locationsCount: lCount,
      );
    } catch (e) {
      return RestoreResult(
        success: false,
        message: 'Errore durante la lettura del backup: $e',
      );
    }
  }
}
