import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MimioColors {
  static const primary = Color(0xFF6C63FF);
  static const primaryLight = Color(0xFF9B95FF);
  static const background = Color(0xFFF8F7FF);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B6B8D);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFB74D);

  static const taskColors = [
    '#6C63FF', '#FF6B9D', '#4ECDC4', '#FFE66D',
    '#FF8B5A', '#A8E6CF', '#DDA0DD', '#87CEEB',
    '#F7DC6F', '#E74C3C', '#3498DB', '#2ECC71',
  ];

  static Color fromHex(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }
}

class MimioTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MimioColors.primary,
        brightness: Brightness.light,
        surface: MimioColors.surface,
      ),
      scaffoldBackgroundColor: MimioColors.background,
      textTheme: GoogleFonts.nunitoTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: MimioColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: MimioColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: MimioColors.textPrimary),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: MimioColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE8E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: MimioColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MimioColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
