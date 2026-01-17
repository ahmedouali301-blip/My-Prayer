import 'package:flutter/material.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(String mode) {
    switch (mode) {
      case 'Clair':
        _themeMode = ThemeMode.light;
        break;
      case 'Sombre':
        _themeMode = ThemeMode.dark;
        break;
      case 'Système':
      default:
        _themeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }

  String getCurrentThemeString() {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Clair';
      case ThemeMode.dark:
        return 'Sombre';
      case ThemeMode.system:
      default:
        return 'Système';
    }
  }

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF1B4965),
      scaffoldBackgroundColor: const Color(0xFFE0E0E0),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1B4965),
        secondary: Color(0xFFFFA726),
        surface: Colors.white,
        background: Color(0xFFE0E0E0),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1B4965),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF1B4965),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B4965),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF1B4965),
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF1B4965),
        secondary: Color(0xFFFFA726),
        surface: Color(0xFF1E1E1E),
        background: Color(0xFF121212),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1B4965),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF1E1E1E),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF1B4965),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B4965),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}