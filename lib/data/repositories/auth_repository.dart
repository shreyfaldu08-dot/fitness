import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/supabase_service.dart';

class AuthUser {
  final String id;
  final String email;
  final String fullName;

  const AuthUser({
    required this.id,
    required this.email,
    required this.fullName,
  });

  Map<String, dynamic> toJson() => {'id': id, 'email': email, 'full_name': fullName};

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String? ?? '',
        email: json['email'] as String? ?? '',
        fullName: json['full_name'] as String? ?? '',
      );
}

class AuthRepository {
  final _authStreamController = StreamController<AuthUser?>.broadcast();
  AuthUser? _currentUser;

  Stream<AuthUser?> get authStateChanges => _authStreamController.stream;
  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  AuthRepository() {
    _initSession();
  }

  Future<void> _initSession() async {
    // 1. Check Supabase session first if connected
    if (!SupabaseService.isOfflineMode && SupabaseService.client != null) {
      final supaUser = SupabaseService.client!.auth.currentUser;
      if (supaUser != null) {
        _currentUser = AuthUser(
          id: supaUser.id,
          email: supaUser.email ?? '',
          fullName: (supaUser.userMetadata?['full_name'] as String?) ?? 'Athlete',
        );
        _authStreamController.add(_currentUser);
        return;
      }
    }

    // 2. Check local stored session
    final storedJson = StorageService.getJson(AppConstants.keyAuthSession);
    if (storedJson != null) {
      _currentUser = AuthUser.fromJson(storedJson as Map<String, dynamic>);
      _authStreamController.add(_currentUser);
    } else {
      // Allow instant access by defaulting to a guest user session
      _currentUser = const AuthUser(
        id: 'athlete_1',
        email: 'alex.vance@example.com',
        fullName: 'Alex Vance',
      );
      _authStreamController.add(_currentUser);
    }
  }

  Future<AuthUser> continueAsGuest() async {
    const guestUser = AuthUser(
      id: 'athlete_1',
      email: 'alex.vance@example.com',
      fullName: 'Alex Vance',
    );
    _currentUser = guestUser;
    await StorageService.setJson(AppConstants.keyAuthSession, guestUser.toJson());
    await StorageService.setBool(AppConstants.keyOnboardingComplete, true);
    _authStreamController.add(_currentUser);
    return guestUser;
  }

  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (!SupabaseService.isOfflineMode && SupabaseService.client != null) {
      try {
        final res = await SupabaseService.client!.auth.signUp(
          email: email,
          password: password,
          data: {'full_name': fullName},
        );
        final user = res.user;
        if (user != null) {
          _currentUser = AuthUser(
            id: user.id,
            email: user.email ?? email,
            fullName: fullName,
          );
          await StorageService.setJson(AppConstants.keyAuthSession, _currentUser!.toJson());
          _authStreamController.add(_currentUser);
          return _currentUser!;
        }
      } catch (e) {
        debugPrint('[AuthRepository] Supabase signup error, continuing locally: $e');
      }
    }

    // Local / Offline Sign up
    final localUser = AuthUser(
      id: const Uuid().v4(),
      email: email,
      fullName: fullName,
    );
    _currentUser = localUser;
    await StorageService.setJson(AppConstants.keyAuthSession, localUser.toJson());
    _authStreamController.add(_currentUser);
    return localUser;
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    if (!SupabaseService.isOfflineMode && SupabaseService.client != null) {
      try {
        final res = await SupabaseService.client!.auth.signInWithPassword(
          email: email,
          password: password,
        );
        final user = res.user;
        if (user != null) {
          final fullName = (user.userMetadata?['full_name'] as String?) ?? 'Athlete';
          _currentUser = AuthUser(
            id: user.id,
            email: user.email ?? email,
            fullName: fullName,
          );
          await StorageService.setJson(AppConstants.keyAuthSession, _currentUser!.toJson());
          _authStreamController.add(_currentUser);
          return _currentUser!;
        }
      } catch (e) {
        debugPrint('[AuthRepository] Supabase login error, falling back locally: $e');
      }
    }

    // Local fallback sign in
    final localUser = AuthUser(
      id: 'local_athlete_${email.hashCode.abs()}',
      email: email,
      fullName: email.split('@').first,
    );
    _currentUser = localUser;
    await StorageService.setJson(AppConstants.keyAuthSession, localUser.toJson());
    _authStreamController.add(_currentUser);
    return localUser;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (!SupabaseService.isOfflineMode && SupabaseService.client != null) {
      try {
        await SupabaseService.client!.auth.resetPasswordForEmail(email);
        return;
      } catch (e) {
        debugPrint('[AuthRepository] Password reset error: $e');
      }
    }
  }

  Future<void> logout() async {
    if (!SupabaseService.isOfflineMode && SupabaseService.client != null) {
      try {
        await SupabaseService.client!.auth.signOut();
      } catch (_) {}
    }
    await StorageService.remove(AppConstants.keyAuthSession);
    _currentUser = null;
    _authStreamController.add(null);
  }

  void dispose() {
    _authStreamController.close();
  }
}
