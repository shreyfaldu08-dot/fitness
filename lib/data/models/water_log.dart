class WaterLog {
  final String id;
  final String userId;
  final int amountMl;
  final DateTime loggedAt;

  const WaterLog({
    required this.id,
    required this.userId,
    required this.amountMl,
    required this.loggedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount_ml': amountMl,
      'logged_at': loggedAt.toIso8601String(),
    };
  }

  factory WaterLog.fromJson(Map<String, dynamic> json) {
    return WaterLog(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      amountMl: (json['amount_ml'] as num?)?.toInt() ?? 250,
      loggedAt: json['logged_at'] != null
          ? DateTime.parse(json['logged_at'] as String)
          : DateTime.now(),
    );
  }
}
