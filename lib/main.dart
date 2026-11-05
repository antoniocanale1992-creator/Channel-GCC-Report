import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/tournament_history_screen.dart';
import 'theme/app_theme.dart';

import 'package:firebase_core/firebase_core.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init: $e');
  }
  await AuthService.instance.init();
  runApp(const PokemonGccTrackerApp());
}

/// Applicazione per la gestione e il tracciamento dei tornei Local di Pokémon GCC
class PokemonGccTrackerApp extends StatelessWidget {
  const PokemonGccTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Channel GCC Report',
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
      home: const TournamentHistoryScreen(),
    );
  }
}
