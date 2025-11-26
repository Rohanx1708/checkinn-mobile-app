import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1F2937), // Dark charcoal matching logo
      onPrimary: Colors.white,
      secondary: Color(0xFF6B7280), // Light grey matching logo text
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF1F2937),
      background: Colors.white,
      onBackground: Color(0xFF1F2937),
      error: Color(0xFFEF4444),
      onError: Colors.white,
    ),
    fontFamily: 'Inter',
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w300),
      displayMedium: GoogleFonts.inter(fontWeight: FontWeight.w300),
      displaySmall: GoogleFonts.inter(fontWeight: FontWeight.w300),
      headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.w400),
      headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w400),
      headlineSmall: GoogleFonts.inter(fontWeight: FontWeight.w400),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w500),
      titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w500),
      titleSmall: GoogleFonts.inter(fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w400),
      bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w400),
      bodySmall: GoogleFonts.inter(fontWeight: FontWeight.w400),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w500),
      labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w500),
      labelSmall: GoogleFonts.inter(fontWeight: FontWeight.w500),
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: Color(0xFF1F2937),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF1F2937), width: 1.5),
      ),
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF1F2937), // Dark charcoal matching logo
      onPrimary: Colors.white,
      secondary: Color(0xFF9CA3AF), // Lighter grey for dark mode
      onSecondary: Colors.white,
      surface: Color(0xFF111827),
      onSurface: Colors.white,
      background: Color(0xFF111827),
      onBackground: Colors.white,
      error: Color(0xFFF87171),
      onError: Colors.white,
    ),
    fontFamily: 'Inter',
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w300),
      displayMedium: GoogleFonts.inter(fontWeight: FontWeight.w300),
      displaySmall: GoogleFonts.inter(fontWeight: FontWeight.w300),
      headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.w400),
      headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w400),
      headlineSmall: GoogleFonts.inter(fontWeight: FontWeight.w400),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w500),
      titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w500),
      titleSmall: GoogleFonts.inter(fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w400),
      bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w400),
      bodySmall: GoogleFonts.inter(fontWeight: FontWeight.w400),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w500),
      labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w500),
      labelSmall: GoogleFonts.inter(fontWeight: FontWeight.w500),
    ),
    scaffoldBackgroundColor: const Color(0xFF111827),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF111827),
      elevation: 0,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF1F2937),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF374151)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF374151)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF1F2937), width: 1.5),
      ),
    ),
  );
}


