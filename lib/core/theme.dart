import 'package:flutter/material.dart';

class WarnaJosBook {
  static const Color navy = Color(0xFF062A6B);
  static const Color biru = Color(0xFF2F80ED);
  static const Color biruMuda = Color(0xFFEAF2FF);
  static const Color teks = Color(0xFF1F2A44);
  static const Color merah = Color(0xFFD64545);
}

ThemeData temaJosBook() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: WarnaJosBook.navy),
    scaffoldBackgroundColor: Colors.white,
  );
}