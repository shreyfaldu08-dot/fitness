import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/fitora_button.dart';
import '../../../core/widgets/fitora_muscle_badge.dart';
import '../../../core/widgets/fitora_muscle_illustration.dart';
import '../../../data/models/workout_plan.dart';
import '../../../data/models/workout_session.dart';
import '../../../data/seed/seed_exercises.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final WorkoutPlan? plan;

  const ActiveWorkoutScreen({
    super.key,
    this.plan,
  });

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  // Overall Workout Stopwatch
  late Timer _workoutTimer;
  int _elapsedSeconds = 0;
  bool _isPaused = false;

  // Rest Interval Countdown Timer
  Timer? _restTimer;
  int _restRemainingSeconds = 0;
  bool _isResting = false;

  late WorkoutSession _session;
  int _currentExerciseIndex = 0;

  @override
  void initState() {
    super.initState();
    _initSession();
    _startStopwatch();
  }

  void _initSession() {
    final workoutRepo = ref.read(workoutRepositoryProvider);
    if (widget.plan != null) {
      _session = workoutRepo.createSessionFromPlan(widget.plan!, 'athlete_1');
    } else {
      // Default blank workout with 2 foundational compound lifts
      final ex1 = SeedExercises.list[0];
      final ex2 = SeedExercises.list[5];
      final quickPlan = WorkoutPlan(
        id: 'quick_custom',
        title: 'Open Strength Session',
        description: 'Self-guided resistance session.',
        exercises: [
          PlanExercise(exerciseId: ex1.id, exercise: ex1, orderIndex: 0, targetSets: 3, targetReps: 10, defaultWeightKg: 40),
          PlanExercise(exerciseId: ex2.id, exercise: ex2, orderIndex: 1, targetSets: 3, targetReps: 10, defaultWeightKg: 45),
        ],
      );
      _session = workoutRepo.createSessionFromPlan(quickPlan, 'athlete_1');
    }
  }

  void _startStopwatch() {
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _startRestTimer(int durationSeconds) {
    _restTimer?.cancel();
    setState(() {
      _isResting = true;
      _restRemainingSeconds = durationSeconds;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_restRemainingSeconds > 0) {
          setState(() {
            _restRemainingSeconds--;
          });
        } else {
          _cancelRestTimer();
        }
      }
    });
  }

  void _cancelRestTimer() {
    _restTimer?.cancel();
    if (mounted) {
      setState(() {
        _isResting = false;
        _restRemainingSeconds = 0;
      });
    }
  }

  void _toggleSetCompletion(int globalSetIndex) {
    final set = _session.sets[globalSetIndex];
    final updated = set.copyWith(isCompleted: !set.isCompleted);

    final updatedSets = List<WorkoutSetLog>.from(_session.sets);
    updatedSets[globalSetIndex] = updated;

    setState(() {
      _session = _session.copyWith(sets: updatedSets);
    });

    if (updated.isCompleted) {
      _startRestTimer(updated.restSeconds);
    }
  }

  void _updateSetMetrics(int globalSetIndex, {double? weight, int? reps}) {
    final set = _session.sets[globalSetIndex];
    final updated = set.copyWith(
      actualWeightKg: weight ?? set.actualWeightKg,
      actualReps: reps ?? set.actualReps,
    );
    final updatedSets = List<WorkoutSetLog>.from(_session.sets);
    updatedSets[globalSetIndex] = updated;

    setState(() {
      _session = _session.copyWith(sets: updatedSets);
    });
  }

  Future<void> _finishWorkout() async {
    _workoutTimer.cancel();
    _restTimer?.cancel();

    // Calculate total volume (sum of weight * reps for completed sets)
    double totalVolume = 0;
    int completedSetsCount = 0;
    final completedExercises = <String>{};

    for (var s in _session.sets) {
      if (s.isCompleted) {
        totalVolume += (s.actualWeightKg * s.actualReps);
        completedSetsCount++;
        completedExercises.add(s.exerciseId);
      }
    }

    final finishedSession = _session.copyWith(
      completedAt: DateTime.now(),
      durationSeconds: _elapsedSeconds,
      totalVolumeKg: totalVolume,
      setsCompleted: completedSetsCount,
      exercisesCompleted: completedExercises.length,
    );

    final workoutRepo = ref.read(workoutRepositoryProvider);
    await workoutRepo.saveWorkoutSession(finishedSession);

    // Update today's activity stats
    final activeMinutes = (_elapsedSeconds / 60).round();
    await ref.read(todayActivityProvider.notifier).addActiveMinutes(activeMinutes);

    if (mounted) {
      _showCompletionDialog(finishedSession);
    }
  }

  void _showCompletionDialog(WorkoutSession session) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedLg),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events_rounded, color: AppColors.success, size: 40),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Workout Complete!', style: AppTypography.headingMedium),
              const SizedBox(height: 4),
              Text(session.workoutName, style: AppTypography.bodySmall),
              const SizedBox(height: AppSpacing.lg),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatSummary('Duration', DateFormatter.formatDuration(session.durationSeconds)),
                  _buildStatSummary('Total Volume', '${session.totalVolumeKg.round()} kg'),
                  _buildStatSummary('Sets Logged', '${session.setsCompleted}'),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              FitoraButton(
                label: 'Save & Return to Dashboard',
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatSummary(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.labelSmall),
      ],
    );
  }

  @override
  void dispose() {
    _workoutTimer.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Unique exercises in this session
    final exerciseNames = <String>[];
    for (var s in _session.sets) {
      if (!exerciseNames.contains(s.exerciseName)) {
        exerciseNames.add(s.exerciseName);
      }
    }

    final activeExName = exerciseNames.isNotEmpty
        ? exerciseNames[_currentExerciseIndex.clamp(0, exerciseNames.length - 1)]
        : 'Exercise';

    final activeSets = _session.sets.asMap().entries.where((entry) => entry.value.exerciseName == activeExName).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_session.workoutName, style: AppTypography.labelLarge),
            Text(
              DateFormatter.formatDuration(_elapsedSeconds),
              style: AppTypography.statUnit.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
            onPressed: () => setState(() => _isPaused = !_isPaused),
          ),
          TextButton(
            onPressed: _finishWorkout,
            child: Text(
              'Finish',
              style: AppTypography.labelMedium.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // REST TIMER BANNER (when active)
            if (_isResting) _buildRestTimerBanner(),

            // Exercise Tabs Selector
            SizedBox(
              height: 46,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: exerciseNames.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isCurrent = _currentExerciseIndex == index;
                  return ChoiceChip(
                    label: Text(exerciseNames[index]),
                    selected: isCurrent,
                    onSelected: (_) => setState(() => _currentExerciseIndex = index),
                    selectedColor: AppColors.primaryLight,
                    labelStyle: TextStyle(
                      color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                },
              ),
            ),

            // Exercise Demonstration & Instruction Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppSpacing.roundedMd,
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Row(
                  children: [
                    // Dynamic Anatomical Target Highlight
                    FitoraMuscleIllustration(
                      muscle: activeExName,
                      width: 56,
                      height: 70,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(activeExName, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          FitoraMuscleBadge(muscle: activeExName),
                          const SizedBox(height: 4),
                          Text(
                            'Maintain rigid posture, controlled 3s tempo, full range of motion.',
                            style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Table Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  const SizedBox(width: 36, child: Text('SET', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  Expanded(flex: 3, child: Center(child: Text('WEIGHT (KG)', style: AppTypography.labelSmall.copyWith(fontSize: 11, fontWeight: FontWeight.bold)))),
                  Expanded(flex: 3, child: Center(child: Text('REPS', style: AppTypography.labelSmall.copyWith(fontSize: 11, fontWeight: FontWeight.bold)))),
                  const SizedBox(width: 44, child: Center(child: Text('DONE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)))),
                ],
              ),
            ),

            // Interactive Set Rows
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: activeSets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final entry = activeSets[index];
                  final globalIndex = entry.key;
                  final set = entry.value;

                  return _buildSetRow(globalIndex, set);
                },
              ),
            ),

            // Bottom Navigation between exercises
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: _currentExerciseIndex > 0
                        ? () => setState(() => _currentExerciseIndex--)
                        : null,
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
                    label: const Text('Previous'),
                  ),
                  if (_currentExerciseIndex < exerciseNames.length - 1)
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _currentExerciseIndex++),
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      label: const Text('Next Exercise'),
                    )
                  else
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                      onPressed: _finishWorkout,
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Finish Workout'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestTimerBanner() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'REST TIMER: ${DateFormatter.formatDuration(_restRemainingSeconds)}',
                style: AppTypography.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => setState(() => _restRemainingSeconds += 30),
                child: const Text('+30s', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                onPressed: _cancelRestTimer,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(int globalIndex, WorkoutSetLog set) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: set.isCompleted ? AppColors.successLight : Colors.white,
        borderRadius: AppSpacing.roundedSm,
        border: Border.all(
          color: set.isCompleted ? AppColors.success : AppColors.border,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // Set #
          SizedBox(
            width: 32,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: set.isCompleted ? AppColors.success : AppColors.surfaceMuted,
              child: Text(
                '${set.setNumber}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: set.isCompleted ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Weight Controller
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => _updateSetMetrics(globalIndex, weight: (set.actualWeightKg - 2.5).clamp(0.0, 500.0)),
                  child: const Icon(Icons.remove_circle_outline, size: 22, color: AppColors.textSecondary),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${set.actualWeightKg}',
                    style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                InkWell(
                  onTap: () => _updateSetMetrics(globalIndex, weight: set.actualWeightKg + 2.5),
                  child: const Icon(Icons.add_circle_outline, size: 22, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // Reps Controller
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => _updateSetMetrics(globalIndex, reps: (set.actualReps - 1).clamp(1, 100)),
                  child: const Icon(Icons.remove_circle_outline, size: 22, color: AppColors.textSecondary),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${set.actualReps}',
                    style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                InkWell(
                  onTap: () => _updateSetMetrics(globalIndex, reps: set.actualReps + 1),
                  child: const Icon(Icons.add_circle_outline, size: 22, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // Done Checkmark
          SizedBox(
            width: 44,
            child: IconButton(
              icon: Icon(
                set.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: set.isCompleted ? AppColors.success : AppColors.borderDark,
                size: 26,
              ),
              onPressed: () => _toggleSetCompletion(globalIndex),
            ),
          ),
        ],
      ),
    );
  }
}
