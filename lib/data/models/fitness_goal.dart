class FitnessGoal {
  final String id;
  final String userId;
  final String goalType; // fat_loss, muscle_gain, strength, endurance, maintenance
  final String experienceLevel; // beginner, intermediate, advanced
  final String activityLevel; // sedentary, lightly_active, moderately_active, very_active, extremely_active
  final int targetCalories;
  final int targetProteinG;
  final int targetCarbsG;
  final int targetFatG;
  final int targetWaterMl;
  final int targetSteps;

  const FitnessGoal({
    required this.id,
    required this.userId,
    this.goalType = 'fat_loss',
    this.experienceLevel = 'intermediate',
    this.activityLevel = 'moderately_active',
    required this.targetCalories,
    required this.targetProteinG,
    required this.targetCarbsG,
    required this.targetFatG,
    this.targetWaterMl = 3000,
    this.targetSteps = 10000,
  });

  String get goalDisplayName {
    switch (goalType) {
      case 'fat_loss':
        return 'Fat Loss';
      case 'muscle_gain':
        return 'Muscle Gain';
      case 'strength':
        return 'Strength & Power';
      case 'endurance':
        return 'Endurance';
      case 'maintenance':
      default:
        return 'Healthy Maintenance';
    }
  }

  String get experienceDisplayName {
    switch (experienceLevel) {
      case 'beginner':
        return 'Beginner';
      case 'advanced':
        return 'Advanced Athlete';
      case 'intermediate':
      default:
        return 'Intermediate';
    }
  }

  FitnessGoal copyWith({
    String? id,
    String? userId,
    String? goalType,
    String? experienceLevel,
    String? activityLevel,
    int? targetCalories,
    int? targetProteinG,
    int? targetCarbsG,
    int? targetFatG,
    int? targetWaterMl,
    int? targetSteps,
  }) {
    return FitnessGoal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goalType: goalType ?? this.goalType,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      activityLevel: activityLevel ?? this.activityLevel,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProteinG: targetProteinG ?? this.targetProteinG,
      targetCarbsG: targetCarbsG ?? this.targetCarbsG,
      targetFatG: targetFatG ?? this.targetFatG,
      targetWaterMl: targetWaterMl ?? this.targetWaterMl,
      targetSteps: targetSteps ?? this.targetSteps,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'goal_type': goalType,
      'experience_level': experienceLevel,
      'activity_level': activityLevel,
      'target_calories': targetCalories,
      'target_protein_g': targetProteinG,
      'target_carbs_g': targetCarbsG,
      'target_fat_g': targetFatG,
      'target_water_ml': targetWaterMl,
      'target_steps': targetSteps,
    };
  }

  factory FitnessGoal.fromJson(Map<String, dynamic> json) {
    return FitnessGoal(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      goalType: json['goal_type'] as String? ?? 'fat_loss',
      experienceLevel: json['experience_level'] as String? ?? 'intermediate',
      activityLevel: json['activity_level'] as String? ?? 'moderately_active',
      targetCalories: (json['target_calories'] as num?)?.toInt() ?? 2100,
      targetProteinG: (json['target_protein_g'] as num?)?.toInt() ?? 140,
      targetCarbsG: (json['target_carbs_g'] as num?)?.toInt() ?? 230,
      targetFatG: (json['target_fat_g'] as num?)?.toInt() ?? 65,
      targetWaterMl: (json['target_water_ml'] as num?)?.toInt() ?? 3000,
      targetSteps: (json['target_steps'] as num?)?.toInt() ?? 10000,
    );
  }
}
