import 'package:flutter/foundation.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/supabase_service.dart';
import '../models/body_measurement.dart';

class ProgressRepository {
  List<BodyMeasurement> _measurements = [];

  ProgressRepository() {
    _loadLocalCache();
  }

  void _loadLocalCache() {
    final stored = StorageService.getJson('fitora_body_measurements');
    if (stored is List) {
      _measurements = stored
          .map((m) => BodyMeasurement.fromJson(m as Map<String, dynamic>))
          .toList();
    } else {
      // Seed initial history so user sees realistic progress charts immediately
      final now = DateTime.now();
      _measurements = [
        BodyMeasurement(
          id: 'meas_init_1',
          userId: 'athlete_1',
          loggedDate: now.subtract(const Duration(days: 28)),
          weightKg: 73.8,
          heightCm: 172,
          bmi: 24.9,
          waistCm: 86.0,
          chestCm: 99.0,
          hipCm: 98.0,
          armCm: 34.0,
          thighCm: 57.0,
          notes: 'Initial starting measurement',
        ),
        BodyMeasurement(
          id: 'meas_init_2',
          userId: 'athlete_1',
          loggedDate: now.subtract(const Duration(days: 21)),
          weightKg: 73.1,
          heightCm: 172,
          bmi: 24.7,
          waistCm: 85.5,
          chestCm: 99.2,
          hipCm: 97.5,
          armCm: 34.2,
          thighCm: 56.8,
        ),
        BodyMeasurement(
          id: 'meas_init_3',
          userId: 'athlete_1',
          loggedDate: now.subtract(const Duration(days: 14)),
          weightKg: 72.4,
          heightCm: 172,
          bmi: 24.5,
          waistCm: 84.8,
          chestCm: 99.5,
          hipCm: 97.0,
          armCm: 34.5,
          thighCm: 56.5,
        ),
        BodyMeasurement(
          id: 'meas_init_4',
          userId: 'athlete_1',
          loggedDate: now.subtract(const Duration(days: 7)),
          weightKg: 71.9,
          heightCm: 172,
          bmi: 24.3,
          waistCm: 84.0,
          chestCm: 100.0,
          hipCm: 96.5,
          armCm: 34.8,
          thighCm: 56.2,
        ),
        BodyMeasurement(
          id: 'meas_init_5',
          userId: 'athlete_1',
          loggedDate: now,
          weightKg: 71.2,
          heightCm: 172,
          bmi: 24.1,
          waistCm: 83.2,
          chestCm: 100.5,
          hipCm: 96.0,
          armCm: 35.0,
          thighCm: 56.0,
          notes: 'Great energy levels, waist down 2.8cm total!',
        ),
      ];
      _persist();
    }
  }

  List<BodyMeasurement> getMeasurements() {
    _measurements.sort((a, b) => b.loggedDate.compareTo(a.loggedDate));
    return _measurements;
  }

  BodyMeasurement? getLatestMeasurement() {
    final list = getMeasurements();
    return list.isNotEmpty ? list.first : null;
  }

  Future<void> logMeasurement(BodyMeasurement measurement) async {
    _measurements.insert(0, measurement);
    await _persist();

    if (!SupabaseService.isOfflineMode && SupabaseService.client != null) {
      try {
        await SupabaseService.client!.from('body_measurements').upsert(measurement.toJson());
      } catch (e) {
        debugPrint('[ProgressRepository] Upsert measurement to Supabase error: $e');
      }
    }
  }

  Future<void> deleteMeasurement(String id) async {
    _measurements.removeWhere((m) => m.id == id);
    await _persist();

    if (!SupabaseService.isOfflineMode && SupabaseService.client != null) {
      try {
        await SupabaseService.client!.from('body_measurements').delete().eq('id', id);
      } catch (e) {
        debugPrint('[ProgressRepository] Delete measurement error: $e');
      }
    }
  }

  Future<void> _persist() async {
    await StorageService.setJson(
      'fitora_body_measurements',
      _measurements.map((m) => m.toJson()).toList(),
    );
  }
}
