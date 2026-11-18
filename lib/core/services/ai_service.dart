import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/fitness_goal.dart';
import '../../data/models/user_preferences.dart';

class AiService {
  AiService._();

  static Future<String> generateFitnessResponse({
    required String prompt,
    UserProfile? profile,
    FitnessGoal? goal,
    UserPreferences? preferences,
    List<String> recentWorkoutNames = const [],
    int todayCaloriesLogged = 0,
    int todayWaterMl = 0,
  }) async {
    final apiKey = AppConstants.openAiApiKey;

    // Build rich context summary
    final contextSummary = StringBuffer();
    if (profile != null) {
      contextSummary.writeln('User Profile: ${profile.fullName}, Age: ${profile.age}, Weight: ${profile.currentWeightKg}kg, Height: ${profile.heightCm}cm, BMI: ${profile.bmi}');
    }
    if (goal != null) {
      contextSummary.writeln('Goal: ${goal.goalDisplayName}, Target Calories: ${goal.targetCalories} kcal, Target Protein: ${goal.targetProteinG}g, Target Carbs: ${goal.targetCarbsG}g, Target Fat: ${goal.targetFatG}g');
    }
    if (preferences != null) {
      contextSummary.writeln('Diet: ${preferences.dietaryPreference}, Cooking: ${preferences.cookingAvailability}, Budget: ${preferences.dailyBudget}, Workout Location: ${preferences.workoutPreference}');
    }
    contextSummary.writeln('Today Status: $todayCaloriesLogged kcal logged, $todayWaterMl ml water.');

    // If an OpenAI API Key is provided, call OpenAI securely
    if (apiKey.isNotEmpty && !apiKey.contains('placeholder')) {
      try {
        final response = await http.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': 'gpt-4o-mini',
            'messages': [
              {
                'role': 'system',
                'content': '''You are FITORA AI, a world-class personal fitness coach and sports nutritionist.
Context of user:
$contextSummary

Safety & Medical Guidelines:
1. You are an AI fitness assistant, not a doctor. Never diagnose medical conditions or prescribe medications.
2. Never recommend extreme calorie deficits (<1200 kcal for women, <1500 kcal for men) or dangerous dehydration/starvation methods.
3. Prioritize whole foods, verified Indian dietary options (dals, paneer, sprouts, rotis, curd) and balanced resistance training.
4. Keep advice clear, actionable, evidence-based, and encouraging.''',
              },
              {'role': 'user', 'content': prompt},
            ],
            'temperature': 0.7,
            'max_tokens': 600,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final content = data['choices']?[0]?['message']?['content'] as String?;
          if (content != null && content.isNotEmpty) {
            return content.trim();
          }
        }
      } catch (_) {
        // Fall back to local intelligent engine
      }
    }

