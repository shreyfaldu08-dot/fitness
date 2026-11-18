import 'dart:math' as math;

enum FitnessGoalType {
  fatLoss,
  muscleGain,
  strength,
  endurance,
  maintenance,
}

enum ActivityLevelType {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  extremelyActive,
}

enum GenderType {
  male,
  female,
  preferNotToSay,
}

class MacroTargets {
  final int calories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final int waterMl;

  const MacroTargets({
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.waterMl,
  });
}

class FitnessCalculator {
  FitnessCalculator._();

  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return math.max(1, age);
  }

  static double calculateBmi({
    required double weightKg,
    required double heightCm,
  }) {
    if (heightCm <= 0 || weightKg <= 0) return 0.0;
    final heightM = heightCm / 100.0;
    final bmi = weightKg / (heightM * heightM);
    return double.parse(bmi.toStringAsFixed(1));
  }

  static String getBmiCategory(double bmi) {
    if (bmi <= 0) return 'Unknown';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 24.9) return 'Normal weight';
    if (bmi < 29.9) return 'Overweight';
    return 'Obese';
  }

  /// Calculates Basal Metabolic Rate using the Mifflin-St Jeor equation.
  static int calculateBmr({
    required double weightKg,
    required double heightCm,
    required int age,
    required GenderType gender,
  }) {
    if (weightKg <= 0 || heightCm <= 0 || age <= 0) return 1800;

    double bmr;
    switch (gender) {
      case GenderType.male:
        bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
        break;
      case GenderType.female:
        bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
        break;
      case GenderType.preferNotToSay:
        bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 78;
        break;
    }
    return math.max(1000, bmr.round());
  }

  /// Total Daily Energy Expenditure (TDEE) based on activity level multiplier.
  static int calculateTdee({
    required int bmr,
    required ActivityLevelType activityLevel,
  }) {
    double multiplier;
    switch (activityLevel) {
      case ActivityLevelType.sedentary:
        multiplier = 1.2;
        break;
      case ActivityLevelType.lightlyActive:
        multiplier = 1.375;
        break;
      case ActivityLevelType.moderatelyActive:
        multiplier = 1.55;
        break;
      case ActivityLevelType.veryActive:
        multiplier = 1.725;
        break;
      case ActivityLevelType.extremelyActive:
        multiplier = 1.9;
        break;
    }
    return (bmr * multiplier).round();
  }

  /// Computes personalized calorie targets and macronutrient distributions.
  static MacroTargets calculateMacroTargets({
    required double weightKg,
    required double heightCm,
    required int age,
    required GenderType gender,
    required ActivityLevelType activityLevel,
    required FitnessGoalType goal,
  }) {
    final bmr = calculateBmr(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
    );
    final tdee = calculateTdee(bmr: bmr, activityLevel: activityLevel);

    int targetCalories;
    double proteinMultiplier; // grams per kg

    switch (goal) {
      case FitnessGoalType.fatLoss:
        targetCalories = (tdee - 450).clamp(1200, 4500);
        proteinMultiplier = 2.0; // Higher protein to preserve lean muscle in deficit
        break;
      case FitnessGoalType.muscleGain:
        targetCalories = (tdee + 350).clamp(1500, 5000);
        proteinMultiplier = 2.0;
        break;
      case FitnessGoalType.strength:
        targetCalories = (tdee + 150).clamp(1500, 4800);
        proteinMultiplier = 1.9;
        break;
      case FitnessGoalType.endurance:
        targetCalories = (tdee + 200).clamp(1600, 5000);
        proteinMultiplier = 1.6;
        break;
      case FitnessGoalType.maintenance:
        targetCalories = tdee.clamp(1400, 4500);
        proteinMultiplier = 1.8;
        break;
    }

    // Protein: 4 kcal per gram
    int proteinGrams = (weightKg * proteinMultiplier).round().clamp(60, 260);
    int proteinCalories = proteinGrams * 4;

    // Fat: 25-28% of total calories (9 kcal per gram)
    int fatCalories = (targetCalories * 0.27).round();
    int fatGrams = (fatCalories / 9).round().clamp(30, 140);

    // Carbohydrates: remaining calories divided by 4 kcal per gram
    int remainingCalories = targetCalories - (proteinCalories + (fatGrams * 9));
    int carbsGrams = math.max(50, (remainingCalories / 4).round());

    // Recalibrate target calories to match exact sum of macros
    int exactCalories = (proteinGrams * 4) + (carbsGrams * 4) + (fatGrams * 9);

    // Recommended water intake: ~35-40 ml per kg of bodyweight
    int waterMl = ((weightKg * 38) / 100).round() * 100;
    waterMl = waterMl.clamp(2000, 4500);

    return MacroTargets(
      calories: exactCalories,
      proteinGrams: proteinGrams,
      carbsGrams: carbsGrams,
      fatGrams: fatGrams,
      waterMl: waterMl,
    );
  }
}
