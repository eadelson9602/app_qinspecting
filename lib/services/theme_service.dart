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
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.1),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
      bodySmall: TextStyle(color: Colors.grey[600]),
      labelLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w400),
    ),
    iconTheme: IconThemeData(color: Colors.black87),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.green, width: 2),
      ),
      labelStyle: TextStyle(color: Colors.grey[600]),
      hintStyle: TextStyle(color: Colors.grey[500]),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey[600],
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    dividerColor: Colors.grey[300],
    shadowColor: Colors.black.withValues(alpha: 0.1),
  );
  
  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.green,
    primaryColor: const Color(0xFF39FF14), // Verde brillante como en la imagen
    scaffoldBackgroundColor: const Color(0xFF121212), // Gris muy oscuro casi negro
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF121212),
      foregroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.3),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E), // Gris ligeramente más claro que el fondo
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: const Color(0xFFA0A0A0)), // Gris claro para texto secundario
      labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(color: const Color(0xFFA0A0A0), fontWeight: FontWeight.w400),
    ),
    iconTheme: IconThemeData(color: Colors.white),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF39FF14), // Verde brillante
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E1E1E), // Mismo color que las cards
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: const Color(0xFF404040)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: const Color(0xFF404040)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: const Color(0xFF39FF14), width: 2),
      ),
      labelStyle: TextStyle(color: const Color(0xFFA0A0A0)),
      hintStyle: TextStyle(color: const Color(0xFF808080)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF121212), // Mismo color que el fondo principal
      selectedItemColor: Colors.white, // Blanco para elementos activos
      unselectedItemColor: const Color(0xFFA0A0A0), // Gris claro para elementos inactivos
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    dividerColor: const Color(0xFF404040),
    shadowColor: Colors.black.withValues(alpha: 0.3),
  );
  
  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;
}
