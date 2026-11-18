import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../../data/models/workout_plan.dart';
import 'fitora_button.dart';
import 'fitora_exercise_visual_tile.dart';

/// Interactive Day-by-Day 7-Day Weekly Split Calendar & Workout Schedule
class FitoraWeeklySplitView extends StatefulWidget {
  final WorkoutPlan plan;
  final bool isCompact;

  const FitoraWeeklySplitView({
    super.key,
    required this.plan,
    this.isCompact = false,
  });

  @override
  State<FitoraWeeklySplitView> createState() => _FitoraWeeklySplitViewState();
}

class _FitoraWeeklySplitViewState extends State<FitoraWeeklySplitView> {
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _initTodayIndex();
  }

  void _initTodayIndex() {
    final nowWeekday = DateTime.now().weekday; // 1 = Monday, 7 = Sunday
    final targetIndex = (nowWeekday - 1).clamp(0, 6);
    if (widget.plan.weeklySchedule.length > targetIndex) {
      _selectedDayIndex = targetIndex;
    } else {
      _selectedDayIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedule = widget.plan.weeklySchedule;
    if (schedule.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentDay = schedule[_selectedDayIndex.clamp(0, schedule.length - 1)];
    final themeColor = widget.plan.goalBadgeColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 7-DAY WEEKLY CALENDAR STRIP
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(schedule.length, (index) {
              final day = schedule[index];
              final isSelected = index == _selectedDayIndex;
              final isRest = day.isRestDay;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDayIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? themeColor.withValues(alpha: 0.12)
                          : isRest
                              ? const Color(0xFFF1F5F9)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? themeColor
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.6 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          day.dayOfWeek,
                          style: TextStyle(
                            color: isSelected ? themeColor : const Color(0xFF475569),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: isRest
                                ? const Color(0xFFE2E8F0)
                                : isSelected
                                    ? themeColor
                                    : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isRest ? 'REST' : _getShortSplitTag(day.title),
                            style: TextStyle(
                              color: isRest
                                  ? const Color(0xFF64748B)
                                  : isSelected
                                      ? Colors.white
                                      : const Color(0xFF334155),
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(height: 3),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: themeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        // If NOT compact preview mode, render full day details & scheduled exercises
        if (!widget.isCompact) ...[
          const SizedBox(height: AppSpacing.md),

          // SELECTED DAY DETAIL CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppSpacing.roundedLg,
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day Title & Status Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            currentDay.dayName.toUpperCase(),
                            style: TextStyle(
                              color: themeColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: currentDay.isRestDay
                                ? const Color(0xFF64748B).withValues(alpha: 0.12)
                                : AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            currentDay.isRestDay ? 'RECOVERY DAY' : '${currentDay.intensity.toUpperCase()} INTENSITY',
                            style: TextStyle(
                              color: currentDay.isRestDay ? const Color(0xFF64748B) : AppColors.success,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!currentDay.isRestDay)
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '~${currentDay.estimatedMinutes}m',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title of the session
                Text(
                  currentDay.title,
                  style: AppTypography.headingSmall.copyWith(fontSize: 17),
                ),
                const SizedBox(height: 4),

                // Target Muscles
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.adjust_rounded, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        currentDay.targetMuscles,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Coach's Advisory Note for Today
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: AppSpacing.roundedMd,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.sports_rounded, size: 16, color: themeColor),
                          const SizedBox(width: 6),
                          Text(
                            "COACH'S PROTOCOL",
                            style: TextStyle(
                              color: themeColor,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        currentDay.coachTip,
                        style: AppTypography.bodySmall.copyWith(fontSize: 12, height: 1.35),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.directions_walk_rounded, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              currentDay.cardioGuidance,
                              style: AppTypography.bodySmall.copyWith(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // IF TRAINING DAY: List Exercises with Photos & 3D Anatomy
                if (!currentDay.isRestDay && currentDay.exercises.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Scheduled Exercises (${currentDay.exercises.length})',
                        style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Tap for 3D Muscle Scan',
                        style: AppTypography.labelSmall.copyWith(color: themeColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currentDay.exercises.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final planEx = currentDay.exercises[i];
                      return FitoraExerciseVisualTile(
                        planExercise: planEx,
                        index: i + 1,
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Start This Session Button
                  FitoraButton(
                    label: "Start ${currentDay.dayName}'s Session",
                    icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                    onPressed: () {
                      // Create an on-the-fly workout plan for this specific day
                      final dayPlan = WorkoutPlan(
                        id: '${widget.plan.id}_${currentDay.dayOfWeek.toLowerCase()}',
                        title: '${widget.plan.title} - ${currentDay.dayName}',
                        description: currentDay.title,
                        level: widget.plan.level,
                        daysPerWeek: widget.plan.daysPerWeek,
                        estimatedDurationMinutes: currentDay.estimatedMinutes,
                        exercises: currentDay.exercises,
                        goalType: widget.plan.goalType,
                        goalDisplayName: widget.plan.goalDisplayName,
                        splitType: widget.plan.splitType,
                      );
                      context.push('/active-workout', extra: dayPlan);
                    },
                  ),
                ] else if (currentDay.isRestDay) ...[
                  // RECOVERY PROTOCOL BANNER
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: AppSpacing.roundedMd,
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.nightlight_round, color: Color(0xFF64748B), size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Muscles Grow While Resting',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Supercompensation occurs during deep REM sleep and active hydration. Avoid strenuous lifting today to allow neuromuscular recharge.',
                                style: AppTypography.bodySmall.copyWith(fontSize: 11.5, color: const Color(0xFF475569)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _getShortSplitTag(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('push')) return 'PUSH';
    if (lower.contains('pull')) return 'PULL';
    if (lower.contains('leg')) return 'LEGS';
    if (lower.contains('upper')) return 'UPPER';
    if (lower.contains('lower')) return 'LOWER';
    if (lower.contains('tabata') || lower.contains('hiit')) return 'HIIT';
    if (lower.contains('squat')) return 'SQUAT';
    if (lower.contains('bench')) return 'BENCH';
    if (lower.contains('deadlift')) return 'DEAD';
    if (lower.contains('zone 2') || lower.contains('cardio')) return 'CARDIO';
    if (lower.contains('core')) return 'CORE';
    return 'TRAIN';
  }
}
