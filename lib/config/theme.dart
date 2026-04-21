import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// MyC Design Tokens — extracted from the HTML prototype
class MyCColors {
  // Brand
  static const accent = Color(0xFF6A5EF7);
  static const accentLight = Color(0xFF9B5EF7);
  static const pink = Color(0xFFFF6A88);
  static const green = Color(0xFF43E97B);
  static const teal = Color(0xFF38F9D7);
  static const gold = Color(0xFFFFCF4A);

  // Dark mode
  static const darkBg = Color(0xFF0B0B12);
  static const darkSurface = Color(0xFF14141E);
  static const darkCard = Color(0xFF1A1A28);
  static const darkText = Color(0xFFF5F5FA);
  static const darkMuted = Color(0xFF8A8A9A);

  // Light mode
  static const lightBg = Color(0xFFF5F5F7);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightText = Color(0xFF111111);
  static const lightMuted = Color(0xFF8E8E93);

  // Status
  static const online = Color(0xFF2ED573);
  static const error = Color(0xFFFF4A5C);

  // Gradients
  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );

  static const pinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9A8B), Color(0xFFFF6A88), Color(0xFFFF99AC)],
  );

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Color(0xFFB5AAFF), Color(0xFFFF9AC8)],
  );
}

class MyCTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: MyCColors.darkBg,
    colorScheme: const ColorScheme.dark(
      primary: MyCColors.accent,
      secondary: MyCColors.pink,
      surface: MyCColors.darkSurface,
    ),
    textTheme: _textTheme(MyCColors.darkText, MyCColors.darkMuted),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    useMaterial3: true,
  );

  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: MyCColors.lightBg,
    colorScheme: const ColorScheme.light(
      primary: MyCColors.accent,
      secondary: MyCColors.pink,
      surface: MyCColors.lightSurface,
    ),
    textTheme: _textTheme(MyCColors.lightText, MyCColors.lightMuted),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    useMaterial3: true,
  );

  static TextTheme _textTheme(Color primary, Color muted) {
    return TextTheme(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -1,
        color: primary,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5,
        color: primary,
      ),
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.3,
        color: primary,
      ),
      titleMedium: GoogleFonts.spaceGrotesk(
        fontSize: 17, fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleSmall: GoogleFonts.spaceGrotesk(
        fontSize: 15, fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400,
        color: muted,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.w600,
        color: primary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w600,
        letterSpacing: 1.5, color: muted,
      ),
    );
  }
}
