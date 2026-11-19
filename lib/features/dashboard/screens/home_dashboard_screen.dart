import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/fitora_concentric_rings.dart';
import '../../../core/widgets/fitora_week_streak.dart';
import '../../../core/widgets/fitora_animated_exercise_demo.dart';
import '../../../core/widgets/fitora_exercise_visual_tile.dart';
import '../../../data/models/workout_plan.dart';

/// Clean Minimalist "Today's Focus" Home Dashboard.
/// Inspired by Apple Fitness: Crisp white surfaces, ample breathing room,
/// prominent single workout card with realistic 3D animated demonstration,
/// and smooth progress rings.
class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final goal = ref.watch(fitnessGoalProvider);
    final activity = ref.watch(todayActivityProvider);
    final waterMl = ref.watch(todayWaterProvider);
    final nutritionLogs = ref.watch(nutritionLogsProvider);
    final workoutRepo = ref.watch(workoutRepositoryProvider);

    // Nutrition Totals
    final totalCaloriesLogged = nutritionLogs.fold(0.0, (sum, l) => sum + l.calories).round();
    final targetCalories = goal.targetCalories;

    // Active Multi-Week Program & Today's Schedule
    final activeProgram = workoutRepo.getActiveMultiWeekProgram();
    final todaySchedule = activeProgram.getTodaySchedule();
    final plans = workoutRepo.getAllPlans();
    final fallbackPlan = plans.isNotEmpty ? plans.first : null;

    final now = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Apple-style pristine light neutral
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
                // 1. MINIMAL HEADER BAR
                _buildHeaderBar(
                  context: context,
                  name: profile?.fullName ?? 'Athlete',
                  date: DateFormatter.formatFullDate(now),
                ),
                const SizedBox(height: 18),

                // 2. APPLE-STYLE ACTIVITY RINGS
                _buildActivityRingsCard(
                  activity: activity,
                  goal: goal,
                  onAddSteps: () => ref.read(todayActivityProvider.notifier).addSteps(1000),
                ),
                const SizedBox(height: 18),

                // 3. HERO: "TODAY'S FOCUS" WORKOUT CARD
                _buildTodayFocusHeroCard(
                  context: context,
                  activeProgram: activeProgram,
                  todaySchedule: todaySchedule,
                  fallbackPlan: fallbackPlan,
                  onStart: () {
                    if (todaySchedule != null && !todaySchedule.isRestDay && todaySchedule.exercises.isNotEmpty) {
                      final dayPlan = WorkoutPlan(
                        id: '${activeProgram.id}_today',
                        title: todaySchedule.title,
                        description: todaySchedule.coachTip,
                        exercises: todaySchedule.exercises,
                        goalType: activeProgram.goalType,
                        goalDisplayName: activeProgram.goalDisplayName,
                      );
                      context.push('/active-workout', extra: dayPlan);
                    } else if (fallbackPlan != null) {
                      context.push('/active-workout', extra: fallbackPlan);
                    }
                  },
                ),
                const SizedBox(height: 18),

                // 4. QUICK FUEL & HYDRATION ROW
                _buildFuelAndWaterRow(
                  context: context,
                  waterMl: waterMl,
                  waterGoalMl: goal.targetWaterMl,
                  caloriesLogged: totalCaloriesLogged,
                  calorieTarget: targetCalories,
                  onAddWater: (amt) => ref.read(todayWaterProvider.notifier).addWater(amt),
                ),
                const SizedBox(height: 18),

                // 5. 7-DAY CONSISTENCY STREAK
                const FitoraWeekStreak(
                  streakDays: 5,
                  daysCompleted: [true, true, true, true, true, false, false],
                ),
                const SizedBox(height: 18),

                // 6. QUICK NAVIGATION TILES (Splits & Planner)
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickTile(
                        context: context,
                        icon: Icons.fitness_center_rounded,
                        color: const Color(0xFF2563EB),
                        title: 'Workout Splits',
                        subtitle: 'Goals & routines',
                        onTap: () => context.push('/workouts'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickTile(
                        context: context,
                        icon: Icons.calendar_month_rounded,
                        color: const Color(0xFF10B981),
                        title: 'Mesocycle',
                        subtitle: 'Multi-week plan',
                        onTap: () => context.push('/multi-week-planner'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBar({
    required BuildContext context,
    required String name,
    required String date,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning, $name',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            InkWell(
              onTap: () => context.push('/analytics'),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(Icons.bar_chart_rounded, size: 20, color: Color(0xFF0F172A)),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => context.push('/ai-coach'),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: const Icon(Icons.auto_awesome_rounded, size: 20, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityRingsCard({
    required dynamic activity,
    required dynamic goal,
    required VoidCallback onAddSteps,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.donut_large_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Daily Activity Rings',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onAddSteps,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '+ 1,000 Steps',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FitoraConcentricRings(
            moveProgress: (activity.caloriesBurned / 500.0).clamp(0.0, 1.5),
            exerciseProgress: (activity.activeMinutes / 45.0).clamp(0.0, 1.5),
            standProgress: (goal.targetSteps > 0
                    ? activity.steps / goal.targetSteps
                    : 0.0)
                .clamp(0.0, 1.5),
            moveValue: activity.caloriesBurned,
            moveTarget: 500,
            exerciseValue: activity.activeMinutes,
            exerciseTarget: 45,
            standValue: activity.steps,
            standTarget: goal.targetSteps,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayFocusHeroCard({
    required BuildContext context,
    required MultiWeekProgram activeProgram,
    required WorkoutDaySchedule? todaySchedule,
    required WorkoutPlan? fallbackPlan,
    required VoidCallback onStart,
  }) {
    final isRest = todaySchedule?.isRestDay ?? false;
    final title = todaySchedule?.title ?? fallbackPlan?.title ?? 'Daily Movement Protocol';
    final duration = todaySchedule?.estimatedMinutes ?? fallbackPlan?.estimatedDurationMinutes ?? 45;
    final exercises = todaySchedule?.exercises ?? fallbackPlan?.exercises ?? [];
    final leadEx = exercises.isNotEmpty ? exercises.first.exercise : null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PROGRAM STATUS PILL & MULTI-WEEK LABEL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'WEEK ${activeProgram.currentWeekNumber} OF ${activeProgram.totalWeeks} • ${activeProgram.goalDisplayName.toUpperCase()}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              InkWell(
                onTap: () => context.push('/multi-week-planner'),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Planner',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(Icons.arrow_forward_ios_rounded, size: 9, color: Color(0xFF64748B)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // TITLE & DURATION
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(
                '~$duration mins',
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.fitness_center_rounded, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(
                '${exercises.length} movements scheduled',
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3D ANIMATED MOVEMENT OF TODAY'S LEAD EXERCISE
          if (!isRest && leadEx != null) ...[
            FitoraAnimatedExerciseDemo(
              exercise: leadEx,
              height: 200,
              isCompact: true,
              showControls: true,
            ),
            const SizedBox(height: 14),
          ] else if (isRest) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bedtime_rounded, color: Color(0xFF64748B), size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Scheduled Rest & Muscle Recovery Day. Focus on hydration and light walking.',
                      style: TextStyle(fontSize: 12.5, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // ACTION BUTTONS: Start Workout & View Breakdown
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                  label: Text(
                    isRest ? 'Train Anyway' : 'Start Today\'s Workout',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                ),
              ),
              if (exercises.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed: () => _showExerciseBreakdown(context, title, exercises),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      'View Plan',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showExerciseBreakdown(BuildContext context, String title, List<PlanExercise> exercises) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '${exercises.length} exercises with 3D movement scans',
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: exercises.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (c, i) {
                    final ex = exercises[i];
                    return FitoraExerciseVisualTile(
                      planExercise: ex,
                      index: i + 1,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFuelAndWaterRow({
    required BuildContext context,
    required int waterMl,
    required int waterGoalMl,
    required int caloriesLogged,
    required int calorieTarget,
    required ValueChanged<int> onAddWater,
  }) {
    return Row(
      children: [
        // HYDRATION CAPSULE CARD
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.water_drop_rounded, color: Color(0xFF0EA5E9), size: 18),
                    InkWell(
                      onTap: () => onAddWater(250),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          '+250ml',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${(waterMl / 1000).toStringAsFixed(1)} / ${(waterGoalMl / 1000).toStringAsFixed(1)} L',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                const Text('Hydration Log', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // NUTRITION CAPSULE CARD
        Expanded(
          child: InkWell(
            onTap: () => context.push('/food-search?mealType=lunch'),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.restaurant_rounded, color: Color(0xFFF59E0B), size: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          '+ Food',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$caloriesLogged / $calorieTarget kcal',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text('Nutrition Target', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickTile({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
