import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors — Vibrant Blue (#0284C7) for text/icons + Soft Pastel Cyan (#D2F7FF / #C4F4FF) for backgrounds & fills
  static const Color primary      = Color(0xFF0284C7); // Vibrant Sky Blue (visible text, icons, buttons)
  static const Color primaryDark  = Color(0xFF0369A1); // Deep Cyan Blue
  static const Color secondary    = Color(0xFF0EA5E9); // Bright Blue Accent
  static const Color accent       = Color(0xFFC4F4FF); // Light Cyan Accent
  static const Color lightPastel  = Color(0xFFD2F7FF); // Soft Blue Fill

  // Neutral Colors (Light)
  static const Color backgroundLight   = Color(0xFFF0F9FF); // Soft Light Blue Tinted Background
  static const Color surfaceLight      = Color(0xFFFFFFFF); // Pure White Surface
  static const Color textPrimaryLight  = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);

  // Neutral Colors (Dark)
  static const Color backgroundDark  = Color(0xFF0A192F);
  static const Color surfaceDark     = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error   = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info    = Color(0xFF0284C7);

  // Brand Gradient (#0284C7 → #0EA5E9)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0284C7), Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
