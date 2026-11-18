import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

class FitoraBmiGauge extends StatelessWidget {
  final double bmi;

  const FitoraBmiGauge({
    super.key,
    required this.bmi,
  });

  String get _categoryTitle {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Healthy Weight';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese Class';
  }

  Color get _categoryColor {
    if (bmi < 18.5) return const Color(0xFF3B82F6); // Blue
    if (bmi < 25.0) return const Color(0xFF10B981); // Emerald
    if (bmi < 30.0) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFFEF4444); // Red
  }

  String get _categoryDescription {
    if (bmi < 18.5) {
      return 'Below typical range. Focus on nutrient-dense meals and progressive resistance training.';
    }
    if (bmi < 25.0) {
      return 'Optimal range for longevity, metabolic health, and balanced body composition.';
    }
    if (bmi < 30.0) {
      return 'Slightly elevated. A modest caloric deficit with consistent activity is recommended.';
    }
    return 'Above recommended range. Structured resistance and cardiovascular exercise can help restore balance.';
  }

  @override
  Widget build(BuildContext context) {
    // Map BMI range [15.0 to 35.0] to ratio [0.0 to 1.0]
    final normalized = ((bmi - 15.0) / (35.0 - 15.0)).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _categoryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('Body Mass Index (BMI)', style: AppTypography.labelLarge),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _categoryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${bmi.toStringAsFixed(1)} • $_categoryTitle',
                  style: AppTypography.labelSmall.copyWith(
                    color: _categoryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Visual Spectrum Bar with Arrow Indicator
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final pointerX = (normalized * width).clamp(8.0, width - 8.0);

              return Column(
                children: [
                  // Pointer Arrow
                  SizedBox(
                    height: 14,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: pointerX - 7,
                          top: 0,
                          child: Icon(
                            Icons.arrow_drop_down_rounded,
                            size: 20,
                            color: _categoryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Multi-zone color bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 12,
                      width: double.infinity,
                      child: Row(
                        children: [
                          // Underweight (<18.5) -> 17.5% of 15-35 range
                          Expanded(flex: 18, child: Container(color: const Color(0xFF3B82F6))),
                          const SizedBox(width: 2),
                          // Normal (18.5 - 25.0) -> 32.5% of range
                          Expanded(flex: 33, child: Container(color: const Color(0xFF10B981))),
                          const SizedBox(width: 2),
                          // Overweight (25.0 - 30.0) -> 25% of range
                          Expanded(flex: 25, child: Container(color: const Color(0xFFF59E0B))),
                          const SizedBox(width: 2),
                          // Obese (30.0 - 35.0+) -> 24% of range
                          Expanded(flex: 24, child: Container(color: const Color(0xFFEF4444))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Zone labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('< 18.5\nUnder', style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.textMuted), textAlign: TextAlign.center),
                      Text('18.5 - 24.9\nHealthy', style: AppTypography.labelSmall.copyWith(fontSize: 10, color: const Color(0xFF10B981), fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      Text('25.0 - 29.9\nOver', style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.textMuted), textAlign: TextAlign.center),
                      Text('30.0+\nObese', style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.textMuted), textAlign: TextAlign.center),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Clinical context note
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: AppSpacing.roundedSm,
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _categoryDescription,
                    style: AppTypography.bodySmall.copyWith(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
