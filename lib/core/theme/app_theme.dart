import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand Palette (Vibrant Blue #0284C7 primary + Pastel #D2F7FF fills + White)
  static const primary     = Color(0xFF0284C7); // Rich Sky Blue
  static const primaryDark = Color(0xFF0369A1); // Deep Accent
  static const secondary   = Color(0xFF0EA5E9); // Bright Accent
  static const green       = Color(0xFF0284C7);
  static const darkBlue    = Color(0xFF0F172A);
  static const white       = Color(0xFFFFFFFF);
  static const lightGray   = Color(0xFFF0F9FF); // Soft Tinted Background
  static const lightPastel = Color(0xFFD2F7FF); // Soft Pastel Blue Fill
  static const textDark    = Color(0xFF0F172A);
  static const textGray    = Color(0xFF64748B);

  // Gradient (#0284C7 → #0EA5E9)
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF0284C7), Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static const _primary   = AppColors.primary;   // orange
  static const _secondary = AppColors.secondary; // blue
  static const _bg        = AppColors.lightGray;

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      splashColor: _primary.withOpacity(0.08),
      highlightColor: Colors.transparent,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primary,
        primary: _primary,
        secondary: _secondary,
        background: _bg,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.white,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS:     CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS:   FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: GoogleFonts.outfit(
          color: AppColors.darkBlue,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkBlue),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 56),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16),
        ).copyWith(
          elevation: WidgetStateProperty.all(0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightGray,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.textGray, fontWeight: FontWeight.w500),
      ),
      chipTheme: ChipThemeData(
        selectedColor: _primary.withOpacity(0.12),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.lightGray, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: AppColors.darkBlue,
        contentTextStyle: GoogleFonts.outfit(
          color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  static ThemeData get lightTheme => light;
  static ThemeData get darkTheme  => light;
}
