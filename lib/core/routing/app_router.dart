import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/screens/welcome_screen.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/signup_screen.dart';
import '../../features/authentication/screens/forgot_password_screen.dart';
import '../../features/onboarding/screens/onboarding_flow_screen.dart';
import '../../features/shell/main_scaffold_screen.dart';
import '../../features/workouts/screens/exercise_library_screen.dart';
import '../../features/workouts/screens/exercise_detail_screen.dart';
import '../../features/workouts/screens/active_workout_screen.dart';
import '../../features/workouts/screens/workout_plan_builder_screen.dart';
import '../../features/workouts/screens/multi_week_planner_screen.dart';
import '../../features/workouts/screens/workout_history_screen.dart';
import '../../features/nutrition/screens/food_search_screen.dart';
import '../../features/nutrition/screens/meal_planner_screen.dart';
import '../../features/nutrition/screens/custom_food_screen.dart';
import '../../features/progress/screens/photo_comparison_screen.dart';
import '../../features/ai_assistant/screens/ai_assistant_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/habits/screens/habits_screen.dart';
import '../../features/health/screens/health_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../data/models/exercise.dart';
import '../../data/models/workout_plan.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  AppRouter._();

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: _determineInitialLocation(),
    routes: [
      // Authentication Routes
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot_password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Onboarding Route
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingFlowScreen(),
      ),

      // Main Shell Tab Routes
      GoRoute(
        path: '/',
        name: 'main',
        builder: (context, state) {
          final tabIndexStr = state.uri.queryParameters['tab'];
          final initialIndex = tabIndexStr != null ? int.tryParse(tabIndexStr) ?? 0 : 0;
          return MainScaffoldScreen(initialTabIndex: initialIndex);
        },
      ),

      // Workout Sub-routes
      GoRoute(
        path: '/exercises',
        name: 'exercises',
        builder: (context, state) {
          final category = state.uri.queryParameters['category'];
          return ExerciseLibraryScreen(initialCategory: category);
        },
      ),
      GoRoute(
        path: '/exercise-detail',
        name: 'exercise_detail',
        builder: (context, state) {
          final exercise = state.extra as Exercise?;
          return ExerciseDetailScreen(exercise: exercise);
        },
      ),
      GoRoute(
        path: '/workout-builder',
        name: 'workout_builder',
        builder: (context, state) {
          final existingPlan = state.extra as WorkoutPlan?;
          return WorkoutPlanBuilderScreen(existingPlan: existingPlan);
        },
      ),
      GoRoute(
        path: '/multi-week-planner',
        name: 'multi_week_planner',
        builder: (context, state) => const MultiWeekPlannerScreen(),
      ),
      GoRoute(
        path: '/active-workout',
        name: 'active_workout',
        builder: (context, state) {
          final plan = state.extra as WorkoutPlan?;
          return ActiveWorkoutScreen(plan: plan);
        },
      ),
      GoRoute(
        path: '/workout-history',
        name: 'workout_history',
        builder: (context, state) => const WorkoutHistoryScreen(),
      ),

      // Nutrition Sub-routes
      GoRoute(
        path: '/food-search',
        name: 'food_search',
        builder: (context, state) {
          final mealType = state.uri.queryParameters['mealType'] ?? 'lunch';
          return FoodSearchScreen(mealType: mealType);
        },
      ),
      GoRoute(
        path: '/meal-planner',
        name: 'meal_planner',
        builder: (context, state) => const MealPlannerScreen(),
      ),
      GoRoute(
        path: '/custom-food',
        name: 'custom_food',
        builder: (context, state) => const CustomFoodScreen(),
      ),

      // Progress & Photos
      GoRoute(
        path: '/photo-comparison',
        name: 'photo_comparison',
        builder: (context, state) => const PhotoComparisonScreen(),
      ),

      // AI Assistant
      GoRoute(
        path: '/ai-coach',
        name: 'ai_coach',
        builder: (context, state) => const AiAssistantScreen(),
      ),

      // Analytics & Reports
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),

      // Habits
      GoRoute(
        path: '/habits',
        name: 'habits',
        builder: (context, state) => const HabitsScreen(),
      ),

      // Health & Sleep
      GoRoute(
        path: '/health',
        name: 'health',
        builder: (context, state) => const HealthScreen(),
      ),

      // Profile Edit
      GoRoute(
        path: '/edit-profile',
        name: 'edit_profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
  );

  static String _determineInitialLocation() {
    // Allows immediate direct access to the main dashboard without requiring sign-in
    return '/';
  }
}
