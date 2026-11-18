# FITORA — Personal Fitness & Wellness Application

FITORA is a personal fitness, nutrition, and wellness mobile application built with Flutter, Riverpod, Supabase (PostgreSQL, Auth, Storage), and FL Chart.

Inspired by **Apple Health**, **Whoop**, and **Nike Training Club**, FITORA delivers a personal health experience featuring active workout tracking with rest timers, verified Indian nutrition data, body transformation analytics, habit streak tracking, and an intelligent evidence-based AI fitness assistant.

---

## 📱 Core Feature Modules

### 1. Multi-Step Personalized Onboarding
- **Personal Profiling**: Captures name, biological sex, date of birth (calculates exact chronological age), height, current weight, and target weight.
- **Fitness Objectives**: Calibrates for Fat Loss, Muscle Gain (Hypertrophy), Strength & Power, Endurance, or Healthy Maintenance.
- **Dietary & Lifestyle Context**: Tailors to Vegetarian, Vegan, Eggetarian, or Non-Vegetarian diets; integrates cooking availability and daily food budget.
- **Algorithmic Baseline**: Computes BMI category, Basal Metabolic Rate (BMR via Mifflin-St Jeor formula), Total Daily Energy Expenditure (TDEE), target daily calories, macronutrient distribution (Protein, Carbohydrates, Fats), and daily hydration volume.
- **Clear Health Disclaimers**: Prominently communicates that calorie, macro, and energy targets are algorithmic estimates designed for guidance, not medical prescriptions.

### 2. Personalized Home Dashboard
- **Dynamic Greeting Header**: Personalized athlete greeting, current date, and daily motivation.
- **Daily Activity Rings**: Real-time progress on steps, active minutes, and estimated calories burned.
- **Nutrition Summary Card**: Live breakdown of calories consumed vs target, remaining energy, and visual linear progress across Protein, Carbs, and Fats.
- **Hydration Tracker**: Current intake vs daily goal with quick-add buttons (+250 ml, +500 ml).
- **Today's Workout Preview**: Direct access to scheduled routine with exercise counts, estimated time, and a 1-tap "Start Workout" button.
- **Interactive Daily Habits**: Horizontal habit completion cards with streak badges.
- **Transformation Snapshot**: Current weight and delta against starting baseline.

### 3. Workout Management & Active Session Logger
- **Comprehensive Exercise Library**: Categorized across **9 muscle groups** (Chest, Back, Shoulders, Biceps, Triceps, Legs & Glutes, Abs & Core, Cardio, Full Body) with verified instructions, target and secondary muscles, equipment tags, and safety advisories.
- **Structured Training Plans**: Pre-built plans for Beginner Full Body, Intermediate Upper Hypertrophy, Lower Body Power, and Metabolic HIIT circuits.
- **Custom Workout Builder**: Interactive plan authoring with exercise multi-selection, reordering, custom sets, reps, rest intervals, and target weights.
- **Dedicated Active Workout Session**:
  - Live stopwatch tracking total session duration with pause/resume functionality.
  - Interactive set logger with target vs actual kg and repetition inputs.
  - Set completion checkmarks that dynamically update total volume lifted.
  - Real-time countdown Rest Timer with automatic launch on set completion, +30s extensions, and skip options.
  - Workout completion modal calculating total volume moved (kg), duration, and completed sets, seamlessly updating daily activity statistics.
- **Workout History**: Historical logs with duration, volume progression, and personal records.

