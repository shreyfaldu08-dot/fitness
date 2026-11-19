import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
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
      borderRadius: BorderRadius.circular(22),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22), // Soft Capsule Card
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // STEP NUMBER PILL (if provided)
            if (index != null) ...[
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  '$index',
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],

            // 3D ANIMATED MOTION THUMBNAIL
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 70,
                height: 70,
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
                      bottom: 3,
                      right: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          '3D',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 7.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // MIDDLE INFO: Name, Target Muscle Capsule, Parameter Pills
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
                  const SizedBox(height: 5),

                  // Capsule Target Muscle Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: highlightColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999), // Stadium Capsule
                      border: Border.all(color: highlightColor.withValues(alpha: 0.25), width: 0.8),
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
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: highlightColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Capsule Parameter Chips Row
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      _buildMiniCapsule('$targetSets sets × $targetReps'),
                      if (weightKg != null && weightKg > 0)
                        _buildMiniCapsule(
                          '${weightKg.toStringAsFixed(weightKg.truncateToDouble() == weightKg ? 0 : 1)} kg',
                          isBold: true,
                        ),
                      _buildMiniCapsule('${restSeconds}s rest'),
                    ],
                  ),
                ],
              ),
            ),

            // RIGHT CHEVRON CAPSULE
            Container(
              margin: const EdgeInsets.only(left: 6),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF64748B),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCapsule(String text, {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          color: isBold ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
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
