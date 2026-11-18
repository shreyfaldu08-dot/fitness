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
  });

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
    );
  }
}
