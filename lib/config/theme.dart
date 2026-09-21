import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class ForceTheme {
  static const orange = Color(0xFFFF6B00);
  static const navy = Color(0xFF0F172A);
  static const green = Color(0xFF00D084);
  static ThemeData light = ThemeData(
    primaryColor: orange,
    scaffoldBackgroundColor: Color(0xFFF8FAFC),
    textTheme: GoogleFonts.poppinsTextTheme(),
    appBarTheme: AppBarTheme(backgroundColor: navy, foregroundColor: Colors.white, elevation: 0, centerTitle: true),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: orange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24))),
    inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIconColor: orange),
  );
}