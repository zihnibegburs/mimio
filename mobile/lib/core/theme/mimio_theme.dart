import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimio/core/storage/settings_storage.dart';

/// Calm Horizon — soft teal & warm coral palette for neurodivergent-friendly focus.
class MimioColors {
  static const primary = Color(0xFF3D9B87);
  static const primaryLight = Color(0xFF6BBFB0);
  static const accent = Color(0xFFE07A5F);
  static const success = Color(0xFF48A67C);
  static const warning = Color(0xFFE8A838);

  // Light semantic defaults (prefer [MimioPalette] via context in widgets).
  static const background = Color(0xFFF4F9F8);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF1C2826);
  static const textSecondary = Color(0xFF5F7A76);
  static const border = Color(0xFFDDE8E6);

  static const taskColors = [
    '#3D9B87', '#E07A5F', '#6BBFB0', '#B794F4',
    '#4A90D9', '#F4C542', '#E8849A', '#7BC47F',
    '#5B8DEF', '#D4A76A', '#9B87C4', '#56B4A6',
  ];

  static Color fromHex(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }
}

@immutable
class MimioPalette extends ThemeExtension<MimioPalette> {
  const MimioPalette({
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
  });

  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;

  static const light = MimioPalette(
    background: Color(0xFFF4F9F8),
    surface: Colors.white,
    textPrimary: Color(0xFF1C2826),
    textSecondary: Color(0xFF5F7A76),
    border: Color(0xFFDDE8E6),
  );

  static const dark = MimioPalette(
    background: Color(0xFF0F1614),
    surface: Color(0xFF1A2422),
    textPrimary: Color(0xFFE8F2F0),
    textSecondary: Color(0xFF8FA8A4),
    border: Color(0xFF2E3E3B),
  );

  @override
  MimioPalette copyWith({
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
  }) {
    return MimioPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
    );
  }

  @override
  MimioPalette lerp(MimioPalette? other, double t) {
    if (other == null) return this;
    return MimioPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}

extension MimioPaletteContext on BuildContext {
  MimioPalette get palette =>
      Theme.of(this).extension<MimioPalette>() ?? MimioPalette.light;
}

enum AppThemePreference { system, light, dark }

final appThemeModeProvider =
    AsyncNotifierProvider<AppThemeModeNotifier, ThemeMode>(AppThemeModeNotifier.new);

class AppThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    return ref.read(settingsStorageProvider).getThemeMode();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await ref.read(settingsStorageProvider).setThemeMode(mode);
    state = AsyncData(mode);
  }
}

ThemeMode themeModeFromPreference(AppThemePreference pref) => switch (pref) {
      AppThemePreference.light => ThemeMode.light,
      AppThemePreference.dark => ThemeMode.dark,
      AppThemePreference.system => ThemeMode.system,
    };

AppThemePreference preferenceFromThemeMode(ThemeMode mode) => switch (mode) {
      ThemeMode.light => AppThemePreference.light,
      ThemeMode.dark => AppThemePreference.dark,
      ThemeMode.system => AppThemePreference.system,
    };

class MimioTheme {
  static ThemeData get light => _build(Brightness.light, MimioPalette.light);

  static ThemeData get dark => _build(Brightness.dark, MimioPalette.dark);

  static ThemeData _build(Brightness brightness, MimioPalette palette) {
    final isDark = brightness == Brightness.dark;
    final primary = isDark ? const Color(0xFF52B5A3) : MimioColors.primary;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: [palette],
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        surface: palette.surface,
        primary: primary,
        secondary: MimioColors.accent,
        onSurface: palette.textPrimary,
      ),
      scaffoldBackgroundColor: palette.background,
      cardColor: palette.surface,
      dividerColor: palette.border,
      textTheme: GoogleFonts.nunitoTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ).apply(
        bodyColor: palette.textPrimary,
        displayColor: palette.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: palette.textPrimary,
        ),
        iconTheme: IconThemeData(color: palette.textPrimary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: palette.textSecondary,
        ),
        contentTextStyle: GoogleFonts.nunito(
          fontSize: 13,
          color: palette.textPrimary,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? palette.background : palette.surface,
        hintStyle: TextStyle(color: palette.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: palette.surface,
        iconColor: palette.textPrimary,
        textColor: palette.textPrimary,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(color: palette.textPrimary),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? palette.surface : palette.textPrimary,
        contentTextStyle: TextStyle(color: isDark ? palette.textPrimary : palette.surface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
