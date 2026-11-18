import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../../data/models/exercise.dart';
import '../../data/models/workout_plan.dart';
import 'fitora_muscle_badge.dart';
import 'fitora_muscle_illustration.dart';

/// Highly visual exercise tile displaying both the movement photography
/// and the 3D anatomical silhouette with highlighted target muscles.
class FitoraExerciseVisualTile extends StatelessWidget {
  final PlanExercise? planExercise;
  final Exercise? exercise;
  final int? index;
  final VoidCallback? onTap;

  const FitoraExerciseVisualTile({
    super.key,
    this.planExercise,
    this.exercise,
    this.index,
    this.onTap,
  }) : assert(planExercise != null || exercise != null, 'Must provide planExercise or exercise');

  Exercise get _effectiveExercise {
    if (planExercise?.exercise != null) return planExercise!.exercise!;
    if (exercise != null) return exercise!;
    return Exercise(
      id: planExercise?.exerciseId ?? 'ex_custom',
      name: 'Custom Exercise',
      category: 'full_body',
      targetMuscle: 'Full Body',
      equipment: 'Barbell',
      instructions: 'Perform with strict form.',
      safetyGuidance: 'Maintain neutral spine.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final ex = _effectiveExercise;
    final primaryMuscle = ex.targetMuscle;
    final secondaryMuscles = ex.secondaryMuscles;
    final highlightColor = FitoraMuscleBadge.getMuscleColor(primaryMuscle);
    final isBack = FitoraMuscleIllustration.isBackMuscle(primaryMuscle);

    final targetSets = planExercise?.targetSets ?? ex.defaultSets;
    final targetReps = planExercise?.targetReps ?? ex.defaultReps;
    final restSeconds = planExercise?.restSeconds ?? ex.restSeconds;
    final weightKg = planExercise?.defaultWeightKg;

    return InkWell(
      onTap: onTap ??
          () {
            context.push('/exercise-detail', extra: ex);
          },
      borderRadius: AppSpacing.roundedMd,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppSpacing.roundedMd,
          border: Border.all(color: highlightColor.withValues(alpha: 0.25), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: highlightColor.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // DUAL VISUAL COMPONENT: Movement Photo + Neon Anatomical Silhouette
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 96,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A), // Dark slate
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: highlightColor.withValues(alpha: 0.45), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: highlightColor.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Row(
                      children: [
                        // Left half: Exercise Photo
                        Expanded(
                          flex: 1,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (ex.imageUrl.isNotEmpty)
                                CachedNetworkImage(
                                  imageUrl: ex.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: const Color(0xFF1E293B),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white54),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    color: const Color(0xFF1E293B),
                                    child: const Icon(Icons.fitness_center_rounded, color: Colors.white38, size: 20),
                                  ),
                                )
                              else
                                Container(
                                  color: const Color(0xFF1E293B),
                                  child: const Icon(Icons.fitness_center_rounded, color: Colors.white38, size: 20),
                                ),
                              // Gradient shadow separating photo and muscle map
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.transparent,
                                      const Color(0xFF0F172A).withValues(alpha: 0.7),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Right half: Realistic Neon Anatomical Silhouette
                        Expanded(
                          flex: 1,
                          child: Container(
                            color: const Color(0xFF090D16),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                FitoraMuscleIllustration(
                                  muscle: primaryMuscle,
                                  width: 44,
                                  height: 68,
                                  showContainer: false,
                                ),
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: highlightColor.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      isBack ? 'POST' : 'ANT',
                                      style: TextStyle(
                                        color: highlightColor,
                                        fontSize: 7,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Step # badge (e.g. 1, 2, 3)
                if (index != null)
                  Positioned(
                    top: -5,
                    left: -5,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '$index',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // EXERCISE INFO & TARGET DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ex.name,
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Target Muscles & Equipment Badges
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      FitoraMuscleBadge(muscle: primaryMuscle),
                      if (secondaryMuscles.isNotEmpty)
                        FitoraMuscleBadge(muscle: secondaryMuscles.first, isSecondary: true),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          ex.equipment.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Sets, Reps, and Rest
                  Row(
                    children: [
                      const Icon(Icons.repeat_rounded, size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '$targetSets sets × $targetReps reps',
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.timer_outlined, size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${restSeconds}s rest',
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // TARGET WEIGHT CHIP & CHEVRON
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (weightKg != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      weightKg > 0 ? '${weightKg.toStringAsFixed(weightKg.truncateToDouble() == weightKg ? 0 : 1)} kg' : 'Bodywt',
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textMuted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
