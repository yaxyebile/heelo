import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors — Orange + Blue
  static const Color primary   = Color(0xFFF97316); // Orange
  static const Color secondary = Color(0xFF2563EB); // Blue
  static const Color accent    = Color(0xFF2563EB); // Blue accent

  // Neutral Colors (Light)
  static const Color backgroundLight   = Color(0xFFF8FAFC);
  static const Color surfaceLight      = Colors.white;
  static const Color textPrimaryLight  = Color(0xFF1F2937);
  static const Color textSecondaryLight = Color(0xFF64748B);

  // Neutral Colors (Dark)
  static const Color backgroundDark  = Color(0xFF020617);
  static const Color surfaceDark     = Color(0xFF1F2937);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error   = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info    = Color(0xFF2563EB);

  // Brand Gradient (orange → blue)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
