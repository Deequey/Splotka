import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// kolory
const Color kBeige = Color(0xFFF8F1E4);
const Color kMint = Color(0xFFC8E3D4);
const Color kBrown = Color(0xFFB79B74);
const Color kPinkAccent = Color(0xFFF3C5B9);

final ThemeData crochetLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: kMint,
  scaffoldBackgroundColor: kBeige,
  colorScheme: ColorScheme.light (
    primary: kMint,
    secondary: kPinkAccent,
    surface: Colors.white,
    onPrimary: Colors.black87,
    onSurface: kBrown,
    background: kBeige,
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

//dark theme nizej

