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
import '../../../core/widgets/fitora_exercise_visual_tile.dart';
import '../../../core/widgets/fitora_weekly_split_view.dart';
import '../../../data/models/workout_plan.dart';

class WorkoutHomeScreen extends ConsumerStatefulWidget {
  const WorkoutHomeScreen({super.key});

  @override
  ConsumerState<WorkoutHomeScreen> createState() => _WorkoutHomeScreenState();
}

class _WorkoutHomeScreenState extends ConsumerState<WorkoutHomeScreen> {
  String _selectedGoal = 'all';

  final List<Map<String, dynamic>> _goalFilters = [
    {'id': 'all', 'label': 'All Goals', 'icon': Icons.apps_rounded, 'color': AppColors.primary},
    {'id': 'muscle_gain', 'label': 'Muscle Gain', 'icon': Icons.fitness_center_rounded, 'color': Color(0xFF8B5CF6)},
    {'id': 'fat_loss', 'label': 'Fat Loss & Shred', 'icon': Icons.local_fire_department_rounded, 'color': Color(0xFFEF4444)},
    {'id': 'strength', 'label': 'Pure Strength', 'icon': Icons.offline_bolt_rounded, 'color': Color(0xFFF59E0B)},
    {'id': 'recomposition', 'label': 'Body Recomp', 'icon': Icons.auto_awesome_rounded, 'color': Color(0xFF10B981)},
    {'id': 'calisthenics', 'label': 'Home Bodyweight', 'icon': Icons.accessibility_new_rounded, 'color': Color(0xFF06B6D4)},
  ];

  @override
  Widget build(BuildContext context) {
    final workoutRepo = ref.watch(workoutRepositoryProvider);
    final allPlans = workoutRepo.getAllPlans();
    final sessions = workoutRepo.getWorkoutSessions();
    final activeProgram = workoutRepo.getActiveMultiWeekProgram();

    final filteredPlans = _selectedGoal == 'all'
        ? allPlans
        : allPlans.where((p) => p.goalType.toLowerCase() == _selectedGoal.toLowerCase()).toList();

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
                      'Targeted hypertrophy splits, metabolic fat loss circuits, and strength protocols.',
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

              // ACTIVE MULTI-WEEK PROGRAM CARD
              FitoraCard(
                padding: const EdgeInsets.all(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.stars_rounded, size: 14, color: AppColors.primary),
                              SizedBox(width: 5),
                              Text(
                                'ACTIVE MULTI-WEEK PROGRAM',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Week ${activeProgram.currentWeekNumber} of ${activeProgram.totalWeeks}',
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(activeProgram.title, style: AppTypography.headingSmall.copyWith(fontSize: 16)),
                    const SizedBox(height: 3),
                    Text(
                      activeProgram.isCommonTemplate
                          ? 'Common weekly routine repeating across ${activeProgram.totalWeeks} weeks'
                          : 'Customized week-by-week mesocycle (${activeProgram.weeks.length} weeks configured)',
                      style: AppTypography.bodySmall.copyWith(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.tune_rounded, size: 16),
                            label: const Text('Customize Multi-Week Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            onPressed: () => context.push('/multi-week-planner'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

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
                      icon: Icons.calendar_month_rounded,
                      title: 'Multi-Week Planner',
                      subtitle: 'Custom 4-12 wks',
                      color: AppColors.proteinAccent,
                      onTap: () => context.push('/multi-week-planner'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // SECTION HEADER: GOAL-BASED TRAINING PLANS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Training Plans & Splits', style: AppTypography.headingSmall),
                  Text('${filteredPlans.length} programs', style: AppTypography.labelSmall),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Evidence-based routines structured by primary fitness goals and weekly splits.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),

              // INTERACTIVE GOAL FILTER BAR
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _goalFilters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final filter = _goalFilters[i];
                    final isSelected = _selectedGoal == filter['id'];
                    final color = filter['color'] as Color;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGoal = filter['id'] as String;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? color : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? color : AppColors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              filter['icon'] as IconData,
                              size: 15,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              filter['label'] as String,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // LIST OF TRAINING PLANS
              if (filteredPlans.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppSpacing.roundedMd,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.fitness_center_outlined, size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text('No programs found for this goal', style: AppTypography.headingSmall),
                      const SizedBox(height: 6),
                      Text(
                        'Select another goal filter or build your own custom plan.',
                        style: AppTypography.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredPlans.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final plan = filteredPlans[index];
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
    final goalColor = plan.goalBadgeColor;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header: Goal Badge + Difficulty
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: goalColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: goalColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(plan.goalIcon, size: 14, color: goalColor),
                    const SizedBox(width: 6),
                    Text(
                      plan.goalDisplayName.toUpperCase(),
                      style: TextStyle(
                        color: goalColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              FitoraDifficultyIndicator(difficulty: plan.difficulty),
            ],
          ),
          const SizedBox(height: 12),

          // Plan Title & Split Type Subtitle
          Text(plan.title, style: AppTypography.headingSmall.copyWith(fontSize: 18)),
          const SizedBox(height: 2),
          Text(
            plan.splitType,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: goalColor,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            plan.description,
            style: AppTypography.bodySmall.copyWith(height: 1.35),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Schedule Details Row
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('${plan.daysPerWeek} days/wk', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
              const SizedBox(width: 14),
              const Icon(Icons.timer_outlined, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('~${plan.estimatedDurationMinutes}m', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
              const SizedBox(width: 14),
              const Icon(Icons.fitness_center_rounded, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('${plan.exercises.length} movements', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 14),

          // 7-DAY WEEKLY SPLIT PREVIEW STRIP
          if (plan.weeklySchedule.isNotEmpty) ...[
            FitoraWeeklySplitView(plan: plan, isCompact: true),
            const SizedBox(height: 14),
          ],

          // S&C COACH ADVICE SNIPPET
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: AppSpacing.roundedMd,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.psychology_rounded, size: 18, color: goalColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "COACH'S PROTOCOL",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: goalColor,
                              letterSpacing: 0.6,
                            ),
                          ),
                          Text(
                            plan.coachingAdvice.targetRpe,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.coachingAdvice.nutritionSynergy,
                        style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Action Buttons: View Split & Start
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _showPlanExercisesSheet(context, plan);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: goalColor),
                    foregroundColor: goalColor,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  child: const Text(
                    'View Weekly Split',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.push('/active-workout', extra: plan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goalColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  child: const Text(
                    'Start Routine',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
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
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DefaultTabController(
          length: 2,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.88,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Sheet Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: plan.goalBadgeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                plan.goalDisplayName.toUpperCase(),
                                style: TextStyle(
                                  color: plan.goalBadgeColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(plan.title, style: AppTypography.headingSmall),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Tab Bar: 7-Day Weekly Split vs Session Movements
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: plan.goalBadgeColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      tabs: const [
                        Tab(text: '7-Day Weekly Split'),
                        Tab(text: 'All Movements (3D Scan)'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    children: [
                      // TAB 1: Complete 7-Day Weekly Split Calendar View
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FitoraWeeklySplitView(plan: plan),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),

                      // TAB 2: All Plan Exercises with Dual Movement Photo & 3D Anatomy
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${plan.exercises.length} Core Exercises Scheduled',
                              style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap any movement to inspect full muscle scan & execution cues.',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 12),

                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: plan.exercises.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (c, i) {
                                final ex = plan.exercises[i];
                                return FitoraExerciseVisualTile(
                                  planExercise: ex,
                                  index: i + 1,
                                );
                              },
                            ),
                            const SizedBox(height: 24),

                            FitoraButton(
                              label: 'Start Routine Now',
                              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                              onPressed: () {
                                Navigator.pop(ctx);
                                context.push('/active-workout', extra: plan);
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
