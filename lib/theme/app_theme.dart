import 'package:flutter/material.dart';

/// Tema grafico moderno e distintivo ispirato al GCC Pokémon (Playmat Arena)
class AppTheme {
  // Colori Brand & Pokémon TCG (Caldi, Energetici, NO Blu Notte!)
  static const Color pokemonBlue = Color(0xFFE11D48); // Poké-Red Crimson
  static const Color pokemonBlueLight = Color(0xFFF59E0B); // Ultra Ball Gold
  static const Color ultraBallGold = Color(0xFFF59E0B); // Oro Ultra Ball
  static const Color ultraBallGoldLight = Color(0xFFFBBF24); // Oro Chiaro
  static const Color pokedexRed = Color(0xFFE11D48); // Rosso Pokédex

  // Colori Risultati (W / L / D)
  static const Color winGreen = Color(0xFF16A34A);      // Energia Erba / Vittoria
  static const Color winGreenLight = Color(0xFF22C55E);
  static const Color lossRed = Color(0xFFDC2626);       // Energia Fuoco / Sconfitta
  static const Color lossRedLight = Color(0xFFEF4444);
  static const Color drawYellow = Color(0xFFD97706);    // Energia Lampo / Pareggio
  static const Color drawYellowLight = Color(0xFFFBBF24);

  // Sfondi e Superfici Slate (#0F172A come colore principale)
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900 - Colore Principale
  static const Color darkBackgroundDeep = Color(0xFF090D16); // Slate 950 Deep
  static const Color darkSurface = Color(0xFF1E293B);    // Slate 800 Surface
  static const Color darkCard = Color(0xFF1E293B);       // Slate 800 Card
  static const Color darkCardElevated = Color(0xFF263349); // Slate 750
  static const Color darkBorder = Color(0xFF334155);     // Slate 700 Border
  static const Color inputFill = Color(0xFF0B1120);      // Slate 950 Recessed Input
  static const Color textPrimary = Color(0xFFF8FAFC);    // Slate 50 Ultra Crisp White
  static const Color textSecondary = Color(0xFF94A3B8);  // Slate 400 Readable Subtext
  static const Color textMuted = Color(0xFF64748B);      // Slate 500

  /// Tema Ufficiale Warm Titanium TCG Collector
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: ultraBallGold,
        secondary: pokedexRed,
        surface: darkSurface,
        error: lossRedLight,
        onPrimary: Color(0xFF0F172A),
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 1.4),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 0.3,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ultraBallGold, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lossRedLight),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ultraBallGold,
          foregroundColor: const Color(0xFF0F172A),
          elevation: 4,
          shadowColor: ultraBallGold.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurface,
        selectedColor: ultraBallGold,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: darkBorder),
        ),
        labelStyle: const TextStyle(color: textPrimary, fontSize: 13),
      ),
    );
  }
}
