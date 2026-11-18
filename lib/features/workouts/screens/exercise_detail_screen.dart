import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/fitora_card.dart';
import '../../../core/widgets/fitora_button.dart';
import '../../../core/widgets/fitora_muscle_badge.dart';
import '../../../data/models/exercise.dart';
import '../../../data/models/workout_plan.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise? exercise;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    if (exercise == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exercise')),
        body: const Center(child: Text('Exercise not found.')),
      );
    }

    final ex = exercise!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(ex.categoryDisplayName),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise Header & Target Muscle
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppSpacing.roundedLg,
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FitoraDifficultyIndicator(difficulty: ex.difficulty),
                        _buildTag(ex.equipment.toUpperCase(), AppColors.workoutAccent),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(ex.name, style: AppTypography.headingLarge),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Primary Target: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        FitoraMuscleBadge(muscle: ex.targetMuscle),
                      ],
                    ),
                    if (ex.secondaryMuscles.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          const Text('Secondary: ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ...ex.secondaryMuscles.map((sec) => FitoraMuscleBadge(muscle: sec, isSecondary: true)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Sets, Reps & Rest Guidance
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile('Default Sets', '${ex.defaultSets}', 'sets'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile('Default Reps', '${ex.defaultReps}', 'reps'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile('Rest Interval', '${ex.restSeconds}', 'sec'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Instructions
              FitoraCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.format_list_numbered_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('Execution Instructions', style: AppTypography.labelLarge),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      ex.instructions,
                      style: AppTypography.bodyMedium.copyWith(height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Safety Guidance
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: AppSpacing.roundedMd,
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.security_rounded, color: AppColors.warning, size: 20),
                        const SizedBox(width: 8),
                        Text('Safety & Technique Warning',
                            style: AppTypography.labelLarge.copyWith(color: const Color(0xFF78350F))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ex.safetyGuidance,
                      style: AppTypography.bodySmall.copyWith(color: const Color(0xFF78350F), height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Start Quick Session Button
              FitoraButton(
                label: 'Train This Exercise Now',
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                onPressed: () {
                  final singlePlan = WorkoutPlan(
                    id: 'quick_${ex.id}',
                    title: ex.name,
                    description: 'Focused single movement session for ${ex.targetMuscle}.',
                    level: ex.difficulty,
                    exercises: [
                      PlanExercise(
                        exerciseId: ex.id,
                        exercise: ex,
                        orderIndex: 0,
                        targetSets: ex.defaultSets,
                        targetReps: ex.defaultReps,
                        restSeconds: ex.restSeconds,
                      ),
                    ],
                  );
                  context.push('/active-workout', extra: singlePlan);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppSpacing.roundedSm,
      ),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(value, style: AppTypography.headingMedium.copyWith(color: AppColors.primary)),
          const SizedBox(height: 2),
          Text('$label ($unit)', style: AppTypography.labelSmall.copyWith(fontSize: 10), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
