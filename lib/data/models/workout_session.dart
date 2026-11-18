class WorkoutSetLog {
  final int setNumber;
  final String exerciseId;
  final String exerciseName;
  final double targetWeightKg;
  final double actualWeightKg;
  final int targetReps;
  final int actualReps;
  final bool isCompleted;
  final int restSeconds;

  const WorkoutSetLog({
    required this.setNumber,
    required this.exerciseId,
    required this.exerciseName,
    required this.targetWeightKg,
    required this.actualWeightKg,
    required this.targetReps,
    required this.actualReps,
    this.isCompleted = false,
    this.restSeconds = 90,
  });

  WorkoutSetLog copyWith({
    int? setNumber,
    String? exerciseId,
    String? exerciseName,
    double? targetWeightKg,
    double? actualWeightKg,
    int? targetReps,
    int? actualReps,
    bool? isCompleted,
    int? restSeconds,
  }) {
    return WorkoutSetLog(
      setNumber: setNumber ?? this.setNumber,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      actualWeightKg: actualWeightKg ?? this.actualWeightKg,
      targetReps: targetReps ?? this.targetReps,
      actualReps: actualReps ?? this.actualReps,
      isCompleted: isCompleted ?? this.isCompleted,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'set_number': setNumber,
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'target_weight_kg': targetWeightKg,
      'actual_weight_kg': actualWeightKg,
      'target_reps': targetReps,
      'actual_reps': actualReps,
      'is_completed': isCompleted,
      'rest_seconds': restSeconds,
    };
  }

  factory WorkoutSetLog.fromJson(Map<String, dynamic> json) {
    return WorkoutSetLog(
      setNumber: json['set_number'] as int? ?? 1,
      exerciseId: json['exercise_id'] as String? ?? '',
      exerciseName: json['exercise_name'] as String? ?? '',
      targetWeightKg: (json['target_weight_kg'] as num?)?.toDouble() ?? 0.0,
      actualWeightKg: (json['actual_weight_kg'] as num?)?.toDouble() ?? 0.0,
      targetReps: json['target_reps'] as int? ?? 10,
      actualReps: json['actual_reps'] as int? ?? 10,
      isCompleted: json['is_completed'] as bool? ?? false,
      restSeconds: json['rest_seconds'] as int? ?? 90,
    );
  }
}

class WorkoutSession {
  final String id;
  final String userId;
  final String? planId;
  final String workoutName;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int durationSeconds;
  final double totalVolumeKg;
  final int setsCompleted;
  final int exercisesCompleted;
  final String? notes;
  final List<WorkoutSetLog> sets;

  const WorkoutSession({
    required this.id,
    required this.userId,
    this.planId,
    required this.workoutName,
    required this.startedAt,
    this.completedAt,
    this.durationSeconds = 0,
    this.totalVolumeKg = 0.0,
    this.setsCompleted = 0,
    this.exercisesCompleted = 0,
    this.notes,
    this.sets = const [],
  });

  bool get isFinished => completedAt != null;

  WorkoutSession copyWith({
    String? id,
    String? userId,
    String? planId,
    String? workoutName,
    DateTime? startedAt,
    DateTime? completedAt,
    int? durationSeconds,
    double? totalVolumeKg,
    int? setsCompleted,
    int? exercisesCompleted,
    String? notes,
    List<WorkoutSetLog>? sets,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planId: planId ?? this.planId,
      workoutName: workoutName ?? this.workoutName,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      totalVolumeKg: totalVolumeKg ?? this.totalVolumeKg,
      setsCompleted: setsCompleted ?? this.setsCompleted,
      exercisesCompleted: exercisesCompleted ?? this.exercisesCompleted,
      notes: notes ?? this.notes,
      sets: sets ?? this.sets,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan_id': planId,
      'workout_name': workoutName,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'duration_seconds': durationSeconds,
      'total_volume_kg': totalVolumeKg,
      'sets_completed': setsCompleted,
      'exercises_completed': exercisesCompleted,
      'notes': notes,
      'sets': sets.map((s) => s.toJson()).toList(),
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    final rawSets = (json['sets'] as List<dynamic>?) ?? [];
    return WorkoutSession(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      planId: json['plan_id'] as String?,
      workoutName: json['workout_name'] as String? ?? 'Workout',
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      totalVolumeKg: (json['total_volume_kg'] as num?)?.toDouble() ?? 0.0,
      setsCompleted: json['sets_completed'] as int? ?? 0,
      exercisesCompleted: json['exercises_completed'] as int? ?? 0,
      notes: json['notes'] as String?,
      sets: rawSets.map((s) => WorkoutSetLog.fromJson(s as Map<String, dynamic>)).toList(),
    );
  }
}
