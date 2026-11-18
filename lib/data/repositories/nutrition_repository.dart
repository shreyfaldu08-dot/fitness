import 'package:flutter/foundation.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/supabase_service.dart';
import '../models/food.dart';
import '../models/food_log.dart';
import '../models/meal_plan.dart';
import '../seed/seed_foods.dart';

class NutritionRepository {
  List<Food> _foods = [];
  List<FoodLog> _logs = [];

  NutritionRepository() {
    _loadLocalCache();
  }

  void _loadLocalCache() {
    _foods = List.from(SeedFoods.list);

    final storedFoods = StorageService.getJson('fitora_custom_foods');
    if (storedFoods is List) {
      _foods.addAll(
        storedFoods.map((f) => Food.fromJson(f as Map<String, dynamic>)),
      );
    }

    final storedLogs = StorageService.getJson('fitora_food_logs');
    if (storedLogs is List) {
      _logs = storedLogs.map((l) {
        final map = l as Map<String, dynamic>;
        final fId = map['food_id'] as String? ?? '';
        Food? found;
        try {
          found = _foods.firstWhere((f) => f.id == fId);
        } catch (_) {}
        return FoodLog.fromJson(map, found);
      }).toList();
    }
  }

  List<Food> searchFoods({String? query, String? category}) {
    return _foods.where((f) {
      final matchesCat = category == null ||
          category.isEmpty ||
          category == 'all' ||
          f.category.toLowerCase() == category.toLowerCase();
      final matchesQuery = query == null ||
          query.isEmpty ||
          f.name.toLowerCase().contains(query.toLowerCase()) ||
          (f.localName?.toLowerCase().contains(query.toLowerCase()) ?? false);
      return matchesCat && matchesQuery;
    }).toList();
  }

  Future<void> addCustomFood(Food food) async {
    _foods.insert(0, food);
    final customList = _foods.where((f) => !SeedFoods.list.any((s) => s.id == f.id)).toList();
    await StorageService.setJson(
      'fitora_custom_foods',
      customList.map((f) => f.toJson()).toList(),
    );

    if (!SupabaseService.isOfflineMode && SupabaseService.client != null) {
      try {
        await SupabaseService.client!.from('foods').upsert(food.toJson());
      } catch (e) {
        debugPrint('[NutritionRepository] Upsert food error: $e');
      }
    }
  }

  List<FoodLog> getLogsForDate(DateTime date) {
    return _logs.where((log) {
      return log.loggedAt.year == date.year &&
          log.loggedAt.month == date.month &&
          log.loggedAt.day == date.day;
    }).toList();
  }

  Future<void> addFoodLog(FoodLog log) async {
    _logs.insert(0, log);
    await _persistLogs();

    if (!SupabaseService.isOfflineMode && SupabaseService.client != null) {
      try {
        await SupabaseService.client!.from('food_logs').upsert(log.toJson());
      } catch (e) {
        debugPrint('[NutritionRepository] Upsert food log error: $e');
      }
    }
  }

  Future<void> deleteFoodLog(String logId) async {
    _logs.removeWhere((l) => l.id == logId);
    await _persistLogs();

    if (!SupabaseService.isOfflineMode && SupabaseService.client != null) {
      try {
        await SupabaseService.client!.from('food_logs').delete().eq('id', logId);
      } catch (e) {
        debugPrint('[NutritionRepository] Delete food log error: $e');
      }
    }
  }

  Future<void> _persistLogs() async {
    await StorageService.setJson(
      'fitora_food_logs',
      _logs.map((l) => l.toJson()).toList(),
    );
  }

