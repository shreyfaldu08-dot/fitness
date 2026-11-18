class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final DateTime? dateOfBirth;
  final String? gender;
  final double heightCm;
  final double currentWeightKg;
  final double targetWeightKg;
  final String preferredUnits; // 'metric' or 'imperial'
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.dateOfBirth,
    this.gender,
    required this.heightCm,
    required this.currentWeightKg,
    required this.targetWeightKg,
    this.preferredUnits = 'metric',
    required this.createdAt,
    required this.updatedAt,
  });

  int get age {
    if (dateOfBirth == null) return 25;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age > 0 ? age : 25;
  }

  double get bmi {
    if (heightCm <= 0) return 0;
    final h = heightCm / 100.0;
    return double.parse((currentWeightKg / (h * h)).toStringAsFixed(1));
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    DateTime? dateOfBirth,
    String? gender,
    double? heightCm,
    double? currentWeightKg,
    double? targetWeightKg,
    String? preferredUnits,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      preferredUnits: preferredUnits ?? this.preferredUnits,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'height_cm': heightCm,
      'current_weight_kg': currentWeightKg,
      'target_weight_kg': targetWeightKg,
      'preferred_units': preferredUnits,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String?,
      heightCm: (json['height_cm'] as num?)?.toDouble() ?? 172.0,
      currentWeightKg: (json['current_weight_kg'] as num?)?.toDouble() ?? 70.0,
      targetWeightKg: (json['target_weight_kg'] as num?)?.toDouble() ?? 68.0,
      preferredUnits: json['preferred_units'] as String? ?? 'metric',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}
