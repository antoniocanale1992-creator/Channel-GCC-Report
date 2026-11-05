import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/deck_model.dart';
import '../models/location_model.dart';
import '../models/tournament_report.dart';

/// Servizio per la memorizzazione locale dei report tornei, mazzi e location tramite SharedPreferences
class StorageService {
  static const String _storageKey = 'pokemon_gcc_tournament_reports';
  static const String _storageKeyDecks = 'pokemon_gcc_decks';
  static const String _storageKeyLocations = 'pokemon_gcc_locations';
  static StorageService? _instance;

  StorageService._();

  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  /// Recupera tutti i report salvati, ordinati dal più recente al meno recente
  Future<List<TournamentReport>> getReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? rawList = prefs.getStringList(_storageKey);

      if (rawList == null || rawList.isEmpty) {
        return [];
      }

      final reports = rawList.map((itemStr) {
        final Map<String, dynamic> jsonMap = jsonDecode(itemStr);
        return TournamentReport.fromJson(jsonMap);
      }).toList();

      // Ordina per data evento (più recenti prima)
      reports.sort((a, b) => b.eventDate.compareTo(a.eventDate));
      return reports;
    } catch (e) {
      // In caso di errore o parsing fallito, restituisce lista vuota
      return [];
    }
  }

  /// Salva o aggiorna un report
  Future<bool> saveReport(TournamentReport report) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<TournamentReport> currentReports = await getReports();

      // Rimuove eventuale report preesistente con lo stesso ID
      currentReports.removeWhere((r) => r.id == report.id);

      // Inserisce in testa
      currentReports.insert(0, report);

      final List<String> encodedList = currentReports
          .map((r) => jsonEncode(r.toJson()))
          .toList();

      return await prefs.setStringList(_storageKey, encodedList);
    } catch (e) {
      return false;
    }
  }

  /// Elimina un report dato il suo ID
  Future<bool> deleteReport(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<TournamentReport> currentReports = await getReports();

      currentReports.removeWhere((r) => r.id == id);

      final List<String> encodedList = currentReports
          .map((r) => jsonEncode(r.toJson()))
          .toList();

      return await prefs.setStringList(_storageKey, encodedList);
    } catch (e) {
      return false;
    }
  }

  /// Cancella tutti i dati salvati
  Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      await prefs.remove(_storageKeyDecks);
      await prefs.remove(_storageKeyLocations);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== GESTIONE MAZZI ====================

  /// Recupera tutti i mazzi salvati dall'utente
  Future<List<DeckModel>> getDecks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? rawList = prefs.getStringList(_storageKeyDecks);

      if (rawList == null || rawList.isEmpty) {
        return [];
      }

      final decks = rawList.map((itemStr) {
        final Map<String, dynamic> jsonMap = jsonDecode(itemStr);
        return DeckModel.fromJson(jsonMap);
      }).toList();

      // Ordina per data (più recenti prima)
      decks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return decks;
    } catch (e) {
      return [];
    }
  }

  /// Salva o aggiorna un mazzo
  Future<bool> saveDeck(DeckModel deck) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<DeckModel> currentDecks = await getDecks();

      currentDecks.removeWhere((d) => d.id == deck.id);
      currentDecks.insert(0, deck);

      final List<String> encodedList = currentDecks
          .map((d) => jsonEncode(d.toJson()))
          .toList();

      return await prefs.setStringList(_storageKeyDecks, encodedList);
    } catch (e) {
      return false;
    }
  }

  /// Elimina un mazzo dato il suo ID
  Future<bool> deleteDeck(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<DeckModel> currentDecks = await getDecks();

      currentDecks.removeWhere((d) => d.id == id);

      final List<String> encodedList = currentDecks
          .map((d) => jsonEncode(d.toJson()))
          .toList();

      return await prefs.setStringList(_storageKeyDecks, encodedList);
    } catch (e) {
      return false;
    }
  }

  // ==================== GESTIONE LOCATION ====================

  /// Recupera tutte le location salvate dall'utente
  Future<List<LocationModel>> getLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? rawList = prefs.getStringList(_storageKeyLocations);

      if (rawList == null || rawList.isEmpty) {
        return [];
      }

      final locations = rawList.map((itemStr) {
        final Map<String, dynamic> jsonMap = jsonDecode(itemStr);
        return LocationModel.fromJson(jsonMap);
      }).toList();

      // Ordina per nome alfabetico
      locations.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return locations;
    } catch (e) {
      return [];
    }
  }

  /// Salva o aggiorna una location
  Future<bool> saveLocation(LocationModel location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<LocationModel> currentLocations = await getLocations();

      currentLocations.removeWhere((l) => l.id == location.id);
      currentLocations.insert(0, location);

      final List<String> encodedList = currentLocations
          .map((l) => jsonEncode(l.toJson()))
          .toList();

      return await prefs.setStringList(_storageKeyLocations, encodedList);
    } catch (e) {
      return false;
    }
  }

  /// Elimina una location dato il suo ID
  Future<bool> deleteLocation(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<LocationModel> currentLocations = await getLocations();

      currentLocations.removeWhere((l) => l.id == id);

      final List<String> encodedList = currentLocations
          .map((l) => jsonEncode(l.toJson()))
          .toList();

      return await prefs.setStringList(_storageKeyLocations, encodedList);
    } catch (e) {
      return false;
    }
  }
}