### 4. Nutrition Tracking & Indian Food Database
- **Searchable Verified Food Database**: Prioritizes Indian staple foods with verified ICMR/IFCT and USDA nutritional values:
  - *Grains & Rotis*: Whole Wheat Chapati, Bajra Roti, Jowar Roti, Methi Thepla, Steamed Basmati Rice, Brown Rice, Moong Dal Khichdi.
  - *Dals & Legumes*: Yellow Moong Dal Tadka, Toor Dal, Rajma Masala, Chana Masala, Boiled Kala Chana, Sprouted Moong Salad, Soya Chunks.
  - *Dairy*: Fresh Cow Milk Paneer, Low-Fat Paneer, Dahi (Curd), Greek Yogurt, Toned Milk, Spiced Chaas (Buttermilk).
  - *Breakfast*: Poha with Peanuts, Steamed Rice Idli, Plain Dosa, Besan Chilla, High-Protein Moong Dal Chilla, Oats Upma.
  - *Vegetables, Fruits & Proteins*: Bhindi Masala, Palak Paneer, Banana, Apple, Papaya, Boiled Eggs, Egg Whites, Grilled Chicken Breast, Whey Protein Isolate, Almonds.
- **Portion Size Calculator**: Modal sheet allowing fractional and multiple servings with live macronutrient calculations.
- **Meal Organization**: Food logs segmented into Breakfast, Lunch, Dinner, and Snacks.
- **Smart Meal Blueprint**: Weekly Indian meal plans with practical, nutritionally similar meal-swap suggestions.
- **Custom Food Creation**: Allows users to input and save unique recipes and custom food items.

### 5. Body Progress Tracking & Analytics
- **Metric Entry Logger**: Daily or weekly weight, waist, chest, hip, arm, and thigh circumference entries.
- **Interactive FL Chart**: Smooth Bézier line chart with customizable 7-day, 30-day, and 90-day filters.
- **Biological Fluctuation Guidance**: Informs users about natural day-to-day 0.5–2.0 kg shifts caused by sodium, water retention, glycogen storage, and muscular inflammation.
- **Progress Photo Comparison**: Private side-by-side photo comparison slider.

### 6. Health, Sleep & Recovery
- **Sleep Quality Tracking**: Sleep duration (hours), sleep quality rating (1–5 stars), bedtime, and wake time.
- **Wearable Device Integration Layer**: Support for Android Health Connect and Apple Health, clearly distinguishing verified device readings from manual entries.

### 7. Habit Tracking & Streaks
- Configurable habits across hydration, steps, protein, sleep, workout sessions, and mindfulness.
- Consecutive streak tracking (🔥 current and best streaks) and daily completion consistency rates.

### 8. Intelligent AI Fitness Assistant (FITORA Coach)
- **Contextual Intelligence**: Fully aware of the user's current weight, BMI, target calories, dietary preferences (vegetarian, vegan, non-veg), and today's logged calories and water.
- **Clinical & Evidence-Based Guardrails**:
  - Explicitly states estimates and general guidance boundaries.
  - Never diagnoses diseases or prescribes pharmaceutical medications.
  - Rejects dangerous starvation diets or extreme dehydration practices.
- **Backend Architecture**: Ready for OpenAI API integration with secure parameter passing, combined with an intelligent local sports nutrition engine when operating offline.

### 9. Analytics & Long-Term Reports
- Weekly and monthly performance summaries covering workout frequency, total volume lifted (kg), average daily calories, protein adherence, and habit consistency.
- Interactive Bar Charts displaying training consistency across the week.
- Actionable, evidence-based recommendations generated from actual user data.

---

## 🏗 Architecture & Codebase Structure

FITORA follows Clean Architecture principles with feature-based modular packaging:

