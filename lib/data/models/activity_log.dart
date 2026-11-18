class ActivityLog {
  final String id;
  final String userId;
  final DateTime loggedDate;
  final int steps;
  final int activeMinutes;
  final int caloriesBurned;
  final bool isDeviceData;

  const ActivityLog({
    required this.id,
    required this.userId,
    required this.loggedDate,
    required this.steps,
    required this.activeMinutes,
    required this.caloriesBurned,
    this.isDeviceData = false,
  });

  ActivityLog copyWith({
    String? id,
    String? userId,
    DateTime? loggedDate,
    int? steps,
    int? activeMinutes,
    int? caloriesBurned,
    bool? isDeviceData,
  }) {
    return ActivityLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      loggedDate: loggedDate ?? this.loggedDate,
      steps: steps ?? this.steps,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      isDeviceData: isDeviceData ?? this.isDeviceData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'logged_date': loggedDate.toIso8601String(),
      'steps': steps,
      'active_minutes': activeMinutes,
      'calories_burned': caloriesBurned,
      'is_device_data': isDeviceData,
    };
  }

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      loggedDate: json['logged_date'] != null
          ? DateTime.parse(json['logged_date'] as String)
          : DateTime.now(),
      steps: json['steps'] as int? ?? 0,
      activeMinutes: json['active_minutes'] as int? ?? 0,
      caloriesBurned: json['calories_burned'] as int? ?? 0,
      isDeviceData: json['is_device_data'] as bool? ?? false,
    );
  }
}

class SleepLog {
  final String id;
  final String userId;
  final DateTime loggedDate;
  final double durationHours;
  final int qualityRating; // 1-5 stars
  final String bedTime;
  final String wakeTime;
  final String? notes;

  const SleepLog({
    required this.id,
    required this.userId,
    required this.loggedDate,
    required this.durationHours,
    this.qualityRating = 4,
    this.bedTime = '23:00',
    this.wakeTime = '07:00',
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'logged_date': loggedDate.toIso8601String(),
      'duration_hours': durationHours,
      'quality_rating': qualityRating,
      'bed_time': bedTime,
      'wake_time': wakeTime,
      'notes': notes,
    };
  }

  factory SleepLog.fromJson(Map<String, dynamic> json) {
    return SleepLog(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      loggedDate: json['logged_date'] != null
          ? DateTime.parse(json['logged_date'] as String)
          : DateTime.now(),
      durationHours: (json['duration_hours'] as num?)?.toDouble() ?? 7.5,
      qualityRating: json['quality_rating'] as int? ?? 4,
      bedTime: json['bed_time'] as String? ?? '23:00',
      wakeTime: json['wake_time'] as String? ?? '07:00',
      notes: json['notes'] as String?,
    );
  }
}
