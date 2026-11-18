import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/fitora_button.dart';
import '../../../core/widgets/fitora_card.dart';
import '../../../core/widgets/fitora_chip.dart';
import '../../../data/models/food.dart';
import '../../../data/models/food_log.dart';

class FoodSearchScreen extends ConsumerStatefulWidget {
  final String mealType;

  const FoodSearchScreen({
    super.key,
    required this.mealType,
  });

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all';

  final List<(String id, String label)> _categories = const [
    ('all', 'All Foods'),
    ('grains', 'Rotis & Rice'),
    ('lentils_legumes', 'Dals & Legumes'),
    ('dairy', 'Paneer & Dairy'),
    ('breakfast', 'Breakfast'),
    ('vegetables', 'Subzi & Greens'),
    ('fruits', 'Fruits'),
    ('snacks', 'Snacks'),
    ('meat_eggs', 'Eggs & Meats'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showPortionSheet(Food food) {
    double quantity = 1.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final currentCalories = (food.calories * quantity).round();
            final currentProtein = (food.protein * quantity).toStringAsFixed(1);
            final currentCarbs = (food.carbs * quantity).toStringAsFixed(1);
            final currentFat = (food.fat * quantity).toStringAsFixed(1);
            final currentFiber = (food.fiber * quantity).toStringAsFixed(1);

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(food.name, style: AppTypography.headingSmall),
                            if (food.localName != null) ...[
                              const SizedBox(height: 2),
                              Text(food.localName!, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: AppSpacing.roundedSm,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_rounded, size: 14, color: AppColors.success),
                            const SizedBox(width: 4),
                            Text('Verified', style: AppTypography.labelSmall.copyWith(color: AppColors.success)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Serving Stepper
                  Text('Portion Size / Quantity', style: AppTypography.labelMedium),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: AppSpacing.roundedMd,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${quantity.toStringAsFixed(1)} x ${food.servingUnit}',
                          style: AppTypography.labelLarge,
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.primary),
                              onPressed: () {
                                if (quantity > 0.5) {
                                  setSheetState(() => quantity -= 0.5);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
                              onPressed: () {
                                setSheetState(() => quantity += 0.5);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Live Macro Cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPortionMacro('Calories', '$currentCalories', 'kcal', AppColors.calorieAccent),
                      _buildPortionMacro('Protein', '${currentProtein}g', '', AppColors.proteinAccent),
                      _buildPortionMacro('Carbs', '${currentCarbs}g', '', AppColors.carbAccent),
                      _buildPortionMacro('Fats', '${currentFat}g', '', AppColors.fatAccent),
                      _buildPortionMacro('Fiber', '${currentFiber}g', '', AppColors.stepsAccent),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Add Food Button
                  FitoraButton(
                    label: 'Log to ${widget.mealType.toUpperCase()}',
                    icon: const Icon(Icons.check_rounded, color: Colors.white),
                    onPressed: () async {
                      final newLog = FoodLog(
                        id: const Uuid().v4(),
                        userId: 'athlete_1',
                        foodId: food.id,
                        foodName: food.name,
                        mealType: widget.mealType,
                        quantity: quantity,
                        servingUnit: food.servingUnit,
                        calories: food.calories * quantity,
                        protein: food.protein * quantity,
                        carbs: food.carbs * quantity,
                        fat: food.fat * quantity,
                        fiber: food.fiber * quantity,
                        loggedAt: DateTime.now(),
                        food: food,
                      );

                      await ref.read(nutritionLogsProvider.notifier).addLog(newLog);

                      if (mounted) {
                        Navigator.pop(ctx);
                        context.pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Logged ${food.name} to ${widget.mealType}')),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPortionMacro(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(value, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.labelSmall.copyWith(fontSize: 10)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final nutritionRepo = ref.watch(nutritionRepositoryProvider);
    final foods = nutritionRepo.searchFoods(
      query: _searchQuery,
      category: _selectedCategory,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Add to ${widget.mealType.toUpperCase()}'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: TextFormField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                decoration: InputDecoration(
                  hintText: 'Search Roti, Dal, Paneer, Chana, Rice...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Category Chips
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat.$1;
                  return FitoraChip(
                    label: cat.$2,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedCategory = cat.$1),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Foods List
            Expanded(
              child: foods.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.restaurant_rounded, size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text('No foods found', style: AppTypography.headingSmall),
                          const SizedBox(height: 4),
                          Text('Try searching for another food or create a custom item.', style: AppTypography.bodySmall),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () => context.push('/custom-food'),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Custom Food'),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: foods.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final food = foods[index];
                        return _buildFoodCard(food);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodCard(Food food) {
    return FitoraCard(
      onTap: () => _showPortionSheet(food),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.carbAccent.withValues(alpha: 0.12),
              borderRadius: AppSpacing.roundedSm,
            ),
            child: const Icon(Icons.restaurant_rounded, color: AppColors.carbAccent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        food.name,
                        style: AppTypography.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (food.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified_rounded, color: AppColors.success, size: 14),
                    ],
                  ],
                ),
                if (food.localName != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    food.localName!,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '${food.servingSize} ${food.servingUnit} • ${food.protein.round()}g P • ${food.carbs.round()}g C • ${food.fat.round()}g F',
                  style: AppTypography.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${food.calories.round()}',
                style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.calorieAccent),
              ),
              Text('kcal', style: AppTypography.labelSmall.copyWith(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
