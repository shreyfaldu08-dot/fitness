import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'exercise.dart';

class PlanExercise {
  final String exerciseId;
  final Exercise? exercise;
  final int orderIndex;
  final int targetSets;
  final int targetReps;
  final int restSeconds;
  final double defaultWeightKg;

  const PlanExercise({
    required this.exerciseId,
    this.exercise,
    required this.orderIndex,
    this.targetSets = 3,
    this.targetReps = 10,
    this.restSeconds = 90,
    this.defaultWeightKg = 20.0,
  });

  PlanExercise copyWith({
    String? exerciseId,
    Exercise? exercise,
    int? orderIndex,
    int? targetSets,
    int? targetReps,
    int? restSeconds,
    double? defaultWeightKg,
  }) {
    return PlanExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      exercise: exercise ?? this.exercise,
      orderIndex: orderIndex ?? this.orderIndex,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      restSeconds: restSeconds ?? this.restSeconds,
      defaultWeightKg: defaultWeightKg ?? this.defaultWeightKg,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise_id': exerciseId,
      'order_index': orderIndex,
      'target_sets': targetSets,
      'target_reps': targetReps,
      'rest_seconds': restSeconds,
      'default_weight_kg': defaultWeightKg,
    };
  }

  factory PlanExercise.fromJson(Map<String, dynamic> json, [Exercise? exercise]) {
    return PlanExercise(
      exerciseId: json['exercise_id'] as String? ?? '',
      exercise: exercise,
      orderIndex: json['order_index'] as int? ?? 0,
      targetSets: json['target_sets'] as int? ?? 3,
      targetReps: json['target_reps'] as int? ?? 10,
      restSeconds: json['rest_seconds'] as int? ?? 90,
      defaultWeightKg: (json['default_weight_kg'] as num?)?.toDouble() ?? 20.0,
    );
  }
}

/// Professional Day Schedule in a Weekly Workout Split
class WorkoutDaySchedule {
  final String dayOfWeek; // 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'
  final String dayName; // 'Monday', 'Tuesday', etc.
  final String title; // 'Push Day: Chest, Shoulders & Triceps'
  final String targetMuscles; // 'Chest, Anterior Deltoids, Triceps'
  final bool isRestDay;
  final int estimatedMinutes;
  final String intensity; // 'High', 'Moderate', 'Light', 'Recovery'
  final List<PlanExercise> exercises;
  final String coachTip;
  final String cardioGuidance;

  const WorkoutDaySchedule({
    required this.dayOfWeek,
    required this.dayName,
    required this.title,
    required this.targetMuscles,
    this.isRestDay = false,
    this.estimatedMinutes = 45,
    this.intensity = 'Moderate',
    this.exercises = const [],
    this.coachTip = 'Focus on controlled form and full range of motion.',
    this.cardioGuidance = 'Optional: 15-20 min Zone 2 cooldown walk.',
  });

  Map<String, dynamic> toJson() {
    return {
      'day_of_week': dayOfWeek,
      'day_name': dayName,
      'title': title,
      'target_muscles': targetMuscles,
      'is_rest_day': isRestDay,
      'estimated_minutes': estimatedMinutes,
      'intensity': intensity,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'coach_tip': coachTip,
      'cardio_guidance': cardioGuidance,
    };
  }

  factory WorkoutDaySchedule.fromJson(Map<String, dynamic> json, [List<Exercise>? catalog]) {
    final rawExercises = (json['exercises'] as List<dynamic>?) ?? [];
    final parsed = rawExercises.map((e) {
      final map = e as Map<String, dynamic>;
      final exId = map['exercise_id'] as String? ?? '';
      Exercise? found;
      if (catalog != null) {
        try {
          found = catalog.firstWhere((x) => x.id == exId);
        } catch (_) {}
      }
      return PlanExercise.fromJson(map, found);
    }).toList();

    return WorkoutDaySchedule(
      dayOfWeek: json['day_of_week'] as String? ?? 'MON',
      dayName: json['day_name'] as String? ?? 'Monday',
      title: json['title'] as String? ?? 'Training Session',
      targetMuscles: json['target_muscles'] as String? ?? 'Full Body',
      isRestDay: json['is_rest_day'] as bool? ?? false,
      estimatedMinutes: json['estimated_minutes'] as int? ?? 45,
      intensity: json['intensity'] as String? ?? 'Moderate',
      exercises: parsed,
      coachTip: json['coach_tip'] as String? ?? 'Maintain consistent tempo.',
      cardioGuidance: json['cardio_guidance'] as String? ?? '20 min brisk walking.',
    );
  }
}

