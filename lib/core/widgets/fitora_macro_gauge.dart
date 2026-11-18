import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

class FitoraMacroGauge extends StatelessWidget {
  final int caloriesConsumed;
  final int calorieTarget;
  final int proteinConsumed;
  final int proteinTarget;
  final int carbsConsumed;
  final int carbsTarget;
  final int fatConsumed;
  final int fatTarget;

  const FitoraMacroGauge({
    super.key,
    required this.caloriesConsumed,
    required this.calorieTarget,
    required this.proteinConsumed,
    required this.proteinTarget,
    required this.carbsConsumed,
    required this.carbsTarget,
    required this.fatConsumed,
    required this.fatTarget,
  });

  @override
  Widget build(BuildContext context) {
    final remainingCalories = (calorieTarget - caloriesConsumed).clamp(0, 10000);
    final calorieRatio = calorieTarget > 0 ? (caloriesConsumed / calorieTarget).clamp(0.0, 1.0) : 0.0;

    // Macro percentage of total macro grams
    final totalGrams = (proteinConsumed + carbsConsumed + fatConsumed).clamp(1, 10000);
    final proteinPct = (proteinConsumed / totalGrams * 100).round();
    final carbsPct = (carbsConsumed / totalGrams * 100).round();
    final fatPct = (fatConsumed / totalGrams * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Calorie Progress Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$caloriesConsumed',
                      style: AppTypography.headingLarge.copyWith(fontWeight: FontWeight.w800, fontSize: 26),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '/ $calorieTarget kcal',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Text(
                  remainingCalories > 0 ? '$remainingCalories kcal remaining today' : 'Daily caloric target reached!',
                  style: AppTypography.bodySmall.copyWith(
                    color: remainingCalories > 0 ? AppColors.textSecondary : AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.calorieAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${(calorieRatio * 100).round()}% Met',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.calorieAccent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Visual Proportion Bar (The "Macro Plate")
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 10,
                width: double.infinity,
                child: Row(
                  children: [
                    if (proteinConsumed > 0)
                      Expanded(
                        flex: proteinConsumed,
                        child: Container(color: AppColors.proteinAccent),
                      ),
                    if (carbsConsumed > 0)
                      Expanded(
                        flex: carbsConsumed,
                        child: Container(color: AppColors.carbAccent),
                      ),
                    if (fatConsumed > 0)
                      Expanded(
                        flex: fatConsumed,
                        child: Container(color: AppColors.fatAccent),
                      ),
                    if (proteinConsumed == 0 && carbsConsumed == 0 && fatConsumed == 0)
                      Expanded(
                        child: Container(color: AppColors.border),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMacroRatioTag('Protein $proteinPct%', AppColors.proteinAccent),
                _buildMacroRatioTag('Carbs $carbsPct%', AppColors.carbAccent),
                _buildMacroRatioTag('Fat $fatPct%', AppColors.fatAccent),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // 3 Visual Macro Columns
        Row(
          children: [
            Expanded(
              child: _buildMacroCard(
                label: 'Protein',
                icon: Icons.egg_alt_rounded,
                consumed: proteinConsumed,
                target: proteinTarget,
                color: AppColors.proteinAccent,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMacroCard(
                label: 'Carbs',
                icon: Icons.grain_rounded,
                consumed: carbsConsumed,
                target: carbsTarget,
                color: AppColors.carbAccent,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMacroCard(
                label: 'Fats',
                icon: Icons.eco_rounded,
                consumed: fatConsumed,
                target: fatTarget,
                color: AppColors.fatAccent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroRatioTag(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildMacroCard({
    required String label,
    required IconData icon,
    required int consumed,
    required int target,
    required Color color,
  }) {
    final ratio = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold, color: color),
              ),
              Icon(icon, size: 14, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${consumed}g',
                style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(width: 2),
              Text(
                '/$target',
                style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 4,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
