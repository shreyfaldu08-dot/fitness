class UserPreferences {
  final String id;
  final String userId;
  final String dietaryPreference; // vegetarian, vegan, eggetarian, non_vegetarian
  final List<String> foodAllergies;
  final List<String> foodDislikes;
  final String dailyBudget; // budget, moderate, premium
  final String cookingAvailability; // quick_15m, standard_30m, relaxed_60m
  final String workoutPreference; // gym, home, hybrid
  final int workoutDurationMinutes;
  final int availableDaysPerWeek;
  final double sleepTargetHours;
  final int waterTargetMl;
  final String wakeUpTime;
  final String bedTime;

  const UserPreferences({
    required this.id,
    required this.userId,
    this.dietaryPreference = 'vegetarian',
    this.foodAllergies = const [],
    this.foodDislikes = const [],
    this.dailyBudget = 'moderate',
    this.cookingAvailability = 'standard_30m',
    this.workoutPreference = 'gym',
    this.workoutDurationMinutes = 45,
    this.availableDaysPerWeek = 4,
    this.sleepTargetHours = 8.0,
    this.waterTargetMl = 3000,
    this.wakeUpTime = '06:30',
    this.bedTime = '22:30',
  });

  UserPreferences copyWith({
    String? id,
    String? userId,
    String? dietaryPreference,
    List<String>? foodAllergies,
    List<String>? foodDislikes,
    String? dailyBudget,
    String? cookingAvailability,
    String? workoutPreference,
    int? workoutDurationMinutes,
    int? availableDaysPerWeek,
    double? sleepTargetHours,
    int? waterTargetMl,
    String? wakeUpTime,
    String? bedTime,
  }) {
    return UserPreferences(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      foodAllergies: foodAllergies ?? this.foodAllergies,
      foodDislikes: foodDislikes ?? this.foodDislikes,
      dailyBudget: dailyBudget ?? this.dailyBudget,
      cookingAvailability: cookingAvailability ?? this.cookingAvailability,
      workoutPreference: workoutPreference ?? this.workoutPreference,
      workoutDurationMinutes: workoutDurationMinutes ?? this.workoutDurationMinutes,
      availableDaysPerWeek: availableDaysPerWeek ?? this.availableDaysPerWeek,
      sleepTargetHours: sleepTargetHours ?? this.sleepTargetHours,
      waterTargetMl: waterTargetMl ?? this.waterTargetMl,
      wakeUpTime: wakeUpTime ?? this.wakeUpTime,
      bedTime: bedTime ?? this.bedTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'dietary_preference': dietaryPreference,
      'food_allergies': foodAllergies,
      'food_dislikes': foodDislikes,
      'daily_budget': dailyBudget,
      'cooking_availability': cookingAvailability,
      'workout_preference': workoutPreference,
      'workout_duration_minutes': workoutDurationMinutes,
      'available_days_per_week': availableDaysPerWeek,
      'sleep_target_hours': sleepTargetHours,
      'water_target_ml': waterTargetMl,
      'wake_up_time': wakeUpTime,
      'bed_time': bedTime,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      dietaryPreference: json['dietary_preference'] as String? ?? 'vegetarian',
      foodAllergies: (json['food_allergies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      foodDislikes: (json['food_dislikes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      dailyBudget: json['daily_budget'] as String? ?? 'moderate',
      cookingAvailability: json['cooking_availability'] as String? ?? 'standard_30m',
      workoutPreference: json['workout_preference'] as String? ?? 'gym',
      workoutDurationMinutes: json['workout_duration_minutes'] as int? ?? 45,
      availableDaysPerWeek: json['available_days_per_week'] as int? ?? 4,
      sleepTargetHours: (json['sleep_target_hours'] as num?)?.toDouble() ?? 8.0,
      waterTargetMl: json['water_target_ml'] as int? ?? 3000,
      wakeUpTime: json['wake_up_time'] as String? ?? '06:30',
      bedTime: json['bed_time'] as String? ?? '22:30',
    );
  }
}
