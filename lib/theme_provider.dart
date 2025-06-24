import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = (_themeMode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Color(0xFFD0A67D), // Warna utama
      scaffoldBackgroundColor: Colors.white, // Latar belakang halaman
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF6D4C41), // Warna teks di app bar
      ),
      iconTheme: IconThemeData(color: Color(0xFF6D4C41)), // Warna icon
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.black), // Digunakan untuk teks body di light mode
        bodyMedium: TextStyle(color: Colors.black),
        bodySmall: TextStyle(color: Colors.black),
      ),
      buttonTheme: ButtonThemeData(buttonColor: Color(0xFFD0A67D)), // Warna tombol utama
      colorScheme: ColorScheme.light(
        primary: Color(0xFFD0A67D), // Warna utama
        secondary: Color(0xFF6D4C41), // Warna sekunder
        onPrimary: Colors.white, // Warna teks pada primary
        onSecondary: Colors.white, // Warna teks pada secondary
      ),
    );
  }

  // Theme dark mode
  ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Color(0xFFD0A67D), // Warna utama
      scaffoldBackgroundColor: Colors.black, // Latar belakang halaman
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white, // Teks putih di app bar
      ),
      iconTheme: IconThemeData(color: Colors.white), // Icon putih di dark mode
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.white), // Digunakan untuk teks body di dark mode
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white),
      ),
      buttonTheme: ButtonThemeData(buttonColor: Color(0xFFD0A67D)), // Warna tombol utama
      colorScheme: ColorScheme.dark(
        primary: Color(0xFFD0A67D), // Warna utama
        secondary: Color(0xFF6D4C41), // Warna sekunder
        onPrimary: Colors.white, // Warna teks pada primary
        onSecondary: Colors.white, // Warna teks pada secondary
      ),
    );
  }
}
