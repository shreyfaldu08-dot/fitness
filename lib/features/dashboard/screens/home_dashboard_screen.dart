import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/fitora_card.dart';
import '../../../core/widgets/fitora_button.dart';
import '../../../core/widgets/fitora_concentric_rings.dart';
import '../../../core/widgets/fitora_water_bottle.dart';
import '../../../core/widgets/fitora_macro_gauge.dart';
import '../../../core/widgets/fitora_week_streak.dart';
import '../../../core/widgets/fitora_muscle_badge.dart';
import '../../../core/widgets/fitora_muscle_illustration.dart';
import '../../../data/models/workout_plan.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final goal = ref.watch(fitnessGoalProvider);
    final activity = ref.watch(todayActivityProvider);
    final waterMl = ref.watch(todayWaterProvider);
    final nutritionLogs = ref.watch(nutritionLogsProvider);
    final habits = ref.watch(habitsListProvider);
    final workoutRepo = ref.watch(workoutRepositoryProvider);
    final progressRepo = ref.watch(progressRepositoryProvider);

    // Calculate real nutrition totals for today
    final totalCaloriesLogged = nutritionLogs.fold(0.0, (sum, l) => sum + l.calories).round();
    final totalProteinLogged = nutritionLogs.fold(0.0, (sum, l) => sum + l.protein).round();
    final totalCarbsLogged = nutritionLogs.fold(0.0, (sum, l) => sum + l.carbs).round();
    final totalFatLogged = nutritionLogs.fold(0.0, (sum, l) => sum + l.fat).round();

    final targetCalories = goal.targetCalories;
    final remainingCalories = (targetCalories - totalCaloriesLogged).clamp(0, 5000);
    final calorieProgress = targetCalories > 0 ? (totalCaloriesLogged / targetCalories).clamp(0.0, 1.0) : 0.0;

    // Get Today's scheduled or featured workout
    final plans = workoutRepo.getAllPlans();
    final featuredPlan = plans.isNotEmpty ? plans.first : null;

    // Progress snapshot metrics
    final latestMeas = progressRepo.getLatestMeasurement();
    final currentWeight = latestMeas?.weightKg ?? profile?.currentWeightKg ?? 72.0;
    final initialWeight = profile?.currentWeightKg ?? currentWeight;
    final weightDelta = currentWeight - initialWeight;

    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(userProfileProvider);
            ref.invalidate(fitnessGoalProvider);
            ref.invalidate(nutritionLogsProvider);
            ref.invalidate(habitsListProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // A. GREETING & HEADER SECTION
                _buildGreetingHeader(
                  name: profile?.fullName ?? 'Athlete',
                  date: DateFormatter.formatFullDate(now),
                  onAiTap: () => context.push('/ai-coach'),
                  onAnalyticsTap: () => context.push('/analytics'),
                ),
                const SizedBox(height: AppSpacing.md),

                // Motivation Insight
                _buildMotivationBanner(),
                const SizedBox(height: AppSpacing.lg),

                // 7-Day Consistency Streak
                const FitoraWeekStreak(
                  streakDays: 5,
                  daysCompleted: [true, true, true, true, true, false, false],
                ),
                const SizedBox(height: AppSpacing.lg),

                // B. DAILY ACTIVITY RINGS (Steps, Active Min, Burned)
                _buildActivitySection(
                  activity: activity,
                  goal: goal,
                  onAddSteps: () => ref.read(todayActivityProvider.notifier).addSteps(1000),
                ),
                const SizedBox(height: AppSpacing.lg),

                // C. NUTRITION SUMMARY
                _buildNutritionSummaryCard(
                  context: context,
                  caloriesConsumed: totalCaloriesLogged,
                  calorieTarget: targetCalories,
                  remainingCalories: remainingCalories,
                  calorieProgress: calorieProgress,
                  protein: totalProteinLogged,
                  targetProtein: goal.targetProteinG,
                  carbs: totalCarbsLogged,
                  targetCarbs: goal.targetCarbsG,
                  fat: totalFatLogged,
                  targetFat: goal.targetFatG,
                ),
                const SizedBox(height: AppSpacing.lg),

                // D. HYDRATION CARD (with Quick Add Buttons)
                _buildHydrationCard(
                  waterConsumedMl: waterMl,
                  waterGoalMl: goal.targetWaterMl,
                  onAddWater: (amount) => ref.read(todayWaterProvider.notifier).addWater(amount),
                ),
                const SizedBox(height: AppSpacing.lg),

                // E. TODAY'S WORKOUT
                if (featuredPlan != null) ...[
                  _buildTodayWorkoutCard(
                    context: context,
                    plan: featuredPlan,
                    onStart: () => context.push('/active-workout', extra: featuredPlan),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // F. DAILY HABITS
                _buildDailyHabitsSection(
                  habits: habits,
                  onToggle: (id) => ref.read(habitsListProvider.notifier).toggleHabit(id),
                  onViewAll: () => context.push('/habits'),
                ),
                const SizedBox(height: AppSpacing.lg),

                // G. PROGRESS SNAPSHOT
                _buildProgressSnapshot(
                  currentWeight: currentWeight,
                  weightDelta: weightDelta,
                  onTap: () => context.push('/analytics'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingHeader({
    required String name,
    required String date,
    required VoidCallback onAiTap,
    required VoidCallback onAnalyticsTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning, $name',
              style: AppTypography.headingLarge.copyWith(letterSpacing: -0.4),
            ),
            const SizedBox(height: 2),
            Text(
              date,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: onAnalyticsTap,
              icon: const Icon(Icons.bar_chart_rounded, size: 24, color: AppColors.textPrimary),
              tooltip: 'Analytics',
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: onAiTap,
                icon: const Icon(Icons.auto_awesome_rounded, size: 20, color: AppColors.primary),
                tooltip: 'AI Coach',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMotivationBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline_rounded, color: AppColors.warning, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Consistency is key. Every clean rep and nutritious meal moves the needle.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection({
    required dynamic activity,
    required dynamic goal,
    required VoidCallback onAddSteps,
  }) {
    final stepsProgress = goal.targetSteps > 0 ? (activity.steps / goal.targetSteps) : 0.0;
    final exerciseProgress = 45 > 0 ? (activity.activeMinutes / 45.0) : 0.0;
    final moveProgress = 600 > 0 ? (activity.caloriesBurned / 600.0) : 0.0;

    return FitoraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.incomplete_circle_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('Daily Movement Rings', style: AppTypography.labelLarge),
                ],
              ),
              InkWell(
                onTap: onAddSteps,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('+1k Steps', style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FitoraConcentricRings(
            moveProgress: moveProgress,
            exerciseProgress: exerciseProgress,
            standProgress: stepsProgress,
            moveValue: activity.caloriesBurned,
            moveTarget: 600,
            exerciseValue: activity.activeMinutes,
            exerciseTarget: 45,
            standValue: activity.steps,
            standTarget: goal.targetSteps,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummaryCard({
    required BuildContext context,
    required int caloriesConsumed,
    required int calorieTarget,
    required int remainingCalories,
    required double calorieProgress,
    required int protein,
    required int targetProtein,
    required int carbs,
    required int targetCarbs,
    required int fat,
    required int targetFat,
  }) {
    return FitoraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.restaurant_rounded, color: AppColors.carbAccent, size: 20),
                  const SizedBox(width: 8),
                  Text('Nutrition & Fuel Target', style: AppTypography.labelLarge),
                ],
              ),
              InkWell(
                onTap: () => context.push('/food-search?mealType=lunch'),
                child: Text('+ Log Food', style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FitoraMacroGauge(
            caloriesConsumed: caloriesConsumed,
            calorieTarget: calorieTarget,
            proteinConsumed: protein,
            proteinTarget: targetProtein,
            carbsConsumed: carbs,
            carbsTarget: targetCarbs,
            fatConsumed: fat,
            fatTarget: targetFat,
          ),
        ],
      ),
    );
  }

  Widget _buildHydrationCard({
    required int waterConsumedMl,
    required int waterGoalMl,
    required ValueChanged<int> onAddWater,
  }) {
    return FitoraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.water_drop_rounded, color: AppColors.waterAccent, size: 20),
                  const SizedBox(width: 8),
                  Text('Daily Hydration', style: AppTypography.labelLarge),
                ],
              ),
              Text(
                'Goal: ${(waterGoalMl / 1000).toStringAsFixed(1)}L',
                style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FitoraWaterBottle(
            consumedMl: waterConsumedMl,
            targetMl: waterGoalMl,
            onAddWater: onAddWater,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayWorkoutCard({
    required BuildContext context,
    required WorkoutPlan plan,
    required VoidCallback onStart,
  }) {
    return FitoraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.workoutAccent.withValues(alpha: 0.12),
                  borderRadius: AppSpacing.roundedSm,
                ),
                child: Text(
                  'TODAY\'S TRAINING',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.workoutAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              FitoraDifficultyIndicator(difficulty: plan.difficulty),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FitoraMuscleIllustration(
                muscle: plan.category,
                width: 58,
                height: 72,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.title, style: AppTypography.headingSmall),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text('${plan.estimatedDurationMinutes} mins', style: AppTypography.bodySmall),
                        const SizedBox(width: 10),
                        const Icon(Icons.fitness_center_rounded, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text('${plan.exercises.length} exercises', style: AppTypography.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        FitoraMuscleBadge(muscle: plan.category.toUpperCase()),
                        const FitoraMuscleBadge(muscle: 'Hypertrophy', isSecondary: true),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FitoraButton(
            label: 'Start Workout Session',
            icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
            onPressed: onStart,
            height: 46,
          ),
        ],
      ),
    );
  }

  Widget _buildDailyHabitsSection({
    required List<dynamic> habits,
    required ValueChanged<String> onToggle,
    required VoidCallback onViewAll,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Daily Habits', style: AppTypography.labelLarge),
            InkWell(
              onTap: onViewAll,
              child: Text('Manage', style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 94,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: habits.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final habit = habits[index];
              return InkWell(
                onTap: () => onToggle(habit.id),
                borderRadius: AppSpacing.roundedMd,
                child: Container(
                  width: 135,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: habit.isCompletedToday ? AppColors.successLight : Colors.white,
                    borderRadius: AppSpacing.roundedMd,
                    border: Border.all(
                      color: habit.isCompletedToday ? AppColors.success : AppColors.border,
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            habit.isCompletedToday ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                            size: 18,
                            color: habit.isCompletedToday ? AppColors.success : AppColors.textSecondary,
                          ),
                          Text(
                            '🔥 ${habit.currentStreak}d',
                            style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        habit.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: habit.isCompletedToday ? AppColors.success : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSnapshot({
    required double currentWeight,
    required double weightDelta,
    required VoidCallback onTap,
  }) {
    final isLoss = weightDelta < 0;

    return FitoraCard(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Transformation Snapshot', style: AppTypography.labelLarge),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('${currentWeight.toStringAsFixed(1)} kg', style: AppTypography.statDisplay.copyWith(fontSize: 22)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isLoss ? AppColors.successLight : AppColors.primaryLight,
                      borderRadius: AppSpacing.roundedSm,
                    ),
                    child: Text(
                      '${isLoss ? "" : "+"}${weightDelta.toStringAsFixed(1)} kg',
                      style: AppTypography.labelSmall.copyWith(
                        color: isLoss ? AppColors.success : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
