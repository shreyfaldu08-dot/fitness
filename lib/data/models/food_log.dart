import 'food.dart';

enum MealType { breakfast, lunch, dinner, snack }

class FoodLog {
  final String id;
  final String userId;
  final String foodId;
  final String foodName;
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snack'
  final double quantity; // multiplier, e.g. 1.5 servings
  final String servingUnit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final DateTime loggedAt;
  final Food? food;

  const FoodLog({
    required this.id,
    required this.userId,
    required this.foodId,
    required this.foodName,
    required this.mealType,
    required this.quantity,
    required this.servingUnit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0.0,
    required this.loggedAt,
    this.food,
  });

  String get mealDisplayName {
    switch (mealType) {
      case 'breakfast':
        return 'Breakfast';
      case 'lunch':
        return 'Lunch';
      case 'dinner':
        return 'Dinner';
      case 'snack':
      default:
        return 'Snack & Extras';
    }
  }

  FoodLog copyWith({
    String? id,
    String? userId,
    String? foodId,
    String? foodName,
    String? mealType,
    double? quantity,
    String? servingUnit,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    DateTime? loggedAt,
    Food? food,
  }) {
    return FoodLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      foodId: foodId ?? this.foodId,
      foodName: foodName ?? this.foodName,
      mealType: mealType ?? this.mealType,
      quantity: quantity ?? this.quantity,
      servingUnit: servingUnit ?? this.servingUnit,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      loggedAt: loggedAt ?? this.loggedAt,
      food: food ?? this.food,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'food_id': foodId,
      'food_name': foodName,
      'meal_type': mealType,
      'quantity': quantity,
      'serving_unit': servingUnit,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'logged_at': loggedAt.toIso8601String(),
    };
  }

  factory FoodLog.fromJson(Map<String, dynamic> json, [Food? food]) {
    return FoodLog(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      foodId: json['food_id'] as String? ?? '',
      foodName: json['food_name'] as String? ?? '',
      mealType: json['meal_type'] as String? ?? 'breakfast',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      servingUnit: json['serving_unit'] as String? ?? 'serving',
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0.0,
      loggedAt: json['logged_at'] != null
          ? DateTime.parse(json['logged_at'] as String)
          : DateTime.now(),
      food: food,
    );
  }
}
