import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/maintenance_screen.dart';
import 'screens/tournament_history_screen.dart';
import 'services/auth_service.dart';
import 'services/kill_switch_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init: $e');
  }

  // Verifica asincrona del Kill Switch remoto su Firestore config/app_status
  await KillSwitchService.instance.checkAppStatus();
  await AuthService.instance.init();

  runApp(const PokemonGccTrackerApp());
}

/// Applicazione per la gestione e il tracciamento dei tornei Local di Pokémon GCC (PWA & Mobile)
class PokemonGccTrackerApp extends StatefulWidget {
  const PokemonGccTrackerApp({super.key});

  @override
  State<PokemonGccTrackerApp> createState() => _PokemonGccTrackerAppState();
}

class _PokemonGccTrackerAppState extends State<PokemonGccTrackerApp> {
  @override
  void initState() {
    super.initState();
    KillSwitchService.instance.statusNotifier.addListener(_onStatusChanged);
  }

  @override
  void dispose() {
    KillSwitchService.instance.statusNotifier.removeListener(_onStatusChanged);
    super.dispose();
  }

  void _onStatusChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final killStatus = KillSwitchService.instance.currentStatus;

    return MaterialApp(
      title: 'Pokémon TCG Local Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // Supporto localizzazione in lingua italiana per calendari, datepicker e formati
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('it', 'IT'),
        Locale('en', 'US'),
      ],
      locale: const Locale('it', 'IT'),
      home: killStatus.isActive
          ? const TournamentHistoryScreen()
          : MaintenanceScreen(
              message: killStatus.maintenanceMessage,
              onRetry: () => setState(() {}),
            ),
    );
  }
}
