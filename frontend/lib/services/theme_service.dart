import 'package:flutter/material.dart';

// Simple theme service without Provider for now
class ThemeService {
  static const bool _isDarkMode = true; // Default to dark mode
  
  static bool get isDarkMode => _isDarkMode;
  static ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  
  // Dark theme colors (current theme)
  static final ThemeData darkTheme = ThemeData(
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
  static final ThemeData lightTheme = ThemeData(
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
  
  static ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;
  
  // Get background color based on current theme
  static Color get backgroundColor => _isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA);
  
  // Get surface color based on current theme
  static Color get surfaceColor => _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
  
  // Get text color based on current theme
  static Color get textColor => _isDarkMode ? Colors.white : const Color(0xFF1A1A1A);
  
  // Get secondary text color based on current theme
  static Color get secondaryTextColor => _isDarkMode ? Colors.white.withOpacity(0.7) : const Color(0xFF666666);
} 