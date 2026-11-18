import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

class SupabaseService {
  static SupabaseClient? _client;
  static bool _isInitialized = false;
  static bool _isOfflineMode = false;

  static SupabaseClient? get client => _client;
  static bool get isInitialized => _isInitialized;
  static bool get isOfflineMode => _isOfflineMode;

  static Future<void> initialize() async {
    final url = AppConstants.supabaseUrl;
    final anonKey = AppConstants.supabaseAnonKey;

    // Check if real credentials are provided or if running in offline/demo mode
    if (url.contains('placeholder') || anonKey.contains('placeholder') || url.isEmpty || anonKey.isEmpty) {
      debugPrint('[SupabaseService] Running in local/offline storage mode with active local persistence.');
      _isOfflineMode = true;
      _isInitialized = true;
      return;
    }

    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        debug: kDebugMode,
      );
      _client = Supabase.instance.client;
      _isInitialized = true;
      _isOfflineMode = false;
      debugPrint('[SupabaseService] Connected successfully to Supabase: $url');
    } catch (e) {
      debugPrint('[SupabaseService] Initialization failed, falling back to local storage: $e');
      _isOfflineMode = true;
      _isInitialized = true;
    }
  }

  static User? get currentUser => _client?.auth.currentUser;
  static String? get currentUserId => _client?.auth.currentUser?.id;
}
