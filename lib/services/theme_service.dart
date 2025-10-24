import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  
  ThemeService() {
    _loadTheme();
  }
  
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themeKey) ?? false;
      notifyListeners();
    } catch (e) {
      print('Error loading theme: $e');
    }
  }
  
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
      print('Theme saved: ${_isDarkMode ? 'Dark' : 'Light'}');
    } catch (e) {
      print('Error saving theme: $e');
    }
  }
  
  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      notifyListeners();
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_themeKey, _isDarkMode);
        print('Theme set to: ${_isDarkMode ? 'Dark' : 'Light'}');
      } catch (e) {
        print('Error setting theme: $e');
      }
    }
  }
  
  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.green,
    primaryColor: Colors.green,
    scaffoldBackgroundColor: Colors.grey[100],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(color: Colors.black87),
      headlineMedium: TextStyle(color: Colors.black87),
      headlineSmall: TextStyle(color: Colors.black87),
      titleLarge: TextStyle(color: Colors.black87),
      titleMedium: TextStyle(color: Colors.black87),
      titleSmall: TextStyle(color: Colors.black87),
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
      bodySmall: TextStyle(color: Colors.grey[600]),
      labelLarge: TextStyle(color: Colors.black87),
      labelMedium: TextStyle(color: Colors.black87),
      labelSmall: TextStyle(color: Colors.grey[600]),
    ),
    iconTheme: IconThemeData(color: Colors.black87),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
      ),
    ),
  );
  
  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.green,
    primaryColor: Colors.green,
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[800],
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.grey[800],
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.3),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(color: Colors.white),
      headlineMedium: TextStyle(color: Colors.white),
      headlineSmall: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: Colors.white),
      titleSmall: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.grey[300]),
      labelLarge: TextStyle(color: Colors.white),
      labelMedium: TextStyle(color: Colors.white),
      labelSmall: TextStyle(color: Colors.grey[300]),
    ),
    iconTheme: IconThemeData(color: Colors.white),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
      ),
    ),
  );
  
  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;
}
