class Habit {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category; // water, steps, workout, sleep, nutrition, mindfulness
  final int targetValue;
  final String unit;
  final int currentStreak;
  final int bestStreak;
  final bool isCompletedToday;
  final String? reminderTime;

  const Habit({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.targetValue,
    required this.unit,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.isCompletedToday = false,
    this.reminderTime,
  });

  Habit copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    int? targetValue,
    String? unit,
    int? currentStreak,
    int? bestStreak,
    bool? isCompletedToday,
    String? reminderTime,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category,
      'target_value': targetValue,
      'unit': unit,
      'current_streak': currentStreak,
      'best_streak': bestStreak,
      'is_completed_today': isCompletedToday,
      'reminder_time': reminderTime,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'water',
      targetValue: json['target_value'] as int? ?? 1,
      unit: json['unit'] as String? ?? 'times',
      currentStreak: json['current_streak'] as int? ?? 0,
      bestStreak: json['best_streak'] as int? ?? 0,
      isCompletedToday: json['is_completed_today'] as bool? ?? false,
      reminderTime: json['reminder_time'] as String?,
    );
  }
}
