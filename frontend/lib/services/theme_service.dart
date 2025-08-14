import 'package:flutter/material.dart';

// Theme service that can be used with Provider
class ThemeService extends ChangeNotifier {
  bool _isDarkMode = true; // Default to dark mode
  
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  
  // Method to toggle theme
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
  
  // Dark theme colors (current theme)
  static final ThemeData _darkThemeData = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: const Color(0xFF0A0A0A),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0A0A0A),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: Colors.white),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    dividerTheme: const DividerThemeData(color: Colors.white24),
    colorScheme: const ColorScheme.dark(
      primary: Colors.blue,
      secondary: Colors.purple,
      surface: Color(0xFF1A1A1A),
      background: Color(0xFF0A0A0A),
    ),
  );
  
  // Light theme colors
  static final ThemeData _lightThemeData = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF8F9FA),
      foregroundColor: Color(0xFF1A1A1A),
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF1A1A1A)),
      bodyMedium: TextStyle(color: Color(0xFF1A1A1A)),
      titleLarge: TextStyle(color: Color(0xFF1A1A1A)),
      titleMedium: TextStyle(color: Color(0xFF1A1A1A)),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
    dividerTheme: const DividerThemeData(color: Color(0xFFE0E0E0)),
    colorScheme: const ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.purple,
      surface: Colors.white,
      background: Color(0xFFF8F9FA),
    ),
  );
  
  ThemeData get currentTheme => _isDarkMode ? _darkThemeData : _lightThemeData;
  
  // Get background color based on current theme
  Color get backgroundColor => _isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA);
  
  // Get surface color based on current theme
  Color get surfaceColor => _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
  
  // Get card color based on current theme
  Color get cardColor => _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
  
  // Get text color based on current theme
  Color get textColor => _isDarkMode ? Colors.white : const Color(0xFF1A1A1A);
  
  // Get secondary text color based on current theme
  Color get secondaryTextColor => _isDarkMode ? Colors.white.withOpacity(0.7) : const Color(0xFF666666);
  
  // Get dark theme data
  ThemeData get darkTheme => _darkThemeData;
  
  // Get light theme data
  ThemeData get lightTheme => _lightThemeData;
} 