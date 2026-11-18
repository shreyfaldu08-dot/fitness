class MealPlanItem {
  final String id;
  final String title;
  final String hindiName;
  final String mealType; // breakfast, lunch, dinner, snack
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String ingredients;
  final String alternativeSuggestion;

  const MealPlanItem({
    required this.id,
    required this.title,
    this.hindiName = '',
    required this.mealType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ingredients,
    required this.alternativeSuggestion,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'hindi_name': hindiName,
      'meal_type': mealType,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'ingredients': ingredients,
      'alternative_suggestion': alternativeSuggestion,
    };
  }

  factory MealPlanItem.fromJson(Map<String, dynamic> json) {
    return MealPlanItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      hindiName: json['hindi_name'] as String? ?? '',
      mealType: json['meal_type'] as String? ?? 'lunch',
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      ingredients: json['ingredients'] as String? ?? '',
      alternativeSuggestion: json['alternative_suggestion'] as String? ?? '',
    );
  }
}

class DailyMealPlan {
  final String dayName;
  final List<MealPlanItem> meals;

  const DailyMealPlan({
    required this.dayName,
    required this.meals,
  });

  double get totalCalories => meals.fold(0, (sum, m) => sum + m.calories);
  double get totalProtein => meals.fold(0, (sum, m) => sum + m.protein);
  double get totalCarbs => meals.fold(0, (sum, m) => sum + m.carbs);
  double get totalFat => meals.fold(0, (sum, m) => sum + m.fat);
}
