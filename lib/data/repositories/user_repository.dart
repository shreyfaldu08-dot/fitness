import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/supabase_service.dart';
import '../models/user_profile.dart';
import '../models/user_preferences.dart';
import '../models/fitness_goal.dart';

class UserRepository {
  UserProfile? _cachedProfile;
  UserPreferences? _cachedPreferences;
  FitnessGoal? _cachedGoal;

  UserProfile? get currentProfile => _cachedProfile;
  UserPreferences? get currentPreferences => _cachedPreferences;
  FitnessGoal? get currentGoal => _cachedGoal;

  Future<UserProfile?> fetchProfile(String userId) async {
    // 1. Try Supabase
    if (!SupabaseService.isOfflineMode && SupabaseService.client != null) {
      try {
        final res = await SupabaseService.client!
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();
        if (res != null) {
          _cachedProfile = UserProfile.fromJson(res);
          await StorageService.setJson(AppConstants.keyUserProfile, _cachedProfile!.toJson());
          return _cachedProfile;
        }
      } catch (e) {
        debugPrint('[UserRepository] Fetch profile from Supabase error: $e');
      }
    }

    // 2. Fallback to local storage
    final localJson = StorageService.getJson(AppConstants.keyUserProfile);
    if (localJson != null) {
      _cachedProfile = UserProfile.fromJson(localJson as Map<String, dynamic>);
      return _cachedProfile;
    }

    return null;
  }

  Future<void> saveProfile(UserProfile profile) async {
    _cachedProfile = profile;
    await StorageService.setJson(AppConstants.keyUserProfile, profile.toJson());

    if (!SupabaseService.isOfflineMode && SupabaseService.client != null) {
      try {
        await SupabaseService.client!.from('profiles').upsert(profile.toJson());
      } catch (e) {
        debugPrint('[UserRepository] Upsert profile to Supabase error: $e');
      }
    }
  }

  Future<UserPreferences> fetchPreferences(String userId) async {
    if (!SupabaseService.isOfflineMode && SupabaseService.client != null) {
      try {
        final res = await SupabaseService.client!
            .from('user_preferences')
            .select()
            .eq('user_id', userId)
            .maybeSingle();
        if (res != null) {
          _cachedPreferences = UserPreferences.fromJson(res);
          await StorageService.setJson(AppConstants.keyUserPreferences, _cachedPreferences!.toJson());
          return _cachedPreferences!;
        }
      } catch (e) {
        debugPrint('[UserRepository] Fetch preferences from Supabase error: $e');
      }
    }

    final localJson = StorageService.getJson(AppConstants.keyUserPreferences);
    if (localJson != null) {
      _cachedPreferences = UserPreferences.fromJson(localJson as Map<String, dynamic>);
      return _cachedPreferences!;
    }

    _cachedPreferences = UserPreferences(id: 'pref_$userId', userId: userId);
    return _cachedPreferences!;
  }

  Future<void> savePreferences(UserPreferences prefs) async {
    _cachedPreferences = prefs;
    await StorageService.setJson(AppConstants.keyUserPreferences, prefs.toJson());

    if (!SupabaseService.isOfflineMode && SupabaseService.client != null) {
      try {
        await SupabaseService.client!.from('user_preferences').upsert(prefs.toJson());
      } catch (e) {
        debugPrint('[UserRepository] Upsert preferences to Supabase error: $e');
      }
    }
  }

  Future<FitnessGoal> fetchGoal(String userId) async {
    if (!SupabaseService.isOfflineMode && SupabaseService.client != null) {
      try {
        final res = await SupabaseService.client!
            .from('fitness_goals')
            .select()
            .eq('user_id', userId)
            .maybeSingle();
        if (res != null) {
          _cachedGoal = FitnessGoal.fromJson(res);
          await StorageService.setJson('fitora_fitness_goal', _cachedGoal!.toJson());
          return _cachedGoal!;
        }
      } catch (e) {
        debugPrint('[UserRepository] Fetch goal from Supabase error: $e');
      }
    }

    final localJson = StorageService.getJson('fitora_fitness_goal');
    if (localJson != null) {
      _cachedGoal = FitnessGoal.fromJson(localJson as Map<String, dynamic>);
      return _cachedGoal!;
    }

    _cachedGoal = FitnessGoal(
      id: 'goal_$userId',
      userId: userId,
      targetCalories: 2100,
      targetProteinG: 135,
      targetCarbsG: 230,
      targetFatG: 65,
    );
    return _cachedGoal!;
  }

  Future<void> saveGoal(FitnessGoal goal) async {
    _cachedGoal = goal;
    await StorageService.setJson('fitora_fitness_goal', goal.toJson());

    if (!SupabaseService.isOfflineMode && SupabaseService.client != null) {
      try {
        await SupabaseService.client!.from('fitness_goals').upsert(goal.toJson());
      } catch (e) {
        debugPrint('[UserRepository] Upsert goal to Supabase error: $e');
      }
    }
  }

  bool isOnboardingCompleted() {
    return StorageService.getBool(AppConstants.keyOnboardingComplete) ?? false;
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await StorageService.setBool(AppConstants.keyOnboardingComplete, completed);
  }
}
