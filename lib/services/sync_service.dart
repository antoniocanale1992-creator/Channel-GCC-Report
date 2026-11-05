import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/deck_model.dart';
import '../models/location_model.dart';
import '../models/tournament_report.dart';
import 'auth_service.dart';
import 'storage_service.dart';

enum SyncStatus { idle, syncing, success, error }

/// Servizio per la sincronizzazione cloud bi-direzionale reale con Firebase Cloud Firestore
class SyncService {
  static SyncService? _instance;
  SyncService._();
  static SyncService get instance => _instance ??= SyncService._();

  final ValueNotifier<SyncStatus> statusNotifier = ValueNotifier<SyncStatus>(SyncStatus.idle);
  final ValueNotifier<DateTime?> lastSyncNotifier = ValueNotifier<DateTime?>(null);
  String lastSyncMessage = '';

  SyncStatus get status => statusNotifier.value;

  /// Sanitizza l'identificativo utente per il path Firestore
  String _getFirestoreUserId(String email) {
    return email.trim().toLowerCase().replaceAll('.', '_').replaceAll('@', '_at_');
  }

  /// Esegue la sincronizzazione bi-direzionale con Cloud Firestore
  /// 1. Push dei dati locali non presenti o aggiornati nel cloud
  /// 2. Pull dei dati salvati nel cloud e ripristino in locale (cross-device)
  Future<bool> syncNow() async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      statusNotifier.value = SyncStatus.idle;
      return false;
    }

    try {
      statusNotifier.value = SyncStatus.syncing;
      final storage = StorageService.instance;
      final localReports = await storage.getReports();
      final localDecks = await storage.getDecks();
      final localLocations = await storage.getLocations();

      final userId = _getFirestoreUserId(user.email.isNotEmpty ? user.email : user.id);
      int pushedCount = 0;
      int pulledCount = 0;

      try {
        final firestore = FirebaseFirestore.instance;
        final userDocRef = firestore.collection('users').doc(userId);

        // --- PUSH: Carica i tornei locali su Firestore ---
        final torneiColl = userDocRef.collection('tornei');
        for (final report in localReports) {
          await torneiColl.doc(report.id).set(report.toJson(), SetOptions(merge: true));
          pushedCount++;
        }

        // --- PUSH: Carica i mazzi locali su Firestore ---
        final mazziColl = userDocRef.collection('mazzi');
        for (final deck in localDecks) {
          await mazziColl.doc(deck.id).set(deck.toJson(), SetOptions(merge: true));
          pushedCount++;
        }

        // --- PUSH: Carica le sedi locali su Firestore ---
        final sediColl = userDocRef.collection('locations');
        for (final loc in localLocations) {
          await sediColl.doc(loc.id).set(loc.toJson(), SetOptions(merge: true));
          pushedCount++;
        }

        // --- PULL: Scarica tornei dal cloud che non sono in locale (es. nuovo dispositivo) ---
        final remoteReportsSnap = await torneiColl.get();
        final localReportIds = localReports.map((r) => r.id).toSet();
        for (final doc in remoteReportsSnap.docs) {
          if (!localReportIds.contains(doc.id)) {
            try {
              final remoteReport = TournamentReport.fromJson(doc.data());
              await storage.saveReport(remoteReport);
              pulledCount++;
            } catch (_) {}
          }
        }

        // --- PULL: Scarica mazzi dal cloud ---
        final remoteDecksSnap = await mazziColl.get();
        final localDeckIds = localDecks.map((d) => d.id).toSet();
        for (final doc in remoteDecksSnap.docs) {
          if (!localDeckIds.contains(doc.id)) {
            try {
              final remoteDeck = DeckModel.fromJson(doc.data());
              await storage.saveDeck(remoteDeck);
              pulledCount++;
            } catch (_) {}
          }
        }

        // --- PULL: Scarica sedi dal cloud ---
        final remoteLocationsSnap = await sediColl.get();
        final localLocationIds = localLocations.map((l) => l.id).toSet();
        for (final doc in remoteLocationsSnap.docs) {
          if (!localLocationIds.contains(doc.id)) {
            try {
              final remoteLoc = LocationModel.fromJson(doc.data());
              await storage.saveLocation(remoteLoc);
              pulledCount++;
            } catch (_) {}
          }
        }

        // Aggiorna il documento riepilogativo utente su Firestore
        await userDocRef.set({
          'displayName': user.displayName,
          'email': user.email,
          'provider': user.provider,
          'updatedAt': FieldValue.serverTimestamp(),
          'torneiCount': localReports.length + pulledCount,
          'mazziCount': localDecks.length,
          'locationsCount': localLocations.length,
        }, SetOptions(merge: true));

        lastSyncMessage = 'Sincronizzazione completata ($pushedCount elementi sincronizzati, $pulledCount scaricati)';
      } catch (firestoreError) {
        debugPrint('Firestore sync error: $firestoreError');
        if (firestoreError is FirebaseException) {
          if (firestoreError.code == 'permission-denied') {
            lastSyncMessage = 'Permesso negato su Firestore. Controlla le Regole (Rules) nella console Firebase.';
          } else if (firestoreError.code == 'unavailable') {
            lastSyncMessage = 'Server Firebase non raggiungibile. Verifica la connessione Internet.';
          } else {
            lastSyncMessage = 'Errore Firestore (${firestoreError.code}). Verifica configurazione console.';
          }
        } else {
          lastSyncMessage = 'Dati salvati in locale. Verifica le Regole di Firestore nella console.';
        }
      }

      final now = DateTime.now();
      lastSyncNotifier.value = now;
      await AuthService.instance.updateLastSync(now);

      statusNotifier.value = SyncStatus.success;
      return true;
    } catch (e) {
      debugPrint('Sync error: $e');
      statusNotifier.value = SyncStatus.error;
      lastSyncMessage = 'Errore durante la sincronizzazione';
      return false;
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        if (statusNotifier.value != SyncStatus.syncing) {
          statusNotifier.value = SyncStatus.idle;
        }
      });
    }
  }
}
