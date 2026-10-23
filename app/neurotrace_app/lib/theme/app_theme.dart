import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const teal = Color(0xFF1FA59A);
  static const tealDark = Color(0xFF14857C);
  static const mint = Color(0xFFE3F6F3);
  static const peach = Color(0xFFF6A68C);
  static const peachLight = Color(0xFFFDEDE6);
  static const bgTop = Color(0xFFF1FAF8);
  static const bgBottom = Color(0xFFFDF3EF);
  static const text = Color(0xFF1E2A32);
  static const textMuted = Color(0xFF6B7A85);
  static const low = Color(0xFF2E9E6B);
  static const medium = Color(0xFFE8A33D);
  static const high = Color(0xFFE0524A);
  static const heart = Color(0xFFE85D5D);

  static Color risk(double r) => r >= 0.6 ? high : (r >= 0.35 ? medium : low);
  static String riskLabel(double r) =>
      r >= 0.6 ? 'High' : (r >= 0.35 ? 'Medium' : 'Low');
}

class AppSpace {
  static const xs = 4.0;
  static const s = 8.0;
  static const m = 16.0;
  static const l = 24.0;
  static const xl = 32.0;
  static const screen = 20.0;
  static const radius = 22.0;
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.teal,
        primary: AppColors.teal,
        secondary: AppColors.peach,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.bgTop,
    );
    final text = GoogleFonts.poppinsTextTheme(base.textTheme).apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    );
    return base.copyWith(
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.text,
        titleTextStyle: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.text),
      ),
      sliderTheme: base.sliderTheme.copyWith(
        activeTrackColor: AppColors.teal,
        inactiveTrackColor: AppColors.mint,
        thumbColor: AppColors.teal,
        overlayColor: AppColors.teal.withOpacity(0.12),
        trackHeight: 6,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? Colors.white : null),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.teal : null),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.text,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

/// Shared text styles.
class AppText {
  static TextStyle bigNumber([Color c = AppColors.text]) =>
      GoogleFonts.poppins(fontSize: 34, fontWeight: FontWeight.w700, color: c, height: 1.1);
  static TextStyle title = GoogleFonts.poppins(
      fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.text);
  static TextStyle section = GoogleFonts.poppins(
      fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text);
  static TextStyle body = GoogleFonts.poppins(
      fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.text);
  static TextStyle muted = GoogleFonts.poppins(
      fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMuted);
  static TextStyle label = GoogleFonts.poppins(
      fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMuted);
}
