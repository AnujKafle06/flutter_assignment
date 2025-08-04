// provider/theme_provider.dart - Fixed version
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String THEME_KEY = 'preferred_theme';
  ThemeMode _currentTheme = ThemeMode.system; // Default to system
  bool _isInitialized = false;

  ThemeMode get currentTheme => _currentTheme;
  bool get isDarkMode => _currentTheme == ThemeMode.dark;
  bool get isInitialized => _isInitialized;

  ThemeProvider() {
    _initializeAsync();
  }

  // ✅ Better async initialization with error handling
  void _initializeAsync() async {
    try {
      await _loadThemeFromPrefs();
    } catch (e) {
      // If SharedPreferences fails, use system default
      debugPrint('ThemeProvider initialization error: $e');
      _currentTheme = ThemeMode.system;
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(THEME_KEY);

      if (savedTheme != null) {
        _currentTheme = switch (savedTheme) {
          'light' => ThemeMode.light,
          'dark' => ThemeMode.dark,
          'system' => ThemeMode.system,
          _ => ThemeMode.system,
        };
      }
    } catch (e) {
      debugPrint('Failed to load theme from preferences: $e');
      _currentTheme = ThemeMode.system;
    }
  }

  Future<void> _saveTheme(String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(THEME_KEY, value);
    } catch (e) {
      debugPrint('Failed to save theme to preferences: $e');
      // Continue anyway - the theme change will work for this session
    }
  }

  Future<void> setLightTheme() async {
    _currentTheme = ThemeMode.light;
    notifyListeners();
    await _saveTheme('light');
  }

  Future<void> setDarkTheme() async {
    _currentTheme = ThemeMode.dark;
    notifyListeners();
    await _saveTheme('dark');
  }

  Future<void> setSystemTheme() async {
    _currentTheme = ThemeMode.system;
    notifyListeners();
    await _saveTheme('system');
  }

  void toggleTheme() {
    final newTheme = _currentTheme == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    _currentTheme = newTheme;
    notifyListeners();

    // Save asynchronously without blocking UI
    _saveTheme(newTheme == ThemeMode.dark ? 'dark' : 'light');
  }

  // ✅ Method to force reinitialize if needed
  Future<void> reinitialize() async {
    _isInitialized = false;
    notifyListeners();
    _initializeAsync();
  }
}
