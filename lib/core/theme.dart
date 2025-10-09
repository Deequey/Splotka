import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Kolory ---
const Color kBeige = Color(0xFFF8F1E4);
const Color kMint = Color(0xFFC8E3D4);
const Color kBrown = Color(0xFFB79B74);
const Color kPinkAccent = Color(0xFFF3C5B9);

// Ciemniejsze odpowiedniki
const Color kDarkBlue = Color(0xFF1A2E35);
const Color kDarkMint = Color(0xFF3A5F5F);
const Color kLightBrown = Color(0xFFE0CDB4);


// --- Provider do zarządzania motywem ---
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  // `true` oznacza motyw ciemny
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false); // Domyślnie motyw jasny

  void toggleTheme() {
    state = !state;
  }
}

// --- Motyw Jasny ---
final ThemeData crochetLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: kMint,
  scaffoldBackgroundColor: kBeige,
  colorScheme: const ColorScheme.light(
    primary: kMint,
    secondary: kPinkAccent,
    surface: Colors.white,
    onPrimary: Colors.black87,
    onSurface: kBrown,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: kBeige,
    elevation: 0,
    iconTheme: IconThemeData(color: kBrown),
    titleTextStyle: TextStyle(
      color: kBrown,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: GoogleFonts.nunitoTextTheme(
    const TextTheme(
      bodyLarge: TextStyle(color: kBrown),
      bodyMedium: TextStyle(color: kBrown),
      titleLarge: TextStyle(color: kBrown, fontWeight: FontWeight.bold),
    ),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kPinkAccent,
    foregroundColor: Colors.white,
  ),
);

// --- Motyw Ciemny ---
final ThemeData crochetDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: kDarkMint,
  scaffoldBackgroundColor: kDarkBlue,
  colorScheme: const ColorScheme.dark(
    primary: kDarkMint,
    secondary: kPinkAccent,
    surface: Color(0xFF2C3E43),
    onPrimary: Colors.white,
    onSurface: kLightBrown,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: kDarkBlue,
    elevation: 0,
    iconTheme: IconThemeData(color: kLightBrown),
    titleTextStyle: TextStyle(
      color: kLightBrown,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: GoogleFonts.nunitoTextTheme(
    const TextTheme(
      bodyLarge: TextStyle(color: kLightBrown),
      bodyMedium: TextStyle(color: kLightBrown),
      titleLarge: TextStyle(color: kLightBrown, fontWeight: FontWeight.bold),
    ),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF2C3E43),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kPinkAccent,
    foregroundColor: kDarkBlue,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF2C3E43),
    selectedItemColor: kPinkAccent,
    unselectedItemColor: kLightBrown,
  ),
);
