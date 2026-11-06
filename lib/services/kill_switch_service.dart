import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Modello dello stato operativo del Kill Switch remoto
class KillSwitchStatus {
  final bool isActive;
  final String maintenanceMessage;

  const KillSwitchStatus({
    required this.isActive,
    required this.maintenanceMessage,
  });

  factory KillSwitchStatus.active() => const KillSwitchStatus(
        isActive: true,
        maintenanceMessage: '',
      );
}

/// Servizio Kill Switch per bloccare l'app da remoto in caso di manutenzione
class KillSwitchService {
  static KillSwitchService? _instance;
  KillSwitchService._();
  static KillSwitchService get instance => _instance ??= KillSwitchService._();

  final ValueNotifier<KillSwitchStatus> statusNotifier =
      ValueNotifier<KillSwitchStatus>(KillSwitchStatus.active());

  KillSwitchStatus get currentStatus => statusNotifier.value;

  /// Interroga Cloud Firestore per il documento config/app_status
  Future<KillSwitchStatus> checkAppStatus() async {
    try {
      final docRef = FirebaseFirestore.instance.collection('config').doc('app_status');
      final doc = await docRef.get().timeout(const Duration(seconds: 4));

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final isActive = data['is_active'] as bool? ?? true;
        final message = (data['maintenance_message'] as String?)?.trim() ??
            'L\'applicazione è attualmente in manutenzione per aggiornamenti tecnici. Riprova più tardi.';

        final status = KillSwitchStatus(
          isActive: isActive,
          maintenanceMessage: message,
        );
        statusNotifier.value = status;
        return status;
      }
    } catch (e) {
      debugPrint('Kill Switch check fallback (offline/non configurato): $e');
    }

    // Se il documento non esiste o in caso di errore offline, prosegue normalmente
    final fallback = KillSwitchStatus.active();
    statusNotifier.value = fallback;
    return fallback;
  }
}
