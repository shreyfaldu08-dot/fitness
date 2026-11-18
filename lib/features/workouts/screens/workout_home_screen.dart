import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/fitora_card.dart';
import '../../../core/widgets/fitora_button.dart';
import '../../../core/widgets/fitora_muscle_badge.dart';
import '../../../core/widgets/fitora_muscle_illustration.dart';
import '../../../data/models/workout_plan.dart';

class WorkoutHomeScreen extends ConsumerWidget {
  const WorkoutHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutRepo = ref.watch(workoutRepositoryProvider);
    final plans = workoutRepo.getAllPlans();
    final sessions = workoutRepo.getWorkoutSessions();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Workout Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Workout History',
            onPressed: () => context.push('/workout-history'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Quick Start Card
              FitoraCard(
                color: AppColors.primary,
                border: Border.all(color: Colors.transparent),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: AppSpacing.roundedSm,
                          ),
                          child: Text(
                            'READY TO TRAIN',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Icon(Icons.fitness_center_rounded, color: Colors.white, size: 24),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Push Your Limits Today',
                      style: AppTypography.headingMedium.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Log weights, track rest intervals, and break personal records.',
                      style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FitoraButton(
                      label: 'Start Blank Workout',
                      variant: FitoraButtonVariant.secondary,
                      onPressed: () => context.push('/active-workout'),
                      height: 44,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Quick Actions Row
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.menu_book_rounded,
                      title: 'Exercise Library',
                      subtitle: '9 muscle groups',
                      color: AppColors.workoutAccent,
                      onTap: () => context.push('/exercises'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.add_circle_outline_rounded,
                      title: 'Build Plan',
                      subtitle: 'Custom routine',
                      color: AppColors.proteinAccent,
                      onTap: () => context.push('/workout-builder'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Workout Templates
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Training Plans & Splits', style: AppTypography.headingSmall),
                  Text('${plans.length} available', style: AppTypography.labelSmall),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: plans.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  return _buildPlanCard(context, plan);
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // Recent History Snippet
              if (sessions.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Workouts', style: AppTypography.headingSmall),
                    InkWell(
                      onTap: () => context.push('/workout-history'),
                      child: Text('View All', style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ...sessions.take(3).map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: FitoraCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: AppSpacing.roundedSm,
                              ),
                              child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.workoutName, style: AppTypography.labelLarge),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${s.setsCompleted} sets • ${s.totalVolumeKg.round()} kg total volume',
                                    style: AppTypography.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${s.durationSeconds ~/ 60}m',
                              style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return FitoraCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppSpacing.roundedSm,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(title, style: AppTypography.labelLarge),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTypography.bodySmall.copyWith(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, WorkoutPlan plan) {
    return FitoraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FitoraMuscleBadge(muscle: plan.category.toUpperCase()),
              FitoraDifficultyIndicator(difficulty: plan.difficulty),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(plan.title, style: AppTypography.headingSmall),
          const SizedBox(height: 4),
          Text(
            plan.description,
            style: AppTypography.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('${plan.daysPerWeek} days/wk', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
              const SizedBox(width: 12),
              const Icon(Icons.timer_outlined, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('~${plan.estimatedDurationMinutes}m', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
              const SizedBox(width: 12),
              const Icon(Icons.fitness_center_rounded, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('${plan.exercises.length} movements', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Preview exercises in bottom sheet
                    _showPlanExercisesSheet(context, plan);
                  },
                  child: Text('View ${plan.exercises.length} Exercises'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.push('/active-workout', extra: plan),
                  child: const Text('Start Routine'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPlanExercisesSheet(BuildContext context, WorkoutPlan plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(plan.title, style: AppTypography.headingSmall),
                  const SizedBox(height: 4),
                  Text('${plan.exercises.length} exercises scheduled in this session', style: AppTypography.bodySmall),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      controller: controller,
                      itemCount: plan.exercises.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (c, i) {
                        final ex = plan.exercises[i];
                        final name = ex.exercise?.name ?? 'Exercise';
                        final muscle = ex.exercise?.targetMuscle ?? plan.category;
                        final secondary = ex.exercise?.secondaryMuscles ?? [];

                        return InkWell(
                          onTap: () {
                            if (ex.exercise != null) {
                              context.push('/exercise-detail', extra: ex.exercise);
                            }
                          },
                          borderRadius: AppSpacing.roundedMd,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: AppSpacing.roundedMd,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                // Step # and Anatomical Muscle Illustration
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    FitoraMuscleIllustration(
                                      muscle: muscle,
                                      width: 54,
                                      height: 66,
                                    ),
                                    Positioned(
                                      top: -4,
                                      left: -4,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 1.5),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${i + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),

                                // Exercise details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 4,
                                        runSpacing: 4,
                                        children: [
                                          FitoraMuscleBadge(muscle: muscle),
                                          if (secondary.isNotEmpty)
                                            FitoraMuscleBadge(muscle: secondary.first, isSecondary: true),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${ex.targetSets} sets × ${ex.targetReps} reps • ${ex.restSeconds}s rest',
                                        style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),

                                // Target Weight
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceMuted,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${ex.defaultWeightKg} kg',
                                    style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
