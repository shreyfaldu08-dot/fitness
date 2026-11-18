class Exercise {
  final String id;
  final String name;
  final String category; // chest, back, shoulders, biceps, triceps, legs, abs, cardio, full_body
  final String targetMuscle;
  final List<String> secondaryMuscles;
  final String equipment; // barbell, dumbbell, machine, cable, bodyweight, kettlebell, cardio
  final String difficulty; // beginner, intermediate, advanced
  final String instructions;
  final int defaultSets;
  final int defaultReps;
  final int restSeconds;
  final String safetyGuidance;
  final String imageUrl;

  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.targetMuscle,
    this.secondaryMuscles = const [],
    required this.equipment,
    this.difficulty = 'intermediate',
    required this.instructions,
    this.defaultSets = 3,
    this.defaultReps = 10,
    this.restSeconds = 90,
    required this.safetyGuidance,
    this.imageUrl = '',
  });

  String get categoryDisplayName {
    switch (category) {
      case 'chest':
        return 'Chest';
      case 'back':
        return 'Back';
      case 'shoulders':
        return 'Shoulders';
      case 'biceps':
        return 'Biceps';
      case 'triceps':
        return 'Triceps';
      case 'legs':
        return 'Legs & Glutes';
      case 'abs':
        return 'Abs & Core';
      case 'cardio':
        return 'Cardio';
      case 'full_body':
      default:
        return 'Full Body';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'target_muscle': targetMuscle,
      'secondary_muscles': secondaryMuscles,
      'equipment': equipment,
      'difficulty': difficulty,
      'instructions': instructions,
      'default_sets': defaultSets,
      'default_reps': defaultReps,
      'rest_seconds': restSeconds,
      'safety_guidance': safetyGuidance,
      'image_url': imageUrl,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'chest',
      targetMuscle: json['target_muscle'] as String? ?? '',
      secondaryMuscles: (json['secondary_muscles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      equipment: json['equipment'] as String? ?? 'bodyweight',
      difficulty: json['difficulty'] as String? ?? 'intermediate',
      instructions: json['instructions'] as String? ?? '',
      defaultSets: json['default_sets'] as int? ?? 3,
      defaultReps: json['default_reps'] as int? ?? 10,
      restSeconds: json['rest_seconds'] as int? ?? 90,
      safetyGuidance: json['safety_guidance'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
    );
  }
}