    // Local Intelligent Engine (Rule-based sports nutrition & training reasoning)
    return _generateLocalIntelligentResponse(
      prompt: prompt.toLowerCase(),
      profile: profile,
      goal: goal,
      preferences: preferences,
      todayCaloriesLogged: todayCaloriesLogged,
    );
  }

  static String _generateLocalIntelligentResponse({
    required String prompt,
    UserProfile? profile,
    FitnessGoal? goal,
    UserPreferences? preferences,
    int todayCaloriesLogged = 0,
  }) {
    final diet = preferences?.dietaryPreference ?? 'vegetarian';
    final targetCal = goal?.targetCalories ?? 2100;
    final targetProtein = goal?.targetProteinG ?? 130;
    final remainingCal = targetCal - todayCaloriesLogged;

    if (prompt.contains('eat today') || prompt.contains('meal plan') || prompt.contains('what should i eat')) {
      if (diet == 'vegetarian' || diet == 'vegan') {
        return '''Here is a nutrient-dense, high-protein meal framework tailored to your $targetCal kcal target:

1. **Breakfast (8:30 AM)**: 
   • Besan & Moong Dal Chilla (2 pieces) topped with grated paneer or tofu (approx 320 kcal, 18g protein).
   • 1 cup spiced tea/coffee or fresh lemon water.

2. **Lunch (1:30 PM)**: 
   • 2 Whole Wheat Chapatis + 1 katori Yellow Moong Dal Tadka.
   • 100g Fresh Low-Fat Paneer Bhurji with bell peppers and onions.
   • Fresh cucumber and tomato salad with chaat masala (approx 520 kcal, 32g protein).

3. **Evening Snack (5:00 PM)**: 
   • 1 cup Sprouted Moong Chaat with lemon, or 1 scoop Whey Protein with water (approx 160 kcal, 15g-24g protein).

4. **Dinner (8:30 PM)**: 
   • 1 bowl Moong Dal Khichdi + 1 katori Dahi (curd) and steamed green beans (approx 440 kcal, 18g protein).

💡 *Estimated daily total: ~1,440-1,850 kcal. Adjust portion sizes of chapati/rice to match your exact $targetCal kcal goal.*''';
      } else {
        return '''Here is your balanced meal suggestion for today ($targetCal kcal target):

1. **Breakfast**: 3 Whole Boiled Eggs or 4-egg omelet with spinach + 2 slices whole wheat toast (approx 380 kcal, 26g protein).
2. **Lunch**: 150g Grilled Chicken Breast + 1 cup Steamed Basmati Rice + 1 bowl Dal Tadka with fresh green salad (approx 580 kcal, 42g protein).
3. **Snack**: 1 cup Greek Yogurt with a handful of almonds and a sliced banana (approx 240 kcal, 16g protein).
4. **Dinner**: Mixed Vegetable Curry with 2 Chapatis and grilled paneer or fish fillet (approx 480 kcal, 28g protein).

💡 *Remember to hydrate steadily throughout the day (aim for 3+ liters)!*''';
      }
    }

    if (prompt.contains('protein') || prompt.contains('high-protein') || prompt.contains('vegetarian meal')) {
      return '''Top High-Protein Vegetarian & Indian Foods for Your Goals:

1. **Low-Fat Cow Milk Paneer**: ~25g protein per 100g serving. Excellent for muscle repair before bed.
2. **Soya Chunks**: ~52g protein per 100g dry weight. Boil thoroughly, squeeze excess water, and cook with spices.
3. **Moong Dal & Chana Sprouts**: ~8-10g bio-available protein per bowl with rich micronutrients and fiber.
4. **Greek Yogurt / Hung Curd**: ~15g protein per 150g serving. High calcium and gut-friendly probiotics.
5. **Roasted Kala Chana**: Portable, crunchy snack providing ~10g protein and sustained complex carbs.

💪 *Tip for today*: Pairing legumes with grains (e.g., Dal + Rice or Chana + Roti) creates a complete amino acid profile!''';
    }

    if (prompt.contains('weight fluctuate') || prompt.contains('fluctuation') || prompt.contains('scale')) {
      return '''Why Your Scale Weight Fluctuates Day-to-Day:

It is completely normal for scale weight to shift by **0.5 kg to 2.0 kg** within 24 hours. This is rarely actual fat gain or loss!

Key physiological causes:
1. **Water Retention from Sodium**: A saltier meal causes your body to hold an extra 500ml-1L of water temporarily.
2. **Glycogen Replenishment**: Every 1g of stored carbohydrate binds with roughly 3-4g of water in your muscles.
3. **Workout Inflammation**: Heavy resistance training causes micro-tears in muscle fibers, attracting healing fluids.
4. **Digestion / Food Volume**: Food remains in the gastrointestinal tract for 24-48 hours before elimination.

🎯 *Recommendation*: Track your weekly moving average and progress photos rather than stressing over a single morning readout.''';
    }

    if (prompt.contains('workout') || prompt.contains('suggest a workout') || prompt.contains('exercise')) {
      return '''Recommended Session for Today: **Full-Body Hypertrophy & Stability**

• **Warm-up (5 mins)**: Arm circles, bodyweight squats, cat-cow stretch.
• **Exercise 1**: Barbell Back Squats (or Goblet Squats) — 4 sets × 8-10 reps (90s rest).
• **Exercise 2**: Barbell Flat Bench Press (or Dumbbell Press) — 3 sets × 8-10 reps (90s rest).
• **Exercise 3**: Lat Pulldowns (or Bent-over Rows) — 3 sets × 10 reps (75s rest).
• **Exercise 4**: Dumbbell Lateral Raises — 3 sets × 12 reps (60s rest).
• **Finisher**: Forearm Plank — 3 rounds of 45-60 seconds hold.

🔥 *Tap "Start Workout" on your Workout tab to log your weights and track your rest timer live!*''';
    }

    // Default general advice
    return '''I have reviewed your current profile ($targetCal kcal target, $targetProtein g protein goal):

You have $remainingCal kcal remaining for today. To stay consistent with your ${goal?.goalDisplayName ?? "fitness"} goal:
• Prioritize a protein source with your next meal (such as paneer, dal, eggs, or Greek yogurt).
• Keep a water bottle nearby; staying hydrated keeps metabolic rate and training endurance optimal.
• Ensure you get 7-8 hours of quality sleep tonight for full muscular recovery.

Feel free to ask me to plan specific recipes, swap ingredients, or explain any exercise technique!''';
  }
}
