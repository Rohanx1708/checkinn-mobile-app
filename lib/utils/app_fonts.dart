import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FontConfig {
  static bool _fontsLoaded = false;
  
  static Future<void> initializeFonts() async {
    if (_fontsLoaded) return;
    
    try {
      // Preload Inter and Poppins fonts to avoid runtime errors
      await GoogleFonts.pendingFonts([
        GoogleFonts.inter(),
        GoogleFonts.inter(fontWeight: FontWeight.w300),
        GoogleFonts.inter(fontWeight: FontWeight.w400),
        GoogleFonts.inter(fontWeight: FontWeight.w500),
        GoogleFonts.poppins(),
        GoogleFonts.poppins(fontWeight: FontWeight.w500),
        GoogleFonts.poppins(fontWeight: FontWeight.w600),
        GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ]);
      _fontsLoaded = true;
      print('✅ Google Fonts loaded successfully');
    } catch (e) {
      print('⚠️ Google Fonts failed to load, using system fonts: $e');
      _fontsLoaded = false;
    }
  }
}

class AppFonts {
  static TextStyle poppins({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    // Always try Google Fonts first, but provide fallback
    try {
      return GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        decoration: decoration,
      );
    } catch (e) {
      // Fallback to system font if Google Fonts fails
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        decoration: decoration,
        fontFamily: 'Roboto', // Android default
      );
    }
  }

  static TextStyle poppinsBold({
    double? fontSize,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return poppins(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }

  static TextStyle poppinsMedium({
    double? fontSize,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return poppins(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }

  static TextStyle poppinsSemiBold({
    double? fontSize,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return poppins(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }

  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    // Always try Google Fonts first, but provide fallback
    try {
      return GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        decoration: decoration,
      );
    } catch (e) {
      // Fallback to system font if Google Fonts fails
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        decoration: decoration,
        fontFamily: 'Roboto', // Android default
      );
    }
  }

  static TextStyle interLight({
    double? fontSize,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w300,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }

  static TextStyle interMedium({
    double? fontSize,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }
}