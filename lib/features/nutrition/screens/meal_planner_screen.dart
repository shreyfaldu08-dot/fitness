import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/fitora_card.dart';
import '../../../core/widgets/fitora_chip.dart';
import '../../../data/models/meal_plan.dart';

class MealPlannerScreen extends ConsumerStatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  ConsumerState<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends ConsumerState<MealPlannerScreen> {
  bool _isVegetarian = true;
  String _selectedDay = 'Today';

  final List<String> _days = const ['Today', 'Tomorrow', 'Day 3', 'Day 4', 'Day 5'];

  @override
  Widget build(BuildContext context) {
    final nutritionRepo = ref.watch(nutritionRepositoryProvider);
    final plan = nutritionRepo.getSampleMealPlan(_selectedDay, isVegetarian: _isVegetarian);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Smart Meal Blueprint'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dietary Toggle & Days
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FitoraChip(
                    label: _isVegetarian ? 'Vegetarian Plan (शाकाहारी)' : 'High-Protein Non-Veg',
                    icon: Icon(_isVegetarian ? Icons.eco_rounded : Icons.egg_rounded, size: 16),
                    isSelected: true,
                    onTap: () => setState(() => _isVegetarian = !_isVegetarian),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Day Pills
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _days.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final day = _days[index];
                    final isSelected = _selectedDay == day;
                    return FitoraChip(
                      label: day,
                      isSelected: isSelected,
                      onTap: () => setState(() => _selectedDay = day),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Macro Overview for the day
              FitoraCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Blueprint Energy', style: AppTypography.labelLarge),
                        Text(
                          '${plan.totalCalories.round()} kcal',
                          style: AppTypography.headingSmall.copyWith(color: AppColors.calorieAccent),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMacroStat('Protein', '${plan.totalProtein.round()}g', AppColors.proteinAccent),
                        _buildMacroStat('Carbs', '${plan.totalCarbs.round()}g', AppColors.carbAccent),
                        _buildMacroStat('Fats', '${plan.totalFat.round()}g', AppColors.fatAccent),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text('Daily Scheduled Meals', style: AppTypography.headingSmall),
              const SizedBox(height: AppSpacing.sm),

              ...plan.meals.map((meal) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildMealCard(context, meal),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.labelSmall),
      ],
    );
  }

  Widget _buildMealCard(BuildContext context, MealPlanItem meal) {
    return FitoraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: AppSpacing.roundedSm,
                ),
                child: Text(
                  meal.mealType.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${meal.calories.round()} kcal • ${meal.protein.round()}g Protein',
                style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(meal.title, style: AppTypography.labelLarge),
          if (meal.hindiName.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(meal.hindiName, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11)),
          ],
          const SizedBox(height: 6),
          Text(meal.ingredients, style: AppTypography.bodySmall),
          const Divider(height: 18),

          // Meal Swap Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.swap_horiz_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: AppTypography.bodySmall.copyWith(fontSize: 12),
                    children: [
                      const TextSpan(text: 'Nutritional Swap: ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      TextSpan(text: meal.alternativeSuggestion, style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
