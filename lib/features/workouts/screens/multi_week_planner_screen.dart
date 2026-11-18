import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/fitora_button.dart';
import '../../../core/widgets/fitora_card.dart';
import '../../../core/widgets/fitora_chip.dart';
import '../../../core/widgets/fitora_exercise_visual_tile.dart';
import '../../../data/models/workout_plan.dart';
import '../../../data/seed/seed_exercises.dart';

class MultiWeekPlannerScreen extends ConsumerStatefulWidget {
  const MultiWeekPlannerScreen({super.key});

  @override
  ConsumerState<MultiWeekPlannerScreen> createState() => _MultiWeekPlannerScreenState();
}

class _MultiWeekPlannerScreenState extends ConsumerState<MultiWeekPlannerScreen> {
  late MultiWeekProgram _program;
  final _titleController = TextEditingController();
  int _selectedWeekIndex = 0;
  int _selectedDayIndex = 0;
  bool _isCommonTemplate = true;

  final List<String> _goals = [
    'muscle_gain',
    'fat_loss',
    'strength',
    'recomposition',
    'calisthenics',
  ];

  final Map<String, String> _goalDisplayNames = {
    'muscle_gain': 'Muscle Hypertrophy',
    'fat_loss': 'Fat Loss & Shred',
    'strength': 'Pure Strength',
    'recomposition': 'Body Recomp',
    'calisthenics': 'Home Bodyweight',
  };

  @override
  void initState() {
    super.initState();
    final repo = ref.read(workoutRepositoryProvider);
    _program = repo.getActiveMultiWeekProgram();
    _titleController.text = _program.title;
    _isCommonTemplate = _program.isCommonTemplate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _addWeek() {
    setState(() {
      final newWeekNum = _program.weeks.length + 1;
      // Copy schedule from previous week or default
      final previousDays = _program.weeks.isNotEmpty
          ? _program.weeks.last.days
          : <WorkoutDaySchedule>[];

      final newWeek = ProgramWeek(
        weekNumber: newWeekNum,
        focusTitle: 'Week $newWeekNum: Progression & Overload',
        days: List.from(previousDays),
      );

      final updatedWeeks = List<ProgramWeek>.from(_program.weeks)..add(newWeek);
      _program = _program.copyWith(
        totalWeeks: updatedWeeks.length,
        weeks: updatedWeeks,
      );
      _selectedWeekIndex = updatedWeeks.length - 1;
    });
  }

  void _removeWeek(int index) {
    if (_program.weeks.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A program must have at least 1 week.')),
      );
      return;
    }

    setState(() {
      final updated = List<ProgramWeek>.from(_program.weeks)..removeAt(index);
      // Re-number weeks
      final renumbered = List.generate(updated.length, (i) {
        return updated[i].copyWith(weekNumber: i + 1);
      });
      _program = _program.copyWith(
        totalWeeks: renumbered.length,
        weeks: renumbered,
      );
      _selectedWeekIndex = _selectedWeekIndex.clamp(0, renumbered.length - 1);
    });
  }

  void _toggleCommonTemplate(bool value) {
    setState(() {
      _isCommonTemplate = value;
      _program = _program.copyWith(isCommonTemplate: value);

      // If switching to common template, propagate week 1 to all weeks
      if (value && _program.weeks.isNotEmpty) {
        final masterDays = _program.weeks.first.days;
        final syncedWeeks = _program.weeks.map((w) {
          return w.copyWith(days: List.from(masterDays));
        }).toList();
        _program = _program.copyWith(weeks: syncedWeeks);
      }
    });
  }

  void _updateSelectedDay(WorkoutDaySchedule updatedDay) {
    setState(() {
      final curWeek = _program.weeks[_selectedWeekIndex];
      final updatedDays = List<WorkoutDaySchedule>.from(curWeek.days);
      updatedDays[_selectedDayIndex] = updatedDay;

      if (_isCommonTemplate) {
        // Sync to all weeks
        final updatedWeeks = _program.weeks.map((w) {
          final wDays = List<WorkoutDaySchedule>.from(w.days);
          wDays[_selectedDayIndex] = updatedDay;
          return w.copyWith(days: wDays);
        }).toList();
        _program = _program.copyWith(weeks: updatedWeeks);
      } else {
        final updatedWeek = curWeek.copyWith(days: updatedDays);
        final updatedWeeks = List<ProgramWeek>.from(_program.weeks);
        updatedWeeks[_selectedWeekIndex] = updatedWeek;
        _program = _program.copyWith(weeks: updatedWeeks);
      }
    });
  }

