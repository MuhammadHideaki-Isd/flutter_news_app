// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class InforminTokens {
  static const navy = Color(0xff163a5f);
  static const space8 = 8.0;
  static const space16 = 16.0;
  static const space20 = 20.0;
  static const radius = 9.0; 
}

ThemeData informinTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final background = dark ? const Color(0xff171a1f) : const Color(0xfffbfaf8);
  final scheme = ColorScheme.fromSeed(
    seedColor: InforminTokens.navy,
    brightness: brightness,
    surface: background,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    textTheme: GoogleFonts.interTextTheme(
      ThemeData(brightness: brightness).textTheme,
    ),
    dividerColor: dark ? const Color(0xff30353d) : const Color(0xffe3e2de),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: background,
      indicatorColor: scheme.primary.withOpacity(.12),
    ),
  );
}
