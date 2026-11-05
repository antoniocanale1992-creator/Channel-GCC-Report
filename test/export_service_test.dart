import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon_gcc_tracker/models/deck_model.dart';
import 'package:pokemon_gcc_tracker/models/location_model.dart';
import 'package:pokemon_gcc_tracker/models/tournament_report.dart';
import 'package:pokemon_gcc_tracker/services/export_service.dart';
import 'package:pokemon_gcc_tracker/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ExportService Tests', () {
    test('Generazione corretta del backup JSON con dati di test', () async {
      final storage = StorageService.instance;
      await storage.saveDeck(DeckModel(id: 'd1', name: 'Slowking / Kangaskhan', decklist: ''));
      await storage.saveLocation(LocationModel(id: 'l1', name: 'Games Academy'));
      await storage.saveReport(TournamentReport(
        id: 't1',
        eventDate: DateTime(2026, 11, 5),
        eventType: 'Local',
        deckUsed: 'Slowking',
        roundsCount: 3,
        rounds: [],
      ));

      final jsonStr = await ExportService.instance.exportBackupJson();
      expect(jsonStr.contains('Channel GCC Report'), isTrue);
      expect(jsonStr.contains('Slowking / Kangaskhan'), isTrue);
      expect(jsonStr.contains('Games Academy'), isTrue);
    });

    test('Generazione corretta del riepilogo testuale condivisibile', () async {
      final storage = StorageService.instance;
      await storage.saveDeck(DeckModel(id: 'd1', name: 'Slowking ex', decklist: ''));
      await storage.saveLocation(LocationModel(id: 'l1', name: 'Fumetteria Alpha'));

      final textSummary = await ExportService.instance.exportTextSummary();
      expect(textSummary.contains('CHANNEL GCC REPORT - RIEPILOGO DATI'), isTrue);
      expect(textSummary.contains('Slowking ex'), isTrue);
      expect(textSummary.contains('Fumetteria Alpha'), isTrue);
    });

    test('Ripristino e importazione corretta da stringa JSON', () async {
      const sampleBackup = '''
{
  "appName": "Channel GCC Report",
  "schemaVersion": "1.2",
  "tournaments": [
    {
      "id": "restored_1",
      "eventDate": "2026-11-05T10:00:00.000",
      "eventType": "League Challenge",
      "deckUsed": "Miraidon ex",
      "roundsCount": 3,
      "rounds": []
    }
  ],
  "decks": [
    {
      "id": "deck_restored",
      "name": "Miraidon Turbo",
      "decklist": "Pokémon: 10\\nTrainer: 30"
    }
  ],
  "locations": [
    {
      "id": "loc_restored",
      "name": "Jolly Joker",
      "type": "Fumetteria"
    }
  ]
}
''';

      final result = await ExportService.instance.restoreFromBackupJson(sampleBackup);
      expect(result.success, isTrue);
      expect(result.tournamentsCount, equals(1));
      expect(result.decksCount, equals(1));
      expect(result.locationsCount, equals(1));

      final storage = StorageService.instance;
      final reports = await storage.getReports();
      final decks = await storage.getDecks();
      final locations = await storage.getLocations();

      expect(reports.length, equals(1));
      expect(reports.first.deckUsed, equals('Miraidon ex'));
      expect(decks.first.name, equals('Miraidon Turbo'));
      expect(locations.first.name, equals('Jolly Joker'));
    });
  });
}