  Future<void> _saveProgram() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a program title.')),
      );
      return;
    }

    final updatedProgram = _program.copyWith(
      title: title,
      isCommonTemplate: _isCommonTemplate,
      activatedAt: DateTime.now(),
    );

    final repo = ref.read(workoutRepositoryProvider);
    await repo.saveActiveMultiWeekProgram(updatedProgram);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Active Program "${updatedProgram.title}" successfully saved!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_program.weeks.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentWeek = _program.weeks[_selectedWeekIndex.clamp(0, _program.weeks.length - 1)];
    final currentDay = currentWeek.days.isNotEmpty
        ? currentWeek.days[_selectedDayIndex.clamp(0, currentWeek.days.length - 1)]
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Multi-Week Program Planner'),
        actions: [
          TextButton.icon(
            onPressed: _saveProgram,
            icon: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
            label: Text(
              'Save & Activate',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PROGRAM TITLE & GOAL SECTION
              FitoraCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Program Overview', style: AppTypography.headingSmall.copyWith(fontSize: 16)),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Program Title',
                        hintText: 'e.g. 8-Week Hypertrophy Mesocycle',
                        prefixIcon: Icon(Icons.edit_note_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Primary Athletic Goal', style: AppTypography.labelSmall),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _goals.map((g) {
                          final isSelected = _program.goalType == g;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FitoraChip(
                              label: _goalDisplayNames[g] ?? g,
                              isSelected: isSelected,
                              onTap: () {
                                setState(() {
                                  _program = _program.copyWith(
                                    goalType: g,
                                    goalDisplayName: _goalDisplayNames[g] ?? g,
                                  );
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // PLANNING MODE SELECTOR (Common Repeating vs. Week-by-Week Custom)
              FitoraCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Planning Architecture', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _isCommonTemplate ? 'REPEATING TEMPLATE' : 'CUSTOM MESOCYCLE',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _toggleCommonTemplate(true),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _isCommonTemplate ? AppColors.primaryLight : Colors.white,
                                borderRadius: AppSpacing.roundedSm,
                                border: Border.all(
                                  color: _isCommonTemplate ? AppColors.primary : AppColors.border,
                                  width: _isCommonTemplate ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.sync_rounded, size: 16, color: _isCommonTemplate ? AppColors.primary : AppColors.textSecondary),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Common Template',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: _isCommonTemplate ? AppColors.primary : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '1 weekly routine repeats across all ${_program.weeks.length} weeks',
                                    style: AppTypography.bodySmall.copyWith(fontSize: 10.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _toggleCommonTemplate(false),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: !_isCommonTemplate ? AppColors.primaryLight : Colors.white,
                                borderRadius: AppSpacing.roundedSm,
                                border: Border.all(
                                  color: !_isCommonTemplate ? AppColors.primary : AppColors.border,
                                  width: !_isCommonTemplate ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.view_week_rounded, size: 16, color: !_isCommonTemplate ? AppColors.primary : AppColors.textSecondary),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Week-by-Week',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: !_isCommonTemplate ? AppColors.primary : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Customize unique exercises and reps per week',
                                    style: AppTypography.bodySmall.copyWith(fontSize: 10.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // MULTI-WEEK TABS STRIP (+ Add Week Button)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Program Weeks (${_program.weeks.length})', style: AppTypography.headingSmall.copyWith(fontSize: 16)),
                  TextButton.icon(
                    onPressed: _addWeek,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Week', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _program.weeks.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final week = _program.weeks[i];
                    final isSelected = i == _selectedWeekIndex;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedWeekIndex = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Week ${week.weekNumber}',
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            if (!isSelected && _program.weeks.length > 1) ...[
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => _removeWeek(i),
                                child: const Icon(Icons.close_rounded, size: 14, color: AppColors.textMuted),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // SELECTED WEEK FOCUS BANNER
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: AppSpacing.roundedSm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, color: Colors.white70, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          currentWeek.focusTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Week ${currentWeek.weekNumber} of ${_program.weeks.length}',
                      style: const TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 7-DAY DAY SELECTOR (MON - SUN)
              SizedBox(
                height: 52,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(currentWeek.days.length, (dayIdx) {
                    final day = currentWeek.days[dayIdx];
                    final isSelected = dayIdx == _selectedDayIndex;
                    final isRest = day.isRestDay;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedDayIndex = dayIdx),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : isRest
                                    ? AppColors.surfaceMuted
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                              width: isSelected ? 1.6 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                day.dayOfWeek,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isRest ? 'REST' : '${day.exercises.length}ex',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white70
                                      : isRest
                                          ? AppColors.textMuted
                                          : AppColors.primary,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // DAY EDITOR CARD
              if (currentDay != null) ...[
                FitoraCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Toggle: Training Day vs. Rest Day
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${currentDay.dayName} Configuration',
                            style: AppTypography.headingSmall.copyWith(fontSize: 16),
                          ),
                          Row(
                            children: [
                              Text(
                                currentDay.isRestDay ? 'Rest Day' : 'Training Day',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: currentDay.isRestDay ? AppColors.textSecondary : AppColors.success,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Switch(
                                value: !currentDay.isRestDay,
                                activeThumbColor: AppColors.success,
                                onChanged: (val) {
                                  _updateSelectedDay(
                                    WorkoutDaySchedule(
                                      dayOfWeek: currentDay.dayOfWeek,
                                      dayName: currentDay.dayName,
                                      title: val ? 'Custom Training Session' : 'Active Recovery & Rest',
                                      targetMuscles: val ? 'Full Body' : 'Recovery',
                                      isRestDay: !val,
                                      estimatedMinutes: val ? 45 : 0,
                                      exercises: val ? currentDay.exercises : [],
                                      coachTip: currentDay.coachTip,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 20),

                      if (!currentDay.isRestDay) ...[
                        TextFormField(
                          initialValue: currentDay.title,
                          decoration: const InputDecoration(
                            labelText: 'Day Title',
                            hintText: 'e.g. Push: Chest & Delts',
                          ),
                          onChanged: (val) {
                            _updateSelectedDay(
                              WorkoutDaySchedule(
                                dayOfWeek: currentDay.dayOfWeek,
                                dayName: currentDay.dayName,
                                title: val,
                                targetMuscles: currentDay.targetMuscles,
                                isRestDay: false,
                                estimatedMinutes: currentDay.estimatedMinutes,
                                exercises: currentDay.exercises,
                                coachTip: currentDay.coachTip,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),

                        // Exercises List for this Day
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Exercises (${currentDay.exercises.length})', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                            TextButton.icon(
                              onPressed: () => _showAddExerciseDialog(currentDay),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add Exercise', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        if (currentDay.exercises.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: AppSpacing.roundedSm,
                            ),
                            child: const Text('No exercises added yet. Tap "Add Exercise" to select movements.'),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: currentDay.exercises.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, exIdx) {
                              final pEx = currentDay.exercises[exIdx];
                              return _buildConfigurableExerciseTile(currentDay, exIdx, pEx);
                            },
                          ),
                      ] else ...[
                        // Rest Day Info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: AppSpacing.roundedSm,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.bedtime_rounded, color: AppColors.textSecondary, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'This is designated as an active recovery day for muscle supercompensation and joint recovery.',
                                  style: AppTypography.bodySmall.copyWith(fontSize: 12),
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
              const SizedBox(height: 30),

              // Save & Activate Big Button
              FitoraButton(
                label: 'Save & Set as Active Program',
                icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                onPressed: _saveProgram,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigurableExerciseTile(
    WorkoutDaySchedule currentDay,
    int exIdx,
    PlanExercise pEx,
  ) {
    final name = pEx.exercise?.name ?? 'Exercise';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${exIdx + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(name, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                onPressed: () {
                  final updatedExList = List<PlanExercise>.from(currentDay.exercises)..removeAt(exIdx);
                  _updateSelectedDay(
                    WorkoutDaySchedule(
                      dayOfWeek: currentDay.dayOfWeek,
                      dayName: currentDay.dayName,
                      title: currentDay.title,
                      targetMuscles: currentDay.targetMuscles,
                      isRestDay: false,
                      estimatedMinutes: currentDay.estimatedMinutes,
                      exercises: updatedExList,
                      coachTip: currentDay.coachTip,
                    ),
                  );
                },
              ),
            ],
          ),
          const Divider(height: 14),

          // Stepper Controls: Sets, Reps, Weight
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Sets Stepper
              _buildStepper(
                label: 'SETS',
                value: '${pEx.targetSets}',
                onMinus: () {
                  if (pEx.targetSets > 1) {
                    _updateExerciseProperty(currentDay, exIdx, pEx.copyWith(targetSets: pEx.targetSets - 1));
                  }
                },
                onPlus: () {
                  _updateExerciseProperty(currentDay, exIdx, pEx.copyWith(targetSets: pEx.targetSets + 1));
                },
              ),
              // Reps Stepper
              _buildStepper(
                label: 'REPS',
                value: '${pEx.targetReps}',
                onMinus: () {
                  if (pEx.targetReps > 1) {
                    _updateExerciseProperty(currentDay, exIdx, pEx.copyWith(targetReps: pEx.targetReps - 1));
                  }
                },
                onPlus: () {
                  _updateExerciseProperty(currentDay, exIdx, pEx.copyWith(targetReps: pEx.targetReps + 1));
                },
              ),
              // Weight Stepper
              _buildStepper(
                label: 'KG',
                value: '${pEx.defaultWeightKg.round()}',
                onMinus: () {
                  if (pEx.defaultWeightKg >= 2.5) {
                    _updateExerciseProperty(currentDay, exIdx, pEx.copyWith(defaultWeightKg: pEx.defaultWeightKg - 2.5));
                  }
                },
                onPlus: () {
                  _updateExerciseProperty(currentDay, exIdx, pEx.copyWith(defaultWeightKg: pEx.defaultWeightKg + 2.5));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepper({
    required String label,
    required String value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Row(
          children: [
            InkWell(
              onTap: onMinus,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.remove, size: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            InkWell(
              onTap: onPlus,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.add, size: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _updateExerciseProperty(WorkoutDaySchedule currentDay, int exIdx, PlanExercise updatedEx) {
    final updatedList = List<PlanExercise>.from(currentDay.exercises);
    updatedList[exIdx] = updatedEx;

    _updateSelectedDay(
      WorkoutDaySchedule(
        dayOfWeek: currentDay.dayOfWeek,
        dayName: currentDay.dayName,
        title: currentDay.title,
        targetMuscles: currentDay.targetMuscles,
        isRestDay: false,
        estimatedMinutes: currentDay.estimatedMinutes,
        exercises: updatedList,
        coachTip: currentDay.coachTip,
      ),
    );
  }

  void _showAddExerciseDialog(WorkoutDaySchedule currentDay) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Select Movement to Add', style: AppTypography.headingSmall),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 10),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: SeedExercises.list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (c, i) {
                        final ex = SeedExercises.list[i];
                        return FitoraExerciseVisualTile(
                          exercise: ex,
                          index: i + 1,
                          onTap: () {
                            Navigator.pop(ctx);
                            final updatedList = List<PlanExercise>.from(currentDay.exercises)
                              ..add(
                                PlanExercise(
                                  exerciseId: ex.id,
                                  exercise: ex,
                                  orderIndex: currentDay.exercises.length,
                                  targetSets: ex.defaultSets,
                                  targetReps: ex.defaultReps,
                                  restSeconds: ex.restSeconds,
                                  defaultWeightKg: 20.0,
                                ),
                              );

                            _updateSelectedDay(
                              WorkoutDaySchedule(
                                dayOfWeek: currentDay.dayOfWeek,
                                dayName: currentDay.dayName,
                                title: currentDay.title,
                                targetMuscles: currentDay.targetMuscles,
                                isRestDay: false,
                                estimatedMinutes: currentDay.estimatedMinutes,
                                exercises: updatedList,
                                coachTip: currentDay.coachTip,
                              ),
                            );
                          },
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
