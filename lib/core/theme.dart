import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Nowoczesna, przejrzysta paleta kolorów ---

// Kolory przewodnie
const Color kPrimaryColor = Color(0xFF2563EB); // Vivid Blue
const Color kAccentColor = Color(0xFFF43F5E);  // Rose

// Tryb Jasny (Light Mode)
const Color kLightBg = Color(0xFFF8FAFC);
const Color kLightSurface = Colors.white;
const Color kLightText = Color(0xFF0F172A);
const Color kLightTextSecondary = Color(0xFF475569);

// Tryb Ciemny (Dark Mode)
const Color kDarkBg = Color(0xFF0F172A);      // Slate 900
const Color kDarkSurface = Color(0xFF1E293B); // Slate 800
const Color kDarkText = Color(0xFFF8FAFC);
const Color kDarkTextSecondary = Color(0xFF94A3B8);
const Color kDarkPrimary = Color(0xFF60A5FA); // Lighter blue for better contrast

// Mapowanie starych nazw dla zachowania kompatybilności (opcjonalnie można potem zrefaktoryzować)
const Color kBeige = kLightBg;
const Color kMint = kPrimaryColor;
const Color kBrown = kLightText;
const Color kPinkAccent = kAccentColor;

const Color kDarkBlue = kDarkBg;
const Color kDarkMint = kDarkPrimary;
const Color kLightBrown = kDarkText;


// --- Provider do zarządzania motywem ---
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  static const _themePrefKey = 'isDarkMode';

  ThemeNotifier() : super(false) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_themePrefKey) ?? false;
  }

  Future<void> toggleTheme() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themePrefKey, state);
  }
}

// --- Provider do zarządzania wibracjami ---
final hapticNotifierProvider = StateNotifierProvider<HapticNotifier, bool>((ref) {
  return HapticNotifier();
});

class HapticNotifier extends StateNotifier<bool> {
  static const _hapticPrefKey = 'isHapticEnabled';

  HapticNotifier() : super(true) {
    _loadHaptic();
  }

  Future<void> _loadHaptic() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_hapticPrefKey) ?? true;
  }

  Future<void> toggleHaptic() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticPrefKey, state);
  }
}

// --- Motyw Jasny ---
final ThemeData crochetLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: kPrimaryColor,
  scaffoldBackgroundColor: kLightBg,
  colorScheme: const ColorScheme.light(
    primary: kPrimaryColor,
    secondary: kAccentColor,
    surface: kLightSurface,
    onPrimary: Colors.white,
    onSurface: kLightText,
    background: kLightBg,
    onBackground: kLightText,
    surfaceVariant: Color(0xFFE2E8F0),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: kLightBg,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: kLightText),
    titleTextStyle: TextStyle(
      color: kLightText,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: GoogleFonts.interTextTheme(
    const TextTheme(
      bodyLarge: TextStyle(color: kLightText),
      bodyMedium: TextStyle(color: kLightTextSecondary),
      titleLarge: TextStyle(color: kLightText, fontWeight: FontWeight.bold),
    ),
  ),
  cardTheme: CardThemeData(
    color: kLightSurface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
      side: BorderSide(color: Colors.grey.withAlpha(40), width: 1),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kPrimaryColor,
    foregroundColor: Colors.white,
  ),
);

// --- Motyw Ciemny ---
final ThemeData crochetDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: kDarkPrimary,
  scaffoldBackgroundColor: kDarkBg,
  colorScheme: const ColorScheme.dark(
    primary: kDarkPrimary,
    secondary: kAccentColor,
    surface: kDarkSurface,
    onPrimary: kDarkBg,
    onSurface: kDarkText,
    background: kDarkBg,
    onBackground: kDarkText,
    surfaceVariant: Color(0xFF334155),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: kDarkBg,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: kDarkText),
    titleTextStyle: TextStyle(
      color: kDarkText,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: GoogleFonts.interTextTheme(
    const TextTheme(
      bodyLarge: TextStyle(color: kDarkText),
      bodyMedium: TextStyle(color: kDarkTextSecondary),
      titleLarge: TextStyle(color: kDarkText, fontWeight: FontWeight.bold),
    ),
  ),
  cardTheme: CardThemeData(
    color: kDarkSurface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
      side: BorderSide(color: Colors.white.withAlpha(20), width: 1),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kDarkPrimary,
    foregroundColor: kDarkBg,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: kDarkSurface,
    selectedItemColor: kDarkPrimary,
    unselectedItemColor: kDarkTextSecondary,
  ),
);
