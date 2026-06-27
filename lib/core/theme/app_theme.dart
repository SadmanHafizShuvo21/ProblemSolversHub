import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeNotifier extends ChangeNotifier {
  Color primary;
  Color secondary;
  Color background;
  Color surface;
  Color textPrimary;
  Color textSecondary;

  ThemeNotifier({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
  })  : primary = primary ?? const Color(0xFF4F46E5),
        secondary = secondary ?? const Color(0xFF06B6D4),
        background = background ?? const Color(0xFFF8FAFC),
        surface = surface ?? Colors.white,
        textPrimary = textPrimary ?? const Color(0xFF0F172A),
        textSecondary = textSecondary ?? const Color(0xFF64748B);

  Brightness get brightness => ThemeData.estimateBrightnessForColor(background);

  ColorScheme get colorScheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      background: background,
      surface: surface,
      secondary: secondary,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: textPrimary,
      onSurface: textPrimary,
      onError: Colors.white,
    );

    return scheme.copyWith(
      onSurfaceVariant: textSecondary,
      surfaceVariant: surface.withOpacity(0.96),
      outline: textSecondary.withOpacity(0.65),
    );
  }

  ThemeData get currentTheme {
    final colors = colorScheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: surface,
        foregroundColor: colors.onSurface,
        titleTextStyle: TextStyle(
          color: colors.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: colors.onSurface),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.secondaryContainer,
        selectedColor: primary.withOpacity(0.18),
        labelStyle: TextStyle(color: colors.onSurface),
        secondaryLabelStyle: TextStyle(color: colors.onPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.onSurfaceVariant,
        backgroundColor: surface,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: TextStyle(color: colors.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.outline.withOpacity(0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primary),
        ),
      ),
    );
  }

  void updatePrimary(Color c) {
    primary = c;
    notifyListeners();
  }

  void updateSecondary(Color c) {
    secondary = c;
    notifyListeners();
  }

  void updateBackground(Color c) {
    background = c;
    notifyListeners();
  }

  void updateSurface(Color c) {
    surface = c;
    notifyListeners();
  }

  void updateTextPrimary(Color c) {
    textPrimary = c;
    notifyListeners();
  }

  void updateTextSecondary(Color c) {
    textSecondary = c;
    notifyListeners();
  }

  void updateFromMap(Map<String, Color> map) {
    if (map.containsKey('primary')) primary = map['primary']!;
    if (map.containsKey('secondary')) secondary = map['secondary']!;
    if (map.containsKey('background')) background = map['background']!;
    if (map.containsKey('surface')) surface = map['surface']!;
    if (map.containsKey('textPrimary')) textPrimary = map['textPrimary']!;
    if (map.containsKey('textSecondary')) textSecondary = map['textSecondary']!;
    notifyListeners();
  }
}

final themeNotifierProvider = ChangeNotifierProvider<ThemeNotifier>((ref) => ThemeNotifier());
