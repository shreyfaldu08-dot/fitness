class AppConstants {
  AppConstants._();

  static const String appName = 'FITORA';
  static const String appTagline = 'Elevate Your Fitness & Wellness';
  static const String appVersion = '1.0.0';

  // Local Storage Keys
  static const String keyAuthSession = 'fitora_auth_session';
  static const String keyUserProfile = 'fitora_user_profile';
  static const String keyUserPreferences = 'fitora_user_prefs';
  static const String keyOnboardingComplete = 'fitora_onboarding_done';
  static const String keyOfflineMode = 'fitora_offline_mode';
  static const String keyActiveWorkout = 'fitora_active_workout';

  // Default Targets
  static const int defaultWaterGoalMl = 3000;
  static const int defaultStepsGoal = 10000;
  static const int defaultActiveMinutesGoal = 45;
  static const double defaultSleepHoursGoal = 8.0;

  // Supabase Configuration Defaults (Overridable via AppConfig or Env)
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://demo-fitora.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'public-anon-key-fitora-placeholder',
  );

  static const String openAiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  // Motivational Quotes
  static const List<String> motivationalQuotes = [
    'Consistency is the mother of mastery.',
    'Small daily improvements over time lead to stunning results.',
    'Your only limit is you. Push your boundary today.',
    'Fuel your body, feed your drive, focus on progress.',
    'Celebrate every single milestone on your journey.',
    'Strength does not come from what you can do. It comes from overcoming what you once thought you could not.',
    'Every healthy choice is an investment in your future self.',
  ];

  static const String medicalDisclaimer =
      'Calorie and energy targets, BMI, and nutritional insights provided by FITORA are algorithmic estimates designed for general guidance only. Always consult a qualified medical or nutrition professional before starting any intensive diet or workout program.';
}
