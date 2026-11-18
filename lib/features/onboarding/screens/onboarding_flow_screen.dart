import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/fitness_calculator.dart';
import '../../../core/widgets/fitora_button.dart';
import '../../../core/widgets/fitora_card.dart';
import '../../../core/widgets/fitora_chip.dart';
import '../../../core/widgets/fitora_text_field.dart';
import '../../../data/models/fitness_goal.dart';
import '../../../data/models/user_preferences.dart';
import '../../../data/models/user_profile.dart';

class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Step 1: Personal Info
  final _nameController = TextEditingController(text: 'Alex Vance');
  DateTime _dob = DateTime(1998, 6, 15);
  String _gender = 'male'; // male, female, other
  double _heightCm = 175.0;
  double _weightKg = 74.0;
  double _targetWeightKg = 70.0;

  // Step 2: Fitness Goals
  FitnessGoalType _goalType = FitnessGoalType.fatLoss;
  String _experienceLevel = 'intermediate'; // beginner, intermediate, advanced
  ActivityLevelType _activityLevel = ActivityLevelType.moderatelyActive;
  String _workoutPreference = 'gym'; // gym, home, hybrid
  int _workoutDays = 4;
  int _workoutDuration = 45;

  // Step 3: Nutrition & Habits
  String _dietaryPreference = 'vegetarian'; // vegetarian, vegan, eggetarian, non_vegetarian
  String _cookingTime = 'standard_30m';
  String _budget = 'moderate';
  double _sleepHours = 8.0;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  int get _calculatedAge => FitnessCalculator.calculateAge(_dob);

  GenderType get _mappedGenderType {
    if (_gender == 'male') return GenderType.male;
    if (_gender == 'female') return GenderType.female;
    return GenderType.preferNotToSay;
  }

  MacroTargets get _calculatedMacros => FitnessCalculator.calculateMacroTargets(
        weightKg: _weightKg,
        heightCm: _heightCm,
        age: _calculatedAge,
        gender: _mappedGenderType,
        activityLevel: _activityLevel,
        goal: _goalType,
      );

  double get _calculatedBmi => FitnessCalculator.calculateBmi(
        weightKg: _weightKg,
        heightCm: _heightCm,
      );

  Future<void> _completeOnboarding() async {
    final userRepo = ref.read(userRepositoryProvider);
    final userProfileNotifier = ref.read(userProfileProvider.notifier);
    final userPrefsNotifier = ref.read(userPreferencesProvider.notifier);
    final fitnessGoalNotifier = ref.read(fitnessGoalProvider.notifier);

    final macros = _calculatedMacros;

    final profile = UserProfile(
      id: 'athlete_1',
      email: 'athlete@fitora.app',
      fullName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Athlete',
      dateOfBirth: _dob,
      gender: _gender,
      heightCm: _heightCm,
      currentWeightKg: _weightKg,
      targetWeightKg: _targetWeightKg,
      preferredUnits: 'metric',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final prefs = UserPreferences(
      id: 'pref_athlete_1',
      userId: 'athlete_1',
      dietaryPreference: _dietaryPreference,
      workoutPreference: _workoutPreference,
      workoutDurationMinutes: _workoutDuration,
      availableDaysPerWeek: _workoutDays,
      sleepTargetHours: _sleepHours,
      waterTargetMl: macros.waterMl,
      cookingAvailability: _cookingTime,
      dailyBudget: _budget,
    );

    final goal = FitnessGoal(
      id: 'goal_athlete_1',
      userId: 'athlete_1',
      goalType: _goalType.name == 'fatLoss'
          ? 'fat_loss'
          : (_goalType.name == 'muscleGain' ? 'muscle_gain' : _goalType.name),
      experienceLevel: _experienceLevel,
      activityLevel: _activityLevel.name,
      targetCalories: macros.calories,
      targetProteinG: macros.proteinGrams,
      targetCarbsG: macros.carbsGrams,
      targetFatG: macros.fatGrams,
      targetWaterMl: macros.waterMl,
      targetSteps: 10000,
    );

    await userProfileNotifier.updateProfile(profile);
    await userPrefsNotifier.updatePreferences(prefs);
    await fitnessGoalNotifier.updateGoal(goal);
    await userRepo.setOnboardingCompleted(true);

    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Step ${_currentStep + 1} of $_totalSteps',
          style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
        ),
        centerTitle: true,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () => setState(() => _currentStep--),
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Linear Progress Indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / _totalSteps,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: _buildCurrentStepContent(),
              ),
            ),
            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: FitoraButton(
                label: _currentStep == _totalSteps - 1 ? 'Start Your Journey' : 'Next Step',
                onPressed: () {
                  if (_currentStep < _totalSteps - 1) {
                    setState(() => _currentStep++);
                  } else {
                    _completeOnboarding();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1PersonalInfo();
      case 1:
        return _buildStep2FitnessProfile();
      case 2:
        return _buildStep3NutritionAndHabits();
      case 3:
      default:
        return _buildStep4PlanSummary();
    }
  }

  // --- STEP 1: PERSONAL INFO ---
  Widget _buildStep1PersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Personal Profile', style: AppTypography.headingLarge),
        const SizedBox(height: 6),
        Text('We use these metrics to calculate your precise metabolic baselines.',
            style: AppTypography.bodySmall),
        const SizedBox(height: AppSpacing.xl),

        FitoraTextField(
          controller: _nameController,
          label: 'What should we call you?',
          hintText: 'Your Name',
          prefixIcon: const Icon(Icons.badge_outlined, size: 20),
        ),
        const SizedBox(height: AppSpacing.lg),

        Text('Gender', style: AppTypography.labelMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FitoraChip(
                label: 'Male',
                isSelected: _gender == 'male',
                onTap: () => setState(() => _gender = 'male'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FitoraChip(
                label: 'Female',
                isSelected: _gender == 'female',
                onTap: () => setState(() => _gender = 'female'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FitoraChip(
                label: 'Other',
                isSelected: _gender == 'other',
                onTap: () => setState(() => _gender = 'other'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // DOB Picker Tile
        Text('Date of Birth', style: AppTypography.labelMedium),
        const SizedBox(height: 8),
        FitoraCard(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _dob,
              firstDate: DateTime(1940),
              lastDate: DateTime.now().subtract(const Duration(days: 365 * 12)),
            );
            if (picked != null) {
              setState(() => _dob = picked);
            }
          },
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.cake_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Text('${_dob.day}/${_dob.month}/${_dob.year}', style: AppTypography.bodyMedium),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: AppSpacing.roundedSm,
                ),
                child: Text('Age: $_calculatedAge yrs',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Height Slider
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Height', style: AppTypography.labelMedium),
            Text('${_heightCm.round()} cm', style: AppTypography.labelLarge.copyWith(color: AppColors.primary)),
          ],
        ),
        Slider(
          value: _heightCm,
          min: 130,
          max: 220,
          divisions: 90,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border,
          onChanged: (val) => setState(() => _heightCm = val),
        ),
        const SizedBox(height: AppSpacing.md),

        // Weight Slider
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Current Weight', style: AppTypography.labelMedium),
            Text('${_weightKg.toStringAsFixed(1)} kg',
                style: AppTypography.labelLarge.copyWith(color: AppColors.primary)),
          ],
        ),
        Slider(
          value: _weightKg,
          min: 40,
          max: 160,
          divisions: 240,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border,
          onChanged: (val) => setState(() => _weightKg = val),
        ),
        const SizedBox(height: AppSpacing.md),

        // Target Weight Slider
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Target Weight Goal', style: AppTypography.labelMedium),
            Text('${_targetWeightKg.toStringAsFixed(1)} kg',
                style: AppTypography.labelLarge.copyWith(color: AppColors.success)),
          ],
        ),
        Slider(
          value: _targetWeightKg,
          min: 40,
          max: 160,
          divisions: 240,
          activeColor: AppColors.success,
          inactiveColor: AppColors.border,
          onChanged: (val) => setState(() => _targetWeightKg = val),
        ),
      ],
    );
  }

  // --- STEP 2: FITNESS PROFILE ---
  Widget _buildStep2FitnessProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fitness Objectives', style: AppTypography.headingLarge),
        const SizedBox(height: 6),
        Text('Select your primary focus so we calibrate volume and caloric targets.',
            style: AppTypography.bodySmall),
        const SizedBox(height: AppSpacing.xl),

        Text('Primary Goal', style: AppTypography.labelMedium),
        const SizedBox(height: 8),
        _buildSelectableCard(
          title: 'Fat Loss & Leaning',
          subtitle: 'Moderate calorie deficit with high protein to preserve muscle tone.',
          isSelected: _goalType == FitnessGoalType.fatLoss,
          onTap: () => setState(() => _goalType = FitnessGoalType.fatLoss),
        ),
        const SizedBox(height: 8),
        _buildSelectableCard(
          title: 'Muscle Gain & Hypertrophy',
          subtitle: 'Caloric surplus with progressive overload to build lean mass.',
          isSelected: _goalType == FitnessGoalType.muscleGain,
          onTap: () => setState(() => _goalType = FitnessGoalType.muscleGain),
        ),
        const SizedBox(height: 8),
        _buildSelectableCard(
          title: 'Strength & Power',
          subtitle: 'Compound movement focus to maximize force output.',
          isSelected: _goalType == FitnessGoalType.strength,
          onTap: () => setState(() => _goalType = FitnessGoalType.strength),
        ),
        const SizedBox(height: 8),
        _buildSelectableCard(
          title: 'Healthy Maintenance',
          subtitle: 'Maintain weight, enhance longevity, mobility, and cardiovascular health.',
          isSelected: _goalType == FitnessGoalType.maintenance,
          onTap: () => setState(() => _goalType = FitnessGoalType.maintenance),
        ),
        const SizedBox(height: AppSpacing.lg),

        Text('Training Experience', style: AppTypography.labelMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FitoraChip(
                label: 'Beginner',
                isSelected: _experienceLevel == 'beginner',
                onTap: () => setState(() => _experienceLevel = 'beginner'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FitoraChip(
                label: 'Intermediate',
                isSelected: _experienceLevel == 'intermediate',
                onTap: () => setState(() => _experienceLevel = 'intermediate'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FitoraChip(
                label: 'Advanced',
                isSelected: _experienceLevel == 'advanced',
                onTap: () => setState(() => _experienceLevel = 'advanced'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        Text('Preferred Workout Location', style: AppTypography.labelMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FitoraChip(
                label: 'Gym Equipment',
                icon: const Icon(Icons.fitness_center_rounded, size: 16),
                isSelected: _workoutPreference == 'gym',
                onTap: () => setState(() => _workoutPreference = 'gym'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FitoraChip(
                label: 'Home / Bodyweight',
                icon: const Icon(Icons.home_rounded, size: 16),
                isSelected: _workoutPreference == 'home',
                onTap: () => setState(() => _workoutPreference = 'home'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Workout Days / Week', style: AppTypography.labelMedium),
            Text('$_workoutDays Days', style: AppTypography.labelLarge.copyWith(color: AppColors.primary)),
          ],
        ),
        Slider(
          value: _workoutDays.toDouble(),
          min: 2,
          max: 6,
          divisions: 4,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border,
          onChanged: (val) => setState(() => _workoutDays = val.round()),
        ),
      ],
    );
  }

  // --- STEP 3: NUTRITION & HABITS ---
  Widget _buildStep3NutritionAndHabits() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nutrition & Lifestyle', style: AppTypography.headingLarge),
        const SizedBox(height: 6),
        Text('Tailor diet preferences, cooking frequency, and rest habits.',
            style: AppTypography.bodySmall),
        const SizedBox(height: AppSpacing.xl),

        Text('Dietary Lifestyle', style: AppTypography.labelMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FitoraChip(
              label: 'Vegetarian (शाकाहारी)',
              isSelected: _dietaryPreference == 'vegetarian',
              onTap: () => setState(() => _dietaryPreference = 'vegetarian'),
            ),
            FitoraChip(
              label: 'Eggetarian',
              isSelected: _dietaryPreference == 'eggetarian',
              onTap: () => setState(() => _dietaryPreference = 'eggetarian'),
            ),
            FitoraChip(
              label: 'Non-Vegetarian',
              isSelected: _dietaryPreference == 'non_vegetarian',
              onTap: () => setState(() => _dietaryPreference = 'non_vegetarian'),
            ),
            FitoraChip(
              label: 'Vegan',
              isSelected: _dietaryPreference == 'vegan',
              onTap: () => setState(() => _dietaryPreference = 'vegan'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        Text('Cooking Availability', style: AppTypography.labelMedium),
        const SizedBox(height: 8),
        _buildSelectableCard(
          title: 'Quick & Practical (15-20 min)',
          subtitle: 'Simple Indian meals: Khichdi, Poha, Chilla, Dal Tadka.',
          isSelected: _cookingTime == 'quick_15m',
          onTap: () => setState(() => _cookingTime = 'quick_15m'),
        ),
        const SizedBox(height: 8),
        _buildSelectableCard(
          title: 'Standard (30-45 min)',
          subtitle: 'Fresh Roti, Subzi, Dal, and Rice homestyle prep.',
          isSelected: _cookingTime == 'standard_30m',
          onTap: () => setState(() => _cookingTime = 'standard_30m'),
        ),
        const SizedBox(height: AppSpacing.lg),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Sleep Target (Hours)', style: AppTypography.labelMedium),
            Text('${_sleepHours.toStringAsFixed(1)} hrs',
                style: AppTypography.labelLarge.copyWith(color: AppColors.primary)),
          ],
        ),
        Slider(
          value: _sleepHours,
          min: 6.0,
          max: 10.0,
          divisions: 8,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border,
          onChanged: (val) => setState(() => _sleepHours = val),
        ),
      ],
    );
  }

  // --- STEP 4: PLAN SUMMARY & DISCLAIMER ---
  Widget _buildStep4PlanSummary() {
    final macros = _calculatedMacros;
    final bmi = _calculatedBmi;
    final bmiCategory = FitnessCalculator.getBmiCategory(bmi);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: AppSpacing.roundedSm,
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your personalized baseline has been calculated!',
                  style: AppTypography.labelLarge.copyWith(color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        Text('Initial Fitness Profile', style: AppTypography.headingLarge),
        const SizedBox(height: AppSpacing.md),

        // BMI & Metrics Card
        FitoraCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Body Mass Index (BMI)', style: AppTypography.labelMedium),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('$bmi', style: AppTypography.statDisplay.copyWith(fontSize: 26)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius: AppSpacing.roundedSm,
                            ),
                            child: Text(
                              bmiCategory,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Daily Calories', style: AppTypography.labelMedium),
                      const SizedBox(height: 4),
                      Text('${macros.calories} kcal',
                          style: AppTypography.statDisplay
                              .copyWith(fontSize: 26, color: AppColors.calorieAccent)),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),

              // Macro Split Breakdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMacroColumn('Protein', '${macros.proteinGrams}g', AppColors.proteinAccent),
                  _buildMacroColumn('Carbs', '${macros.carbsGrams}g', AppColors.carbAccent),
                  _buildMacroColumn('Fats', '${macros.fatGrams}g', AppColors.fatAccent),
                  _buildMacroColumn('Water', '${macros.waterMl / 1000}L', AppColors.waterAccent),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Training Summary
        FitoraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Training Schedule Blueprint', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              Text(
                '$_workoutDays days per week • $_workoutDuration min per session • $_workoutPreference focus',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Dietary framework: ${_dietaryPreference.replaceAll('_', ' ').toUpperCase()}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Medical & Algorithmic Disclaimer (as specifically required by Section 5 & 11)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.warningLight,
            borderRadius: AppSpacing.roundedMd,
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppConstants.medicalDisclaimer,
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFF78350F),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _buildMacroColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: AppTypography.labelLarge.copyWith(color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.labelSmall),
      ],
    );
  }

  Widget _buildSelectableCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FitoraCard(
      onTap: onTap,
      color: isSelected ? AppColors.primaryLight : Colors.white,
      border: Border.all(
        color: isSelected ? AppColors.primary : AppColors.border,
        width: isSelected ? 1.8 : 1,
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: isSelected ? AppColors.primary : AppColors.textMuted,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLarge.copyWith(
                    color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.bodySmall.copyWith(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
