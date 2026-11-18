import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/fitora_card.dart';
import '../../../core/widgets/fitora_progress_ring.dart';
import '../../../data/models/food_log.dart';

class NutritionHomeScreen extends ConsumerWidget {
  const NutritionHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedNutritionDateProvider);
    final goal = ref.watch(fitnessGoalProvider);
    final logs = ref.watch(nutritionLogsProvider);

    // Compute macro totals
    final totalCalories = logs.fold(0.0, (sum, l) => sum + l.calories).round();
    final totalProtein = logs.fold(0.0, (sum, l) => sum + l.protein).round();
    final totalCarbs = logs.fold(0.0, (sum, l) => sum + l.carbs).round();
    final totalFat = logs.fold(0.0, (sum, l) => sum + l.fat).round();
    final totalFiber = logs.fold(0.0, (sum, l) => sum + l.fiber).round();

    final remainingCalories = (goal.targetCalories - totalCalories).clamp(0, 5000);
    final calorieRatio = goal.targetCalories > 0 ? (totalCalories / goal.targetCalories).clamp(0.0, 1.0) : 0.0;

    // Filter by meal type
    final breakfastLogs = logs.where((l) => l.mealType == 'breakfast').toList();
    final lunchLogs = logs.where((l) => l.mealType == 'lunch').toList();
    final dinnerLogs = logs.where((l) => l.mealType == 'dinner').toList();
    final snackLogs = logs.where((l) => l.mealType == 'snack').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nutrition & Fuel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_rounded),
            tooltip: 'Meal Planner',
            onPressed: () => context.push('/meal-planner'),
          ),
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: 'Create Custom Food',
            onPressed: () => context.push('/custom-food'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Switcher Row
              _buildDateSwitcher(
                context,
                date: selectedDate,
                onDateSelected: (d) => ref.read(selectedNutritionDateProvider.notifier).setDate(d),
              ),
              const SizedBox(height: AppSpacing.md),

              // Macro Rings & Summary Card
              _buildCalorieAndMacroCard(
                totalCalories: totalCalories,
                targetCalories: goal.targetCalories,
                remainingCalories: remainingCalories,
                ratio: calorieRatio,
                protein: totalProtein,
                targetProtein: goal.targetProteinG,
                carbs: totalCarbs,
                targetCarbs: goal.targetCarbsG,
                fat: totalFat,
                targetFat: goal.targetFatG,
                fiber: totalFiber,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Meal Sections
              _buildMealSection(
                context,
                title: 'Breakfast',
                icon: Icons.wb_sunny_outlined,
                color: AppColors.carbAccent,
                logs: breakfastLogs,
                onAdd: () => context.push('/food-search?mealType=breakfast'),
                onDelete: (id) => ref.read(nutritionLogsProvider.notifier).deleteLog(id),
              ),
              const SizedBox(height: AppSpacing.md),

              _buildMealSection(
                context,
                title: 'Lunch',
                icon: Icons.wb_twilight_rounded,
                color: AppColors.primary,
                logs: lunchLogs,
                onAdd: () => context.push('/food-search?mealType=lunch'),
                onDelete: (id) => ref.read(nutritionLogsProvider.notifier).deleteLog(id),
              ),
              const SizedBox(height: AppSpacing.md),

              _buildMealSection(
                context,
                title: 'Dinner',
                icon: Icons.nightlight_outlined,
                color: AppColors.sleepAccent,
                logs: dinnerLogs,
                onAdd: () => context.push('/food-search?mealType=dinner'),
                onDelete: (id) => ref.read(nutritionLogsProvider.notifier).deleteLog(id),
              ),
              const SizedBox(height: AppSpacing.md),

              _buildMealSection(
                context,
                title: 'Snacks & Extras',
                icon: Icons.fastfood_outlined,
                color: AppColors.fatAccent,
                logs: snackLogs,
                onAdd: () => context.push('/food-search?mealType=snack'),
                onDelete: (id) => ref.read(nutritionLogsProvider.notifier).deleteLog(id),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSwitcher(
    BuildContext context, {
    required DateTime date,
    required ValueChanged<DateTime> onDateSelected,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () => onDateSelected(date.subtract(const Duration(days: 1))),
        ),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2025),
              lastDate: DateTime(2027),
            );
            if (picked != null) onDateSelected(picked);
          },
          child: Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                DateFormatter.formatRelativeDate(date),
                style: AppTypography.headingSmall.copyWith(fontSize: 16),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: () => onDateSelected(date.add(const Duration(days: 1))),
        ),
      ],
    );
  }

  Widget _buildCalorieAndMacroCard({
    required int totalCalories,
    required int targetCalories,
    required int remainingCalories,
    required double ratio,
    required int protein,
    required int targetProtein,
    required int carbs,
    required int targetCarbs,
    required int fat,
    required int targetFat,
    required int fiber,
  }) {
    return FitoraCard(
      child: Column(
        children: [
          Row(
            children: [
              FitoraProgressRing(
                progress: ratio,
                size: 90,
                strokeWidth: 9,
                progressColor: AppColors.calorieAccent,
                centerChild: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$remainingCalories', style: AppTypography.statDisplay.copyWith(fontSize: 22)),
                    Text('kcal left', style: AppTypography.labelSmall.copyWith(fontSize: 10)),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$totalCalories consumed', style: AppTypography.labelLarge),
                        Text('$targetCalories target', style: AppTypography.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildMacroLinearRow('Protein', protein, targetProtein, AppColors.proteinAccent),
                    const SizedBox(height: 6),
                    _buildMacroLinearRow('Carbs', carbs, targetCarbs, AppColors.carbAccent),
                    const SizedBox(height: 6),
                    _buildMacroLinearRow('Fats', fat, targetFat, AppColors.fatAccent),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Fiber: ${fiber}g / 35g', style: AppTypography.bodySmall),
              Container(width: 1, height: 14, color: AppColors.border),
              Text('Calorie Adherence: ${(ratio * 100).round()}%',
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroLinearRow(String name, int current, int target, Color color) {
    final frac = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    return Row(
      children: [
        SizedBox(width: 48, child: Text(name, style: AppTypography.labelSmall)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: frac,
              backgroundColor: AppColors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$current/${target}g', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMealSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<FoodLog> logs,
    required VoidCallback onAdd,
    required ValueChanged<String> onDelete,
  }) {
    final mealCalories = logs.fold(0.0, (sum, l) => sum + l.calories).round();

    return FitoraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: AppSpacing.roundedSm,
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(title, style: AppTypography.labelLarge),
                ],
              ),
              Row(
                children: [
                  Text('$mealCalories kcal', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onAdd,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: AppColors.primary, size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (logs.isNotEmpty) ...[
            const Divider(height: 20),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logs.length,
              separatorBuilder: (_, __) => const Divider(height: 12),
              itemBuilder: (context, index) {
                final log = logs[index];
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(log.foodName, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(
                            '${log.quantity}x ${log.servingUnit} • ${log.protein.round()}g P • ${log.carbs.round()}g C • ${log.fat.round()}g F',
                            style: AppTypography.bodySmall.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Text('${log.calories.round()} kcal', style: AppTypography.labelMedium),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                      onPressed: () => onDelete(log.id),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