  // Generate verified meal plan suggestions
  DailyMealPlan getSampleMealPlan(String dayName, {bool isVegetarian = true}) {
    if (isVegetarian) {
      return DailyMealPlan(
        dayName: dayName,
        meals: const [
          MealPlanItem(
            id: 'mp_veg_1',
            title: 'High Protein Besan & Moong Chilla',
            hindiName: 'बेसन और मूंग दाल चीला',
            mealType: 'breakfast',
            calories: 330,
            protein: 18,
            carbs: 42,
            fat: 9,
            ingredients: '2 chillas made with sprouted moong batter, topped with grated paneer and mint chutney.',
            alternativeSuggestion: 'Oats upma with soaked almonds or 2 steamed idlis with sambar.',
          ),
          MealPlanItem(
            id: 'mp_veg_2',
            title: 'Homestyle Moong Dal Tadka with Chapatis & Paneer',
            hindiName: 'दाल तड़का, रोटी और पनीर भुर्जी',
            mealType: 'lunch',
            calories: 580,
            protein: 34,
            carbs: 68,
            fat: 16,
            ingredients: '2 whole wheat chapatis + 1 bowl yellow moong dal + 100g low fat paneer bhurji + cucumber salad.',
            alternativeSuggestion: '1 cup Steamed Brown Rice with Rajma curry and dahi (curd).',
          ),
          MealPlanItem(
            id: 'mp_veg_3',
            title: 'Sprouted Moong Chaat & Roasted Chana',
            hindiName: 'अंकुरित मूंग चाट',
            mealType: 'snack',
            calories: 180,
            protein: 12,
            carbs: 28,
            fat: 2,
            ingredients: '1 cup steamed sprouts with lemon, tomato, green chilli and roasted cumin powder.',
            alternativeSuggestion: '1 scoop Whey Protein Isolate or 1 cup Greek yogurt.',
          ),
          MealPlanItem(
            id: 'mp_veg_4',
            title: 'Moong Dal Khichdi with Curd & Sautéed Palak',
            hindiName: 'दाल खिचड़ी और पालक',
            mealType: 'dinner',
            calories: 450,
            protein: 20,
            carbs: 65,
            fat: 11,
            ingredients: '1 plate light moong dal khichdi + 1 katori fresh dahi + sautéed garlic spinach.',
            alternativeSuggestion: '2 Bajra rotis with Baingan Bharta and buttermilk (chaas).',
          ),
        ],
      );
    } else {
      return DailyMealPlan(
        dayName: dayName,
        meals: const [
          MealPlanItem(
            id: 'mp_nonveg_1',
            title: 'Egg White Omelet & Whole Wheat Toast',
            hindiName: 'अंडे की भुर्जी और टोस्ट',
            mealType: 'breakfast',
            calories: 360,
            protein: 28,
            carbs: 35,
            fat: 8,
            ingredients: '3 egg whites + 1 whole egg scrambled with onions and tomatoes + 2 slices brown bread.',
            alternativeSuggestion: 'Oatmeal with whey protein and chopped banana.',
          ),
          MealPlanItem(
            id: 'mp_nonveg_2',
            title: 'Tandoori Grilled Chicken Breast with Brown Rice & Dal',
            hindiName: 'तंदूरी चिकन और चावल',
            mealType: 'lunch',
            calories: 620,
            protein: 48,
            carbs: 62,
            fat: 14,
            ingredients: '150g grilled chicken breast + 1 cup steamed brown rice + 1 katori yellow dal + mixed greens.',
            alternativeSuggestion: 'Fish curry with steamed rice and green beans.',
          ),
          MealPlanItem(
            id: 'mp_nonveg_3',
            title: 'Plain Greek Yogurt with Almonds',
            hindiName: 'ग्रीक योगर्ट और बादाम',
            mealType: 'snack',
            calories: 190,
            protein: 16,
            carbs: 12,
            fat: 9,
            ingredients: '150g plain greek yogurt topped with 12 soaked almonds and cinnamon.',
            alternativeSuggestion: '2 boiled whole eggs with black pepper.',
          ),
          MealPlanItem(
            id: 'mp_nonveg_4',
            title: 'Grilled Fish / Paneer with Roti & Stir-fried Vegetables',
            hindiName: 'रोटी और भुनी हुई सब्ज़ी',
            mealType: 'dinner',
            calories: 480,
            protein: 36,
            carbs: 45,
            fat: 14,
            ingredients: '150g white fish or low-fat paneer + 2 multigrain rotis + sautéed broccoli and capsicum.',
            alternativeSuggestion: 'Chicken soup with shredded chicken breast and warm dinner roll.',
          ),
        ],
      );
    }
  }
}
