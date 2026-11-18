import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/workout_repository.dart';
import '../../data/repositories/nutrition_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/health_repository.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/ai_repository.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/user_preferences.dart';
import '../../data/models/fitness_goal.dart';
import '../../data/models/activity_log.dart';
import '../../data/models/food_log.dart';
import '../../data/models/habit.dart';

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository();
});

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  return NutritionRepository();
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository();
});

final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepository();
});

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository();
});

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository();
});

// Auth State
final authStateProvider = StreamProvider<AuthUser?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

// Profile & Preferences State
class UserProfileNotifier extends Notifier<UserProfile?> {
  @override
  UserProfile? build() {
    _loadInitial();
    return ref.watch(userRepositoryProvider).currentProfile;
  }

  Future<void> _loadInitial() async {
    final repo = ref.read(userRepositoryProvider);
    final profile = await repo.fetchProfile('athlete_1');
    if (profile != null) {
      state = profile;
    } else {
      final initial = UserProfile(
        id: 'athlete_1',
        email: 'alex.fitness@example.com',
        fullName: 'Alex Vance',
        dateOfBirth: DateTime(1998, 5, 14),
        gender: 'male',
        heightCm: 175.0,
        currentWeightKg: 74.5,
        targetWeightKg: 70.0,
        preferredUnits: 'metric',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      );
      await repo.saveProfile(initial);
      state = initial;
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    await ref.read(userRepositoryProvider).saveProfile(profile);
    state = profile;
  }
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfile?>(UserProfileNotifier.new);

// User Preferences State
class UserPreferencesNotifier extends Notifier<UserPreferences> {
  @override
  UserPreferences build() {
    _load();
    return ref.watch(userRepositoryProvider).currentPreferences ??
        const UserPreferences(
          id: 'pref_athlete_1',
          userId: 'athlete_1',
          dietaryPreference: 'vegetarian',
          foodAllergies: [],
          workoutPreference: 'gym',
          workoutDurationMinutes: 45,
          availableDaysPerWeek: 4,
          waterTargetMl: 3000,
        );
  }

  Future<void> _load() async {
    final prefs = await ref.read(userRepositoryProvider).fetchPreferences('athlete_1');
    state = prefs;
  }

  Future<void> updatePreferences(UserPreferences prefs) async {
    await ref.read(userRepositoryProvider).savePreferences(prefs);
    state = prefs;
  }
}

final userPreferencesProvider = NotifierProvider<UserPreferencesNotifier, UserPreferences>(UserPreferencesNotifier.new);

// Fitness Goal State
class FitnessGoalNotifier extends Notifier<FitnessGoal> {
  @override
  FitnessGoal build() {
    _load();
    return ref.watch(userRepositoryProvider).currentGoal ??
        const FitnessGoal(
          id: 'goal_athlete_1',
          userId: 'athlete_1',
          goalType: 'fat_loss',
          experienceLevel: 'intermediate',
          targetCalories: 2150,
          targetProteinG: 145,
          targetCarbsG: 220,
          targetFatG: 65,
          targetWaterMl: 3000,
          targetSteps: 10000,
        );
  }

  Future<void> _load() async {
    final goal = await ref.read(userRepositoryProvider).fetchGoal('athlete_1');
    state = goal;
  }

  Future<void> updateGoal(FitnessGoal goal) async {
    await ref.read(userRepositoryProvider).saveGoal(goal);
    state = goal;
  }
}

final fitnessGoalProvider = NotifierProvider<FitnessGoalNotifier, FitnessGoal>(FitnessGoalNotifier.new);

// Today Activity
class TodayActivityNotifier extends Notifier<ActivityLog> {
  @override
  ActivityLog build() {
    return ref.watch(healthRepositoryProvider).getTodayActivity();
  }

  Future<void> addSteps(int steps) async {
    final repo = ref.read(healthRepositoryProvider);
    await repo.updateTodayActivity(
      addSteps: steps,
      addCaloriesBurned: (steps * 0.04).round(),
    );
    state = repo.getTodayActivity();
  }

  Future<void> addActiveMinutes(int mins) async {
    final repo = ref.read(healthRepositoryProvider);
    await repo.updateTodayActivity(
      addActiveMinutes: mins,
      addCaloriesBurned: mins * 7,
    );
    state = repo.getTodayActivity();
  }
}

final todayActivityProvider = NotifierProvider<TodayActivityNotifier, ActivityLog>(TodayActivityNotifier.new);

// Today Water
class TodayWaterNotifier extends Notifier<int> {
  @override
  int build() {
    return ref.watch(healthRepositoryProvider).getTodayWaterMl();
  }

  Future<void> addWater(int amountMl) async {
    final repo = ref.read(healthRepositoryProvider);
    await repo.addWater(amountMl);
    state = repo.getTodayWaterMl();
  }
}

final todayWaterProvider = NotifierProvider<TodayWaterNotifier, int>(TodayWaterNotifier.new);

// Nutrition Selected Date
class SelectedNutritionDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) => state = date;
}

final selectedNutritionDateProvider =
    NotifierProvider<SelectedNutritionDateNotifier, DateTime>(SelectedNutritionDateNotifier.new);

// Nutrition Logs
class NutritionLogsNotifier extends Notifier<List<FoodLog>> {
  @override
  List<FoodLog> build() {
    final repo = ref.watch(nutritionRepositoryProvider);
    final date = ref.watch(selectedNutritionDateProvider);
    return repo.getLogsForDate(date);
  }

  Future<void> addLog(FoodLog log) async {
    final repo = ref.read(nutritionRepositoryProvider);
    await repo.addFoodLog(log);
    final date = ref.read(selectedNutritionDateProvider);
    state = repo.getLogsForDate(date);
  }

  Future<void> deleteLog(String logId) async {
    final repo = ref.read(nutritionRepositoryProvider);
    await repo.deleteFoodLog(logId);
    final date = ref.read(selectedNutritionDateProvider);
    state = repo.getLogsForDate(date);
  }
}

final nutritionLogsProvider = NotifierProvider<NutritionLogsNotifier, List<FoodLog>>(NutritionLogsNotifier.new);

// Habits State
class HabitsListNotifier extends Notifier<List<Habit>> {
  @override
  List<Habit> build() {
    return ref.watch(habitRepositoryProvider).getHabits();
  }

  Future<void> toggleHabit(String id) async {
    final repo = ref.read(habitRepositoryProvider);
    await repo.toggleHabit(id);
    state = repo.getHabits();
  }

  Future<void> addHabit(Habit habit) async {
    final repo = ref.read(habitRepositoryProvider);
    await repo.addHabit(habit);
    state = repo.getHabits();
  }

  Future<void> deleteHabit(String id) async {
    final repo = ref.read(habitRepositoryProvider);
    await repo.deleteHabit(id);
    state = repo.getHabits();
  }
}

final habitsListProvider = NotifierProvider<HabitsListNotifier, List<Habit>>(HabitsListNotifier.new);
