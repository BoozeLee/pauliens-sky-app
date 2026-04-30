import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CosmicColors {
  static const background = Color(0xFF0A0520);
  static const surface = Color(0xFF130B35);
  static const card = Color(0xFF1A1040);
  static const divider = Color(0xFF2D1B69);

  static const neonPink = Color(0xFFFF6EFF);
  static const neonCyan = Color(0xFF00F5FF);
  static const neonGreen = Color(0xFF39FF7E);
  static const neonYellow = Color(0xFFFFE84D);
  static const neonLavender = Color(0xFFB57BFF);

  static const textPrimary = Color(0xFFEDE8FF);
  static const textSecondary = Color(0xFF9B8EC4);
  static const textMuted = Color(0xFF5C4F8A);

  // Per-culture accent colors matching the mockup
  static const western = Color(0xFF00F5FF);
  static const chinese = Color(0xFFFF6EFF);
  static const vedic = Color(0xFF39FF7E);
  static const mayan = Color(0xFFFFE84D);
  static const egyptian = Color(0xFFFFB347);
  static const celtic = Color(0xFF7EC8E3);
  static const babylonian = Color(0xFFFF8C69);
}

class CosmicTheme {
  static ThemeData get dark {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: CosmicColors.background,
      colorScheme: const ColorScheme.dark(
        primary: CosmicColors.neonLavender,
        secondary: CosmicColors.neonCyan,
        surface: CosmicColors.surface,
        error: Color(0xFFFF4444),
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: CosmicColors.textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.cinzel(
          color: CosmicColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
        displayMedium: GoogleFonts.cinzel(
          color: CosmicColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
        headlineMedium: GoogleFonts.cinzel(
          color: CosmicColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(
          color: CosmicColors.textPrimary,
          fontSize: 15,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.inter(
          color: CosmicColors.textSecondary,
          fontSize: 13,
          height: 1.5,
        ),
        labelSmall: GoogleFonts.inter(
          color: CosmicColors.textMuted,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: CosmicColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: CosmicColors.divider, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: CosmicColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cinzel(
          color: CosmicColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
        iconTheme: const IconThemeData(color: CosmicColors.textSecondary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: CosmicColors.surface,
        selectedItemColor: CosmicColors.neonLavender,
        unselectedItemColor: CosmicColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CosmicColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CosmicColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CosmicColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CosmicColors.neonLavender, width: 1.5),
        ),
        labelStyle: const TextStyle(color: CosmicColors.textSecondary),
        hintStyle: const TextStyle(color: CosmicColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CosmicColors.neonLavender,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.cinzel(fontWeight: FontWeight.w700, letterSpacing: 1),
        ),
      ),
      dividerColor: CosmicColors.divider,
    );
  }
}
