import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const ink = Color(0xFF251F1C);
  static const chalk = Color(0xFFF1EDE6);
  static const rouge = Color(0xFFA6334A);
  static const brass = Color(0xFFB8935A);
  static const sage = Color(0xFF6E7B62);
  static const rust = Color(0xFFB4462F);
  static const paper = Colors.white;
}

class AppTheme {
  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.chalk,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.rouge,
        primary: AppColors.rouge,
        secondary: AppColors.brass,
        surface: AppColors.paper,
        onSurface: AppColors.ink,
        error: AppColors.rust,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.fraunces(
            fontWeight: FontWeight.bold, color: AppColors.ink, fontSize: 32),
        displayMedium: GoogleFonts.fraunces(
            fontWeight: FontWeight.bold, color: AppColors.ink, fontSize: 28),
        headlineLarge: GoogleFonts.fraunces(
            fontWeight: FontWeight.w600, color: AppColors.ink, fontSize: 24),
        headlineMedium: GoogleFonts.fraunces(
            fontWeight: FontWeight.w600, color: AppColors.ink, fontSize: 20),
        bodyLarge: GoogleFonts.inter(color: AppColors.rouge, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: AppColors.rouge, fontSize: 14),
        labelSmall: GoogleFonts.ibmPlexMono(
            color: AppColors.ink, fontSize: 10, letterSpacing: 1.5),
        labelMedium: GoogleFonts.ibmPlexMono(
            color: AppColors.ink, fontSize: 12, letterSpacing: 1.5),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.chalk,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Fraunces',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.ink,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rouge,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.ink, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFDED9D1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFDED9D1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
        ),
        labelStyle: GoogleFonts.inter(color: AppColors.ink.withOpacity(0.6)),
        hintStyle: GoogleFonts.inter(color: AppColors.ink.withOpacity(0.4)),
      ),
      cardTheme: CardThemeData(
        color: AppColors.paper,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0xFFDED9D1), width: 1),
        ),
      ),
    );
  }
}
