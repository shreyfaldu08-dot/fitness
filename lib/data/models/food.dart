class Food {
  final String id;
  final String name;
  final String? localName; // e.g. "चपाती", "दाल तड़का", "पोहा"
  final String category; // grains, lentils_legumes, dairy, vegetables, fruits, snacks, breakfast, meat_eggs
  final double servingSize;
  final String servingUnit; // g, ml, piece, cup, bowl, roti
  final double calories; // kcal per serving
  final double protein; // g per serving
  final double carbs; // g per serving
  final double fat; // g per serving
  final double fiber; // g per serving
  final bool isVegetarian;
  final bool isVegan;
  final bool isVerified;

  const Food({
    required this.id,
    required this.name,
    this.localName,
    required this.category,
    required this.servingSize,
    required this.servingUnit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0.0,
    this.isVegetarian = true,
    this.isVegan = false,
    this.isVerified = true,
  });

  String get categoryDisplayName {
    switch (category) {
      case 'grains':
        return 'Grains & Breads';
      case 'lentils_legumes':
        return 'Dals & Legumes';
      case 'dairy':
        return 'Dairy & Alternatives';
      case 'vegetables':
        return 'Vegetables & Sabzi';
      case 'fruits':
        return 'Fruits';
      case 'breakfast':
        return 'Breakfast Classics';
      case 'snacks':
        return 'Snacks & Light Bites';
      case 'meat_eggs':
        return 'Eggs & Non-Veg';
      default:
        return 'General Foods';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'local_name': localName,
      'category': category,
      'serving_size': servingSize,
      'serving_unit': servingUnit,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'is_vegetarian': isVegetarian,
      'is_vegan': isVegan,
      'is_verified': isVerified,
    };
  }

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      localName: json['local_name'] as String?,
      category: json['category'] as String? ?? 'grains',
      servingSize: (json['serving_size'] as num?)?.toDouble() ?? 100.0,
      servingUnit: json['serving_unit'] as String? ?? 'g',
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0.0,
      isVegetarian: json['is_vegetarian'] as bool? ?? true,
      isVegan: json['is_vegan'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? true,
    );
  }
}