```
lib/
├── core/
│   ├── constants/        # AppColors, AppTypography, AppSpacing, AppConstants
│   ├── theme/            # AppTheme (Material 3 light theme with soft neutral palette)
│   ├── routing/          # GoRouter configuration with route guards and sub-routes
│   ├── services/         # SupabaseService, StorageService, AiService
│   ├── providers/        # Riverpod Notifier & State providers
│   ├── widgets/          # Reusable UI Kit (FitoraButton, FitoraCard, FitoraProgressRing, etc.)
│   └── utils/            # FitnessCalculator (Mifflin-St Jeor BMR, TDEE, BMI), DateFormatter
│
├── data/
│   ├── models/           # Domain models with full JSON serialization
│   ├── seed/             # 22+ verified exercises and 40+ verified Indian & global foods
│   └── repositories/     # Auth, User, Workout, Nutrition, Progress, Health, Habit, AI repos
│
├── features/
│   ├── authentication/   # Welcome, Login, Sign Up, Forgot Password
│   ├── onboarding/       # 4-step interactive onboarding & plan generator
│   ├── dashboard/        # Greeting, Activity rings, Macros, Hydration, Workout preview
│   ├── workouts/         # Exercise library, Detail view, Builder, Active session logger, History
│   ├── nutrition/        # Daily tracker, Search & portion sheet, Meal planner, Custom food
│   ├── progress/         # Weight & measurement trends with FL Chart, Photo comparison
│   ├── health/           # Sleep logger, Hydration, Health Connect sync status
│   ├── habits/           # Streak tracking and habit manager
│   ├── ai_assistant/     # FITORA Coach interactive chat interface
│   ├── analytics/        # Weekly/Monthly charts & actionable insights
│   ├── profile/          # Athlete settings, metric/imperial toggle, data export, sign out
│   └── shell/            # MainScaffoldScreen with custom 5-tab bottom navigation bar
│
└── main.dart             # Application entry point with ProviderScope and local persistence init
```

---

## 🗄 Supabase Database & Security (PostgreSQL)

Complete production migrations and Row Level Security policies are located in `supabase/migrations/`:

1. **`01_initial_schema.sql`**:
   - Creates 14 normalized tables: `profiles`, `user_preferences`, `fitness_goals`, `exercises`, `workout_plans`, `workout_sessions`, `foods`, `food_logs`, `body_measurements`, `water_logs`, `activity_logs`, `sleep_logs`, `habits`, and `ai_messages`.
   - Incorporates primary keys, foreign key constraints cascading to `auth.users(id)`, and performance B-Tree indexes on `(user_id, logged_at)`, `(user_id, started_at)`, etc.
2. **`02_rls_policies.sql`**:
   - Enables Row Level Security on all tables.
   - Enforces strict data isolation: Users can only read, insert, update, or delete their own private fitness and medical metrics (`auth.uid() = user_id`).
   - Grants public read access only to global reference catalogs (`exercises`, verified `foods`, pre-set templates).
3. **`03_seed_data.sql`**:
   - Populates database with 22+ compound and isolation exercises and 40+ verified Indian staple foods with exact caloric and macronutrient values.

---

## 🚀 Setup & Execution Guide

### Prerequisites
- Flutter SDK (v3.27+ or v3.47+)
- Dart SDK (v3.6+ or v3.13+)

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure Environment (Optional)
Copy `.env.example` to configure Supabase and OpenAI credentials:
```bash
cp .env.example .env
```
Or pass configuration variables directly via `--dart-define` when building or running:
```bash
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-key --dart-define=OPENAI_API_KEY=your-ai-key
```

> **Offline-First Resilience**: If Supabase or OpenAI credentials are not provided or network is unreachable, FITORA automatically and seamlessly engages its persistent local storage engine with verified seed libraries, ensuring 100% of the UI, logging, calculators, and workouts operate smoothly without errors!

### 3. Run Analysis & Verification
```bash
dart analyze
flutter test
```

### 4. Launch Application
To run on your connected device, Chrome, or Windows desktop:
```bash
flutter run -d chrome
```

---

## 🛡 Privacy & Medical Disclaimer

FITORA adheres to strict privacy-by-design standards. Nutritional, workout, and photographic data are strictly isolated per authenticated user. Calorie calculations and fitness targets generated by the Mifflin-St Jeor and TDEE formulas are intended as starting estimates and educational tools. Users are guided to consult qualified healthcare professionals before undertaking intensive diet or exercise protocols.
