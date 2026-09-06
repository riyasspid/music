// ────────────────────────────────────────────────────────────────────────────
// Neumorphism Design System — colors, shadows, text styles
// ────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Color Palette ───────────────────────────────────────────────────────────
const Color neuBase     = Color(0xFFE0E5EC);
const Color neuLight    = Color(0xFFFFFFFF);
const Color neuDark     = Color(0xFFA3B1C6);
const Color accentBlue  = Color(0xFF5B8DEF);
const Color accentPurple = Color(0xFF8B6FE8);
const Color textDark    = Color(0xFF2D3748);
const Color textMid     = Color(0xFF718096);
const Color textLight   = Color(0xFFA0AEC0);
const Color likeRed     = Color(0xFFFF5E7E);

// ─── Layout Constants ─────────────────────────────────────────────────────────
/// Bottom clearance = mini player (70) + margins (8) + nav bar (56) + extra (16)
const double kBottomClearance = 150.0;

// ─── Shadow Helpers ──────────────────────────────────────────────────────────
List<BoxShadow> get neuRaisedShadow => const [
      BoxShadow(
        color: Color(0xFFFFFFFF),
        blurRadius: 12,
        offset: Offset(-4, -4),
      ),
      BoxShadow(
        color: Color(0xFFA3B1C6),
        blurRadius: 12,
        offset: Offset(4, 4),
      ),
    ];

List<BoxShadow> get neuInsetShadow => const [
      BoxShadow(
        color: Color(0xFFA3B1C6),
        blurRadius: 8,
        offset: Offset(3, 3),
        spreadRadius: -1,
      ),
      BoxShadow(
        color: Color(0xFFFFFFFF),
        blurRadius: 8,
        offset: Offset(-3, -3),
        spreadRadius: -1,
      ),
    ];

List<BoxShadow> get neuSoftShadow => const [
      BoxShadow(
        color: Color(0xFFFFFFFF),
        blurRadius: 6,
        offset: Offset(-2, -2),
      ),
      BoxShadow(
        color: Color(0xFFA3B1C6),
        blurRadius: 6,
        offset: Offset(2, 2),
      ),
    ];

// ─── Theme ───────────────────────────────────────────────────────────────────
ThemeData buildAppTheme() {
  final baseTextTheme = GoogleFonts.outfitTextTheme();
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: neuBase,
    fontFamily: GoogleFonts.outfit().fontFamily,
    colorScheme: const ColorScheme.light(
      primary: accentBlue,
      secondary: accentPurple,
      surface: neuBase,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: neuBase,
      foregroundColor: textDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textDark,
      ),
    ),
    textTheme: baseTextTheme.copyWith(
      headlineLarge: GoogleFonts.outfit(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: textDark,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textDark,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textMid,
      ),
      labelSmall: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textLight,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: neuBase,
      selectedItemColor: accentBlue,
      unselectedItemColor: textMid,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
  );
}
