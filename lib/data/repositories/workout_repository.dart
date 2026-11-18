import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/supabase_service.dart';
import '../models/exercise.dart';
import '../models/workout_plan.dart';
import '../models/workout_session.dart';
import '../seed/seed_exercises.dart';
import '../seed/seed_workout_plans.dart';

class WorkoutRepository {
  List<Exercise> _exercises = [];
  List<WorkoutPlan> _customPlans = [];
  List<WorkoutSession> _sessions = [];
  MultiWeekProgram? _activeProgram;

  WorkoutRepository() {
    _loadLocalCache();
  }

  void _loadLocalCache() {
    _exercises = List.from(SeedExercises.list);

    // Load custom plans
    final storedPlans = StorageService.getJson('fitora_custom_workout_plans');
    if (storedPlans is List) {
      _customPlans = storedPlans
          .map((p) => WorkoutPlan.fromJson(p as Map<String, dynamic>, _exercises))
          .toList();
    }

    // Load sessions
    final storedSessions = StorageService.getJson('fitora_workout_sessions');
    if (storedSessions is List) {
      _sessions = storedSessions
          .map((s) => WorkoutSession.fromJson(s as Map<String, dynamic>))
          .toList();
    }

    // Load active multi-week program
    final storedProgram = StorageService.getJson('fitora_active_multi_week_program');
    if (storedProgram is Map<String, dynamic>) {
      _activeProgram = MultiWeekProgram.fromJson(storedProgram, _exercises);
    } else {
      _activeProgram = _createDefaultMultiWeekProgram();
    }
  }

  MultiWeekProgram _createDefaultMultiWeekProgram() {
    final templates = SeedWorkoutPlans.templates;
    final basePlan = templates.isNotEmpty ? templates.first : null;
    final defaultSchedule = basePlan?.weeklySchedule ?? [];

    final weeks = List.generate(4, (i) {
      final weekNum = i + 1;
      String focus;
      if (weekNum == 1) {
        focus = 'Foundation & Movement Patterns';
      } else if (weekNum == 2) {
        focus = 'Volume Accumulation';
      } else if (weekNum == 3) {
        focus = 'Overload & Mechanical Tension';
      } else {
        focus = 'Peak Intensity & Testing';
      }
      return ProgramWeek(
        weekNumber: weekNum,
        focusTitle: focus,
        days: defaultSchedule,
      );
    });

    return MultiWeekProgram(
      id: 'default_hypertrophy_4w',
      title: '4-Week Hypertrophy & Muscle Mass Cycle',
      description: 'Periodized 5-day Upper/Lower & PPL split designed for maximum myofibrillar growth.',
      goalType: 'muscle_gain',
      goalDisplayName: 'Muscle Hypertrophy & Mass',
      totalWeeks: 4,
      isCommonTemplate: true,
      weeks: weeks,
      createdAt: DateTime.now(),
      activatedAt: DateTime.now(),
    );
  }

  MultiWeekProgram getActiveMultiWeekProgram() {
    return _activeProgram ?? _createDefaultMultiWeekProgram();
  }

  Future<void> saveActiveMultiWeekProgram(MultiWeekProgram program) async {
    _activeProgram = program;
    await StorageService.setJson(
      'fitora_active_multi_week_program',
      program.toJson(),
    );
  }

  Future<List<Exercise>> getExercises({String? category, String? query}) async {
    return _exercises.where((e) {
      final matchesCategory = category == null ||
          category.isEmpty ||
          category == 'all' ||
          e.category.toLowerCase() == category.toLowerCase();
      final matchesQuery = query == null ||
          query.isEmpty ||
          e.name.toLowerCase().contains(query.toLowerCase()) ||
          e.targetMuscle.toLowerCase().contains(query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  Exercise? getExerciseById(String id) {
    try {
      return _exercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  List<WorkoutPlan> getAllPlans() {
    return [
      ...SeedWorkoutPlans.templates,
      ..._customPlans,
    ];
  }

  Future<void> saveCustomPlan(WorkoutPlan plan) async {
    final index = _customPlans.indexWhere((p) => p.id == plan.id);
    if (index >= 0) {
      _customPlans[index] = plan;
    } else {
      _customPlans.add(plan);
    }
    await StorageService.setJson(
      'fitora_custom_workout_plans',
      _customPlans.map((p) => p.toJson()).toList(),
    );

    if (!SupabaseService.isOfflineMode && SupabaseService.client != null) {
      try {
        await SupabaseService.client!.from('workout_plans').upsert(plan.toJson());
      } catch (e) {
        debugPrint('[WorkoutRepository] Save custom plan to Supabase error: $e');
      }
    }
  }

  List<WorkoutSession> getWorkoutSessions() {
    _sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return _sessions;
  }

  Future<void> saveWorkoutSession(WorkoutSession session) async {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index >= 0) {
      _sessions[index] = session;
    } else {
      _sessions.insert(0, session);
    }

    await StorageService.setJson(
      'fitora_workout_sessions',
      _sessions.map((s) => s.toJson()).toList(),
    );

    if (!SupabaseService.isOfflineMode && SupabaseService.client != null) {
      try {
        await SupabaseService.client!.from('workout_sessions').upsert(session.toJson());
      } catch (e) {
        debugPrint('[WorkoutRepository] Save session to Supabase error: $e');
      }
    }
  }

  WorkoutSession createSessionFromPlan(WorkoutPlan plan, String userId) {
    final sets = <WorkoutSetLog>[];

    for (var planEx in plan.exercises) {
      final exName = planEx.exercise?.name ?? 'Exercise';
      for (int i = 1; i <= planEx.targetSets; i++) {
        sets.add(
          WorkoutSetLog(
            setNumber: i,
            exerciseId: planEx.exerciseId,
            exerciseName: exName,
            targetWeightKg: planEx.defaultWeightKg,
            actualWeightKg: planEx.defaultWeightKg,
            targetReps: planEx.targetReps,
            actualReps: planEx.targetReps,
            isCompleted: false,
            restSeconds: planEx.restSeconds,
          ),
        );
      }
    }

    return WorkoutSession(
      id: const Uuid().v4(),
      userId: userId,
      planId: plan.id,
      workoutName: plan.title,
      startedAt: DateTime.now(),
      sets: sets,
    );
  }
}