/// S&C Professional Advisory Protocol
class ProfessionalCoachingAdvice {
  final String targetRpe; // e.g. "RPE 8.0 - 9.0 (1-2 Reps in Reserve)"
  final String restProtocol; // e.g. "90 - 120s between compound movements"
  final String progressionRule; // e.g. "Double Progression: Hit top of rep target on all sets, then add 2.5 kg"
  final String nutritionSynergy; // e.g. "+350 to +500 kcal surplus • 1.8-2.2g/kg protein"
  final String cardioGuidance; // e.g. "8,000-10,000 daily steps + 20 min Zone 2 twice weekly"
  final String coachTip; // e.g. "Hypertrophy requires consistent mechanical tension and progressive overload."

  const ProfessionalCoachingAdvice({
    this.targetRpe = 'RPE 7.5 - 8.5 (1-2 Reps in Reserve)',
    this.restProtocol = '60 - 90s between sets',
    this.progressionRule = 'Add 1 rep each session or increase weight by 2.5% once upper rep limit is achieved.',
    this.nutritionSynergy = 'Adequate protein (1.8-2.2g/kg bodyweight) and hydrated glycogen stores.',
    this.cardioGuidance = '8,000-10,000 daily steps for cardiovascular baseline.',
    this.coachTip = 'Emphasize controlled eccentric tempo (3 seconds down) for maximal muscle stimulus.',
  });

  Map<String, dynamic> toJson() {
    return {
      'target_rpe': targetRpe,
      'rest_protocol': restProtocol,
      'progression_rule': progressionRule,
      'nutrition_synergy': nutritionSynergy,
      'cardio_guidance': cardioGuidance,
      'coach_tip': coachTip,
    };
  }

  factory ProfessionalCoachingAdvice.fromJson(Map<String, dynamic> json) {
    return ProfessionalCoachingAdvice(
      targetRpe: json['target_rpe'] as String? ?? 'RPE 7.5 - 8.5',
      restProtocol: json['rest_protocol'] as String? ?? '60 - 90s',
      progressionRule: json['progression_rule'] as String? ?? 'Progressive overload.',
      nutritionSynergy: json['nutrition_synergy'] as String? ?? 'Balanced nutrition.',
      cardioGuidance: json['cardio_guidance'] as String? ?? '8,000 daily steps.',
      coachTip: json['coach_tip'] as String? ?? 'Focus on form.',
    );
  }
}

class WorkoutPlan {
  final String id;
  final String? userId; // null if predefined template
  final String title;
  final String description;
  final String level; // beginner, intermediate, advanced
  final int daysPerWeek;
  final int estimatedDurationMinutes;
  final List<PlanExercise> exercises;
  final bool isTemplate;
  final DateTime? createdAt;

  // Professional Goal & Weekly Split Extensions
  final String goalType; // 'muscle_gain', 'fat_loss', 'strength', 'recomposition', 'calisthenics'
  final String goalDisplayName;
  final String splitType; // e.g. '5-Day Push/Pull/Legs', '4-Day Metabolic Density'
  final List<WorkoutDaySchedule> weeklySchedule;
  final ProfessionalCoachingAdvice coachingAdvice;

  const WorkoutPlan({
    required this.id,
    this.userId,
    required this.title,
    required this.description,
    this.level = 'intermediate',
    this.daysPerWeek = 4,
    this.estimatedDurationMinutes = 45,
    required this.exercises,
    this.isTemplate = false,
    this.createdAt,
    this.goalType = 'muscle_gain',
    this.goalDisplayName = 'Muscle Hypertrophy & Mass',
    this.splitType = '4-Day Split Routine',
    this.weeklySchedule = const [],
    this.coachingAdvice = const ProfessionalCoachingAdvice(),
  });

  String get category {
    final lower = title.toLowerCase();
    if (lower.contains('chest') || lower.contains('push')) return 'Chest';
    if (lower.contains('back') || lower.contains('pull')) return 'Back';
    if (lower.contains('leg') || lower.contains('lower')) return 'Legs';
    if (lower.contains('shoulder')) return 'Shoulders';
    if (lower.contains('arm') || lower.contains('bicep')) return 'Arms';
    if (lower.contains('core') || lower.contains('ab')) return 'Abs';
    return 'Full Body';
  }

  String get difficulty => level;

