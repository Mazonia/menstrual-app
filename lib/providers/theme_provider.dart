import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  // Light theme
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.pink,
      brightness: Brightness.light,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.pink.shade100,
      foregroundColor: Colors.pink.shade900,
    ),
    cardTheme: CardTheme(color: Colors.pink.shade50, elevation: 2),
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        color: Colors.pink.shade900,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: Colors.pink.shade900),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
    ),
  );

  // Dark theme
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.pink,
      brightness: Brightness.dark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade900,
      foregroundColor: Colors.pink.shade200,
    ),
    cardTheme: CardTheme(color: Colors.grey.shade800, elevation: 2),
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        color: Colors.pink.shade200,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: Colors.pink.shade100),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pink.shade700,
        foregroundColor: Colors.white,
      ),
    ),
  );
}
