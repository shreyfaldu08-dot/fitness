import '../../core/services/storage_service.dart';
import '../models/habit.dart';

class HabitRepository {
  List<Habit> _habits = [];

  HabitRepository() {
    _loadLocalCache();
  }

  void _loadLocalCache() {
    final stored = StorageService.getJson('fitora_habits');
    if (stored is List) {
      _habits = stored.map((h) => Habit.fromJson(h as Map<String, dynamic>)).toList();
    } else {
      _habits = const [
        Habit(
          id: 'hab_1',
          userId: 'athlete_1',
          title: 'Daily Hydration (3L)',
          description: 'Drink at least 3,000 ml of pure water throughout the day.',
          category: 'water',
          targetValue: 3000,
          unit: 'ml',
          currentStreak: 6,
          bestStreak: 14,
          isCompletedToday: false,
        ),
        Habit(
          id: 'hab_2',
          userId: 'athlete_1',
          title: '10,000 Steps Target',
          description: 'Stay active through brisk walking and daily movement.',
          category: 'steps',
          targetValue: 10000,
          unit: 'steps',
          currentStreak: 4,
          bestStreak: 12,
          isCompletedToday: false,
        ),
        Habit(
          id: 'hab_3',
          userId: 'athlete_1',
          title: 'Daily Protein Target',
          description: 'Hit target protein grams through whole foods or whey.',
          category: 'nutrition',
          targetValue: 140,
          unit: 'g',
          currentStreak: 5,
          bestStreak: 9,
          isCompletedToday: true,
        ),
        Habit(
          id: 'hab_4',
          userId: 'athlete_1',
          title: '7.5+ Hours Quality Sleep',
          description: 'Keep regular bedtime and wind down without blue light.',
          category: 'sleep',
          targetValue: 8,
          unit: 'hrs',
          currentStreak: 3,
          bestStreak: 10,
          isCompletedToday: true,
        ),
        Habit(
          id: 'hab_5',
          userId: 'athlete_1',
          title: 'Scheduled Workout Session',
          description: 'Complete resistance training or cardio session.',
          category: 'workout',
          targetValue: 1,
          unit: 'session',
          currentStreak: 2,
          bestStreak: 7,
          isCompletedToday: false,
        ),
      ];
      _persist();
    }
  }

  List<Habit> getHabits() => List.unmodifiable(_habits);

  Future<void> toggleHabit(String id) async {
    final idx = _habits.indexWhere((h) => h.id == id);
    if (idx >= 0) {
      final current = _habits[idx];
      final newStatus = !current.isCompletedToday;
      final newStreak = newStatus ? current.currentStreak + 1 : (current.currentStreak > 0 ? current.currentStreak - 1 : 0);
      final newBest = newStreak > current.bestStreak ? newStreak : current.bestStreak;

      _habits[idx] = current.copyWith(
        isCompletedToday: newStatus,
        currentStreak: newStreak,
        bestStreak: newBest,
      );
      await _persist();
    }
  }

  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
    await _persist();
  }

  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    await _persist();
  }

  Future<void> _persist() async {
    await StorageService.setJson('fitora_habits', _habits.map((h) => h.toJson()).toList());
  }
}