  Color get goalBadgeColor {
    switch (goalType.toLowerCase()) {
      case 'muscle_gain':
        return const Color(0xFF8B5CF6); // Vibrant Purple / Violet
      case 'fat_loss':
        return const Color(0xFFEF4444); // Vivid Coral Red
      case 'strength':
        return const Color(0xFFF59E0B); // Electric Amber
      case 'recomposition':
        return const Color(0xFF10B981); // Emerald Green
      case 'calisthenics':
        return const Color(0xFF06B6D4); // Cyan / Ocean Blue
      default:
        return AppColors.primary;
    }
  }

  IconData get goalIcon {
    switch (goalType.toLowerCase()) {
      case 'muscle_gain':
        return Icons.fitness_center_rounded;
      case 'fat_loss':
        return Icons.local_fire_department_rounded;
      case 'strength':
        return Icons.offline_bolt_rounded;
      case 'recomposition':
        return Icons.auto_awesome_rounded;
      case 'calisthenics':
        return Icons.accessibility_new_rounded;
      default:
        return Icons.sports_gymnastics_rounded;
    }
  }

  WorkoutPlan copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? level,
    int? daysPerWeek,
    int? estimatedDurationMinutes,
    List<PlanExercise>? exercises,
    bool? isTemplate,
    DateTime? createdAt,
    String? goalType,
    String? goalDisplayName,
    String? splitType,
    List<WorkoutDaySchedule>? weeklySchedule,
    ProfessionalCoachingAdvice? coachingAdvice,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      level: level ?? this.level,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      exercises: exercises ?? this.exercises,
      isTemplate: isTemplate ?? this.isTemplate,
      createdAt: createdAt ?? this.createdAt,
      goalType: goalType ?? this.goalType,
      goalDisplayName: goalDisplayName ?? this.goalDisplayName,
      splitType: splitType ?? this.splitType,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
      coachingAdvice: coachingAdvice ?? this.coachingAdvice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'level': level,
      'days_per_week': daysPerWeek,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'is_template': isTemplate,
      'created_at': createdAt?.toIso8601String(),
      'goal_type': goalType,
      'goal_display_name': goalDisplayName,
      'split_type': splitType,
      'weekly_schedule': weeklySchedule.map((s) => s.toJson()).toList(),
      'coaching_advice': coachingAdvice.toJson(),
    };
  }

  factory WorkoutPlan.fromJson(Map<String, dynamic> json, [List<Exercise>? catalogExercises]) {
    final rawExercises = (json['exercises'] as List<dynamic>?) ?? [];
    final parsedExercises = rawExercises.map((e) {
      final map = e as Map<String, dynamic>;
      final exId = map['exercise_id'] as String? ?? '';
      Exercise? found;
      if (catalogExercises != null) {
        try {
          found = catalogExercises.firstWhere((x) => x.id == exId);
        } catch (_) {}
      }
      return PlanExercise.fromJson(map, found);
    }).toList();

    final rawSchedule = (json['weekly_schedule'] as List<dynamic>?) ?? [];
    final parsedSchedule = rawSchedule
        .map((s) => WorkoutDaySchedule.fromJson(s as Map<String, dynamic>, catalogExercises))
        .toList();

    final rawCoaching = json['coaching_advice'];
    final parsedCoaching = rawCoaching is Map<String, dynamic>
        ? ProfessionalCoachingAdvice.fromJson(rawCoaching)
        : const ProfessionalCoachingAdvice();

    return WorkoutPlan(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      level: json['level'] as String? ?? 'intermediate',
      daysPerWeek: json['days_per_week'] as int? ?? 4,
      estimatedDurationMinutes: json['estimated_duration_minutes'] as int? ?? 45,
      exercises: parsedExercises,
      isTemplate: json['is_template'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      goalType: json['goal_type'] as String? ?? 'muscle_gain',
      goalDisplayName: json['goal_display_name'] as String? ?? 'Muscle Hypertrophy & Mass',
      splitType: json['split_type'] as String? ?? '4-Day Split Routine',
      weeklySchedule: parsedSchedule,
      coachingAdvice: parsedCoaching,
    );
  }
}

/// A Single Week in a Multi-Week Periodized Training Program
class ProgramWeek {
  final int weekNumber;
  final String focusTitle;
  final List<WorkoutDaySchedule> days;

  const ProgramWeek({
    required this.weekNumber,
    required this.focusTitle,
    required this.days,
  });

