class BodyMeasurement {
  final String id;
  final String userId;
  final DateTime loggedDate;
  final double weightKg;
  final double? heightCm;
  final double? bmi;
  final double? waistCm;
  final double? chestCm;
  final double? hipCm;
  final double? armCm;
  final double? thighCm;
  final String? photoUrl;
  final String? notes;

  const BodyMeasurement({
    required this.id,
    required this.userId,
    required this.loggedDate,
    required this.weightKg,
    this.heightCm,
    this.bmi,
    this.waistCm,
    this.chestCm,
    this.hipCm,
    this.armCm,
    this.thighCm,
    this.photoUrl,
    this.notes,
  });

  BodyMeasurement copyWith({
    String? id,
    String? userId,
    DateTime? loggedDate,
    double? weightKg,
    double? heightCm,
    double? bmi,
    double? waistCm,
    double? chestCm,
    double? hipCm,
    double? armCm,
    double? thighCm,
    String? photoUrl,
    String? notes,
  }) {
    return BodyMeasurement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      loggedDate: loggedDate ?? this.loggedDate,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      bmi: bmi ?? this.bmi,
      waistCm: waistCm ?? this.waistCm,
      chestCm: chestCm ?? this.chestCm,
      hipCm: hipCm ?? this.hipCm,
      armCm: armCm ?? this.armCm,
      thighCm: thighCm ?? this.thighCm,
      photoUrl: photoUrl ?? this.photoUrl,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'logged_date': loggedDate.toIso8601String(),
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'bmi': bmi,
      'waist_cm': waistCm,
      'chest_cm': chestCm,
      'hip_cm': hipCm,
      'arm_cm': armCm,
      'thigh_cm': thighCm,
      'photo_url': photoUrl,
      'notes': notes,
    };
  }

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) {
    return BodyMeasurement(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      loggedDate: json['logged_date'] != null
          ? DateTime.parse(json['logged_date'] as String)
          : DateTime.now(),
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 70.0,
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
      waistCm: (json['waist_cm'] as num?)?.toDouble(),
      chestCm: (json['chest_cm'] as num?)?.toDouble(),
      hipCm: (json['hip_cm'] as num?)?.toDouble(),
      armCm: (json['arm_cm'] as num?)?.toDouble(),
      thighCm: (json['thigh_cm'] as num?)?.toDouble(),
      photoUrl: json['photo_url'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
