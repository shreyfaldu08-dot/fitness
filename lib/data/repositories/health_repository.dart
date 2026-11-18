import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/supabase_service.dart';
import '../models/activity_log.dart';
import '../models/water_log.dart';

class HealthRepository {
  List<ActivityLog> _activities = [];
  List<SleepLog> _sleepLogs = [];
  List<WaterLog> _waterLogs = [];

  HealthRepository() {
    _loadLocalCache();
  }

  void _loadLocalCache() {
    final now = DateTime.now();

    // Activities
    final storedAct = StorageService.getJson('fitora_activities');
    if (storedAct is List) {
      _activities = storedAct.map((a) => ActivityLog.fromJson(a as Map<String, dynamic>)).toList();
    } else {
      _activities = [
        ActivityLog(
          id: 'act_today',
          userId: 'athlete_1',
          loggedDate: now,
          steps: 7420,
          activeMinutes: 38,
          caloriesBurned: 420,
          isDeviceData: false,
        ),
      ];
    }

    // Sleep
    final storedSleep = StorageService.getJson('fitora_sleep_logs');
    if (storedSleep is List) {
      _sleepLogs = storedSleep.map((s) => SleepLog.fromJson(s as Map<String, dynamic>)).toList();
    } else {
      _sleepLogs = [
        SleepLog(
          id: 'sleep_1',
          userId: 'athlete_1',
          loggedDate: now.subtract(const Duration(days: 1)),
          durationHours: 7.8,
          qualityRating: 4,
          bedTime: '23:15',
          wakeTime: '07:05',
          notes: 'Woke up feeling recovered and rested.',
        ),
        SleepLog(
          id: 'sleep_2',
          userId: 'athlete_1',
          loggedDate: now.subtract(const Duration(days: 2)),
          durationHours: 7.2,
          qualityRating: 4,
          bedTime: '23:30',
          wakeTime: '06:45',
        ),
      ];
    }

    // Water
    final storedWater = StorageService.getJson('fitora_water_logs');
    if (storedWater is List) {
      _waterLogs = storedWater.map((w) => WaterLog.fromJson(w as Map<String, dynamic>)).toList();
    } else {
      _waterLogs = [
        WaterLog(
          id: 'w_1',
          userId: 'athlete_1',
          amountMl: 500,
          loggedAt: now.subtract(const Duration(hours: 4)),
        ),
        WaterLog(
          id: 'w_2',
          userId: 'athlete_1',
          amountMl: 500,
          loggedAt: now.subtract(const Duration(hours: 2)),
        ),
        WaterLog(
          id: 'w_3',
          userId: 'athlete_1',
          amountMl: 250,
          loggedAt: now.subtract(const Duration(minutes: 40)),
        ),
      ];
    }
  }

  ActivityLog getTodayActivity() {
    final now = DateTime.now();
    try {
      return _activities.firstWhere(
        (a) => a.loggedDate.year == now.year && a.loggedDate.month == now.month && a.loggedDate.day == now.day,
      );
    } catch (_) {
      final newAct = ActivityLog(
        id: const Uuid().v4(),
        userId: 'athlete_1',
        loggedDate: now,
        steps: 0,
        activeMinutes: 0,
        caloriesBurned: 0,
      );
      _activities.add(newAct);
      return newAct;
    }
  }

  Future<void> updateTodayActivity({int? addSteps, int? addActiveMinutes, int? addCaloriesBurned}) async {
    final current = getTodayActivity();
    final updated = current.copyWith(
      steps: addSteps != null ? current.steps + addSteps : current.steps,
      activeMinutes: addActiveMinutes != null ? current.activeMinutes + addActiveMinutes : current.activeMinutes,
      caloriesBurned: addCaloriesBurned != null ? current.caloriesBurned + addCaloriesBurned : current.caloriesBurned,
    );

    final idx = _activities.indexWhere((a) => a.id == current.id);
    if (idx >= 0) {
      _activities[idx] = updated;
    } else {
      _activities.add(updated);
    }
    await StorageService.setJson('fitora_activities', _activities.map((a) => a.toJson()).toList());
  }

  int getTodayWaterMl() {
    final now = DateTime.now();
    return _waterLogs
        .where((w) => w.loggedAt.year == now.year && w.loggedAt.month == now.month && w.loggedAt.day == now.day)
        .fold(0, (sum, w) => sum + w.amountMl);
  }

  Future<void> addWater(int amountMl) async {
    final log = WaterLog(
      id: const Uuid().v4(),
      userId: 'athlete_1',
      amountMl: amountMl,
      loggedAt: DateTime.now(),
    );
    _waterLogs.insert(0, log);
    await StorageService.setJson('fitora_water_logs', _waterLogs.map((w) => w.toJson()).toList());

    if (!SupabaseService.isOfflineMode && SupabaseService.client != null) {
      try {
        await SupabaseService.client!.from('water_logs').upsert(log.toJson());
      } catch (e) {
        debugPrint('[HealthRepository] Add water log error: $e');
      }
    }
  }

  List<SleepLog> getSleepLogs() {
    _sleepLogs.sort((a, b) => b.loggedDate.compareTo(a.loggedDate));
    return _sleepLogs;
  }

  Future<void> logSleep(SleepLog sleep) async {
    _sleepLogs.insert(0, sleep);
    await StorageService.setJson('fitora_sleep_logs', _sleepLogs.map((s) => s.toJson()).toList());

    if (!SupabaseService.isOfflineMode && SupabaseService.client != null) {
      try {
        await SupabaseService.client!.from('sleep_logs').upsert(sleep.toJson());
      } catch (e) {
        debugPrint('[HealthRepository] Log sleep error: $e');
      }
    }
  }
}