  ProgramWeek copyWith({
    int? weekNumber,
    String? focusTitle,
    List<WorkoutDaySchedule>? days,
  }) {
    return ProgramWeek(
      weekNumber: weekNumber ?? this.weekNumber,
      focusTitle: focusTitle ?? this.focusTitle,
      days: days ?? this.days,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week_number': weekNumber,
      'focus_title': focusTitle,
      'days': days.map((d) => d.toJson()).toList(),
    };
  }

  factory ProgramWeek.fromJson(Map<String, dynamic> json, [List<Exercise>? catalog]) {
    final rawDays = (json['days'] as List<dynamic>?) ?? [];
    final parsedDays = rawDays
        .map((d) => WorkoutDaySchedule.fromJson(d as Map<String, dynamic>, catalog))
        .toList();

    return ProgramWeek(
      weekNumber: json['week_number'] as int? ?? 1,
      focusTitle: json['focus_title'] as String? ?? 'Training Week',
      days: parsedDays,
    );
  }
}

/// A Complete Multi-Week Customized or Common Periodized Program
class MultiWeekProgram {
  final String id;
  final String title;
  final String description;
  final String goalType;
  final String goalDisplayName;
  final int totalWeeks;
  final bool isCommonTemplate;
  final List<ProgramWeek> weeks;
  final DateTime createdAt;
  final DateTime? activatedAt;

  const MultiWeekProgram({
    required this.id,
    required this.title,
    required this.description,
    this.goalType = 'muscle_gain',
    this.goalDisplayName = 'Muscle Hypertrophy & Mass',
    this.totalWeeks = 4,
    this.isCommonTemplate = true,
    required this.weeks,
    required this.createdAt,
    this.activatedAt,
  });

  int get currentWeekNumber {
    if (activatedAt == null || weeks.isEmpty) return 1;
    final daysSinceStart = DateTime.now().difference(activatedAt!).inDays;
    final week = (daysSinceStart ~/ 7) + 1;
    return week.clamp(1, totalWeeks);
  }

  ProgramWeek get currentWeek {
    final curNum = currentWeekNumber;
    return weeks.firstWhere(
      (w) => w.weekNumber == curNum,
      orElse: () => weeks.isNotEmpty ? weeks.first : const ProgramWeek(weekNumber: 1, focusTitle: 'Foundation', days: []),
    );
  }

  WorkoutDaySchedule? getTodaySchedule() {
    final curWeek = currentWeek;
    if (curWeek.days.isEmpty) return null;
    final weekday = DateTime.now().weekday;
    final dayIndex = (weekday - 1).clamp(0, curWeek.days.length - 1);
    return curWeek.days[dayIndex];
  }

  MultiWeekProgram copyWith({
    String? id,
    String? title,
    String? description,
    String? goalType,
    String? goalDisplayName,
    int? totalWeeks,
    bool? isCommonTemplate,
    List<ProgramWeek>? weeks,
    DateTime? createdAt,
    DateTime? activatedAt,
  }) {
    return MultiWeekProgram(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      goalType: goalType ?? this.goalType,
      goalDisplayName: goalDisplayName ?? this.goalDisplayName,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      isCommonTemplate: isCommonTemplate ?? this.isCommonTemplate,
      weeks: weeks ?? this.weeks,
      createdAt: createdAt ?? this.createdAt,
      activatedAt: activatedAt ?? this.activatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'goal_type': goalType,
      'goal_display_name': goalDisplayName,
      'total_weeks': totalWeeks,
      'is_common_template': isCommonTemplate,
      'weeks': weeks.map((w) => w.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'activated_at': activatedAt?.toIso8601String(),
    };
  }

  factory MultiWeekProgram.fromJson(Map<String, dynamic> json, [List<Exercise>? catalog]) {
    final rawWeeks = (json['weeks'] as List<dynamic>?) ?? [];
    final parsedWeeks = rawWeeks
        .map((w) => ProgramWeek.fromJson(w as Map<String, dynamic>, catalog))
        .toList();

    return MultiWeekProgram(
      id: json['id'] as String? ?? 'mwp_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Custom Multi-Week Program',
      description: json['description'] as String? ?? 'Personalized periodized training.',
      goalType: json['goal_type'] as String? ?? 'muscle_gain',
      goalDisplayName: json['goal_display_name'] as String? ?? 'Muscle Hypertrophy',
      totalWeeks: json['total_weeks'] as int? ?? 4,
      isCommonTemplate: json['is_common_template'] as bool? ?? true,
      weeks: parsedWeeks,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      activatedAt: json['activated_at'] != null
          ? DateTime.tryParse(json['activated_at'] as String)
          : null,
    );
  }
}
