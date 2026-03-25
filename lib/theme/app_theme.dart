import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryDarkBackground = Color(0xFF121B1A);
  static const Color primaryLightBackground = Color(0xFFF6F8F7);
  static const Color cardSurfaceDark = Color(0xFF1F2D2C);
  static const Color primaryTeal = Color(0xFF2F7F7B);
  static const Color accentGreen = Color(0xFF5BEC13);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF121B1A);
  static const Color textMediumEmphasis = Color(0xFF9FBCBB);
  static const Color redBadgeError = Color(0xFFE57373);
  static const Color iconColorInactive = Color(0xFF707070);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryDarkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryTeal,
        secondary: accentGreen,
        surface: cardSurfaceDark,
        onSurface: textLight,
        error: redBadgeError,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(
            fontSize: 24, fontWeight: FontWeight.w700, color: textLight),
        titleLarge: GoogleFonts.spaceGrotesk(
            fontSize: 20, fontWeight: FontWeight.w700, color: textLight),
        titleMedium: GoogleFonts.spaceGrotesk(
            fontSize: 18, fontWeight: FontWeight.w600, color: textLight),
        bodyLarge: GoogleFonts.notoSans(
            fontSize: 16, fontWeight: FontWeight.w400, color: textLight),
        bodyMedium: GoogleFonts.notoSans(
            fontSize: 14, fontWeight: FontWeight.w400, color: textLight),
        bodySmall: GoogleFonts.notoSans(
            fontSize: 12, fontWeight: FontWeight.w400, color: textMediumEmphasis),
        labelLarge: GoogleFonts.roboto(
            fontSize: 14, fontWeight: FontWeight.w500, color: textLight),
        labelSmall: GoogleFonts.roboto(
            fontSize: 10, fontWeight: FontWeight.w500, color: textLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: textLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: primaryLightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryTeal,
        secondary: accentGreen,
        surface: Colors.white,
        onSurface: textDark,
        error: redBadgeError,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(
            fontSize: 24, fontWeight: FontWeight.w700, color: textDark),
        titleLarge: GoogleFonts.spaceGrotesk(
            fontSize: 20, fontWeight: FontWeight.w700, color: textDark),
        titleMedium: GoogleFonts.spaceGrotesk(
            fontSize: 18, fontWeight: FontWeight.w600, color: textDark),
        bodyLarge: GoogleFonts.notoSans(
            fontSize: 16, fontWeight: FontWeight.w400, color: textDark),
        bodyMedium: GoogleFonts.notoSans(
            fontSize: 14, fontWeight: FontWeight.w400, color: textDark),
        bodySmall: GoogleFonts.notoSans(
            fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey[600]),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: textLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
