import 'package:flutter/material.dart';

class AppTheme {
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFF8F9FA),
    scaffoldBackgroundColor: const Color(0xFF0C1015),
    cardColor: const Color(0xFF0C1015),
    hintColor: const Color(0xFFA9B1C6),
    dividerColor: const Color(0xFF2D3748),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFF8F9FA),
      secondary: Color(0xFF2D3748),
      surface: Color(0xFF0C1015),
      background: Color(0xFF0C1015),
      error: Color(0xFF9B2C2C),
      onPrimary: Color(0xFF1A202C),
      onSecondary: Color(0xFFF8F9FA),
      onSurface: Color(0xFFF8F9FA),
      onBackground: Color(0xFFF8F9FA),
      onError: Color(0xFFF8F9FA),
    ),
  );
}
