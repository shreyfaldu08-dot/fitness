import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/fitora_button.dart';
import '../../../core/widgets/fitora_text_field.dart';
import '../../../data/models/food.dart';

class CustomFoodScreen extends ConsumerStatefulWidget {
  const CustomFoodScreen({super.key});

  @override
  ConsumerState<CustomFoodScreen> createState() => _CustomFoodScreenState();
}

class _CustomFoodScreenState extends ConsumerState<CustomFoodScreen> {
  final _nameController = TextEditingController();
  final _localNameController = TextEditingController();
  final _servingUnitController = TextEditingController(text: 'g');
  final _servingSizeController = TextEditingController(text: '100');
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController(text: '0');
  bool _isVeg = true;

  @override
  void dispose() {
    _nameController.dispose();
    _localNameController.dispose();
    _servingUnitController.dispose();
    _servingSizeController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomFood() async {
    final name = _nameController.text.trim();
    final calories = double.tryParse(_caloriesController.text.trim());
    if (name.isEmpty || calories == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter food name and calories')),
      );
      return;
    }

    final newFood = Food(
      id: 'custom_${const Uuid().v4()}',
      name: name,
      localName: _localNameController.text.trim().isNotEmpty ? _localNameController.text.trim() : null,
      category: 'custom',
      servingSize: double.tryParse(_servingSizeController.text.trim()) ?? 100,
      servingUnit: _servingUnitController.text.trim(),
      calories: calories,
      protein: double.tryParse(_proteinController.text.trim()) ?? 0,
      carbs: double.tryParse(_carbsController.text.trim()) ?? 0,
      fat: double.tryParse(_fatController.text.trim()) ?? 0,
      fiber: double.tryParse(_fiberController.text.trim()) ?? 0,
      isVegetarian: _isVeg,
      isVerified: false,
    );

    final nutritionRepo = ref.read(nutritionRepositoryProvider);
    await nutritionRepo.addCustomFood(newFood);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved "${newFood.name}" to database!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Custom Food'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FitoraTextField(
                controller: _nameController,
                label: 'Food Item Name',
                hintText: 'e.g. Sattu Drink, Oats Protein Smoothie',
              ),
              const SizedBox(height: AppSpacing.md),

              FitoraTextField(
                controller: _localNameController,
                label: 'Local / Hindi Name (Optional)',
                hintText: 'e.g. सत्तू शर्बत',
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: FitoraTextField(
                      controller: _servingSizeController,
                      label: 'Serving Size',
                      hintText: '100',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FitoraTextField(
                      controller: _servingUnitController,
                      label: 'Unit',
                      hintText: 'g, ml, bowl',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              FitoraTextField(
                controller: _caloriesController,
                label: 'Calories (kcal) per serving',
                hintText: 'e.g. 250',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: FitoraTextField(
                      controller: _proteinController,
                      label: 'Protein (g)',
                      hintText: '0',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FitoraTextField(
                      controller: _carbsController,
                      label: 'Carbs (g)',
                      hintText: '0',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FitoraTextField(
                      controller: _fatController,
                      label: 'Fat (g)',
                      hintText: '0',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Vegetarian Item'),
                value: _isVeg,
                activeTrackColor: AppColors.primary,
                onChanged: (val) => setState(() => _isVeg = val),
              ),
              const SizedBox(height: AppSpacing.xl),

              FitoraButton(
                label: 'Save Food to Library',
                icon: const Icon(Icons.save_rounded, color: Colors.white),
                onPressed: _saveCustomFood,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
