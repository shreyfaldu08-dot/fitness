import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../../data/models/exercise.dart';
import '../../data/models/workout_plan.dart';
import 'fitora_muscle_badge.dart';

/// Clean minimalist Apple Fitness-inspired exercise tile.
/// Features a compact 3D animated movement preview, target muscle badge,
/// and clear sets/reps/weight metrics.
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
    final highlightColor = FitoraMuscleBadge.getMuscleColor(primaryMuscle);

    final targetSets = planExercise?.targetSets ?? ex.defaultSets;
    final targetReps = planExercise?.targetReps ?? ex.defaultReps;
    final restSeconds = planExercise?.restSeconds ?? ex.restSeconds;
    final weightKg = planExercise?.defaultWeightKg;

    return InkWell(
      onTap: onTap ??
          () {
            context.push('/exercise-detail', extra: ex);
          },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // STEP NUMBER (if provided)
            if (index != null) ...[
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$index',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],

            // 3D ANIMATED MOTION THUMBNAIL
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 68,
                height: 68,
                color: const Color(0xFFF8FAFC),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      ex.localAssetGif,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                      errorBuilder: (_, __, ___) {
                        if (ex.gifUrl.isNotEmpty) {
                          return Image.network(
                            ex.gifUrl,
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                            errorBuilder: (_, __, ___) => _buildFallbackPhoto(ex),
                          );
                        }
                        return _buildFallbackPhoto(ex);
                      },
                    ),
                    // Small "3D" pill in bottom right of thumbnail
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '3D',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 7.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),

            // MIDDLE INFO: Name, Target Muscle Chip, Sets/Reps
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ex.name,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Minimal Target Muscle Chip
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: highlightColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: highlightColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                primaryMuscle,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: highlightColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Sets, Reps & Load Details
                  Row(
                    children: [
                      Text(
                        '$targetSets sets × $targetReps reps',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (weightKg != null && weightKg > 0) ...[
                        const Text(' • ', style: TextStyle(color: Color(0xFF94A3B8))),
                        Text(
                          '${weightKg.toStringAsFixed(weightKg.truncateToDouble() == weightKg ? 0 : 1)} kg',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                      const Text(' • ', style: TextStyle(color: Color(0xFF94A3B8))),
                      Text(
                        '${restSeconds}s rest',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // RIGHT CHEVRON
            const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackPhoto(Exercise ex) {
    if (ex.imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: ex.imageUrl,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => const Center(
          child: Icon(Icons.fitness_center_rounded, size: 20, color: Color(0xFF94A3B8)),
        ),
      );
    }
    return const Center(
      child: Icon(Icons.fitness_center_rounded, size: 20, color: Color(0xFF94A3B8)),
    );
  }
}
