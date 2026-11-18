import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand palette
  static const Color primary = Color(0xFF2563EB); // Royal Blue
  static const Color primaryDark = Color(0xFF1747B8);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color primaryTint = Color(0xFFDBEAFE);

  // Background and Surfaces
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F3F5);

  // Typography / Neutral colors
  static const Color textPrimary = Color(0xFF101828);
  static const Color textSecondary = Color(0xFF667085);
  static const Color textMuted = Color(0xFF98A2B3);
  static const Color textLight = Color(0xFFD0D5DD);

  // Borders & Dividers
  static const Color border = Color(0xFFEAECF0);
  static const Color borderDark = Color(0xFFD0D5DD);
  static const Color divider = Color(0xFFF2F4F7);

  // Semantic Feedback
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF0284C7);
  static const Color infoLight = Color(0xFFE0F2FE);

  // Fitness & Health Metric Accents
  static const Color calorieAccent = Color(0xFFFA5A3C);
  static const Color proteinAccent = Color(0xFF2563EB);
  static const Color carbAccent = Color(0xFFF59E0B);
  static const Color fatAccent = Color(0xFF10B981);
  static const Color waterAccent = Color(0xFF0EA5E9);
  static const Color stepsAccent = Color(0xFF8B5CF6);
  static const Color workoutAccent = Color(0xFFEC4899);
  static const Color sleepAccent = Color(0xFF6366F1);

  // Shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF101828).withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: const Color(0xFF101828).withValues(alpha: 0.02),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.24),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ];
}
