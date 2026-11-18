-- ==============================================================================
-- FITORA FITNESS & WELLNESS PLATFORM - DATABASE SCHEMA
-- PostgreSQL via Supabase
-- ==============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. PROFILES TABLE (Extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT NOT NULL,
    date_of_birth DATE,
    gender TEXT CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
    height_cm NUMERIC(5,2) DEFAULT 172.0,
    current_weight_kg NUMERIC(5,2) DEFAULT 70.0,
    target_weight_kg NUMERIC(5,2) DEFAULT 68.0,
    preferred_units TEXT DEFAULT 'metric' CHECK (preferred_units IN ('metric', 'imperial')),
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- 2. USER PREFERENCES TABLE
CREATE TABLE IF NOT EXISTS public.user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    dietary_preference TEXT DEFAULT 'vegetarian' CHECK (dietary_preference IN ('vegetarian', 'vegan', 'eggetarian', 'non_vegetarian')),
    food_allergies TEXT[] DEFAULT ARRAY[]::TEXT[],
    food_dislikes TEXT[] DEFAULT ARRAY[]::TEXT[],
    daily_budget TEXT DEFAULT 'moderate' CHECK (daily_budget IN ('budget', 'moderate', 'premium')),
    cooking_availability TEXT DEFAULT 'standard_30m' CHECK (cooking_availability IN ('quick_15m', 'standard_30m', 'relaxed_60m')),
    workout_preference TEXT DEFAULT 'gym' CHECK (workout_preference IN ('gym', 'home', 'hybrid')),
    workout_duration_minutes INT DEFAULT 45,
    available_days_per_week INT DEFAULT 4,
    sleep_target_hours NUMERIC(3,1) DEFAULT 8.0,
    water_target_ml INT DEFAULT 3000,
    wake_up_time TEXT DEFAULT '06:30',
    bed_time TEXT DEFAULT '22:30',
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    CONSTRAINT unique_user_preferences UNIQUE(user_id)
);

-- 3. FITNESS GOALS TABLE
CREATE TABLE IF NOT EXISTS public.fitness_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    goal_type TEXT DEFAULT 'fat_loss' CHECK (goal_type IN ('fat_loss', 'muscle_gain', 'strength', 'endurance', 'maintenance')),
    experience_level TEXT DEFAULT 'intermediate' CHECK (experience_level IN ('beginner', 'intermediate', 'advanced')),
    activity_level TEXT DEFAULT 'moderately_active' CHECK (activity_level IN ('sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active')),
    target_calories INT NOT NULL DEFAULT 2100,
    target_protein_g INT NOT NULL DEFAULT 140,
    target_carbs_g INT NOT NULL DEFAULT 230,
    target_fat_g INT NOT NULL DEFAULT 65,
    target_water_ml INT DEFAULT 3000,
    target_steps INT DEFAULT 10000,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    CONSTRAINT unique_user_fitness_goal UNIQUE(user_id)
);

-- 4. EXERCISES LIBRARY TABLE (Global catalog & custom additions)
CREATE TABLE IF NOT EXISTS public.exercises (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('chest', 'back', 'shoulders', 'biceps', 'triceps', 'legs', 'abs', 'cardio', 'full_body')),
    target_muscle TEXT NOT NULL,
    secondary_muscles TEXT[] DEFAULT ARRAY[]::TEXT[],
    equipment TEXT NOT NULL CHECK (equipment IN ('barbell', 'dumbbell', 'machine', 'cable', 'bodyweight', 'kettlebell', 'cardio')),
    difficulty TEXT DEFAULT 'intermediate' CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
    instructions TEXT NOT NULL,
    default_sets INT DEFAULT 3,
    default_reps INT DEFAULT 10,
    rest_seconds INT DEFAULT 90,
    safety_guidance TEXT NOT NULL,
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- 5. WORKOUT PLANS TABLE
CREATE TABLE IF NOT EXISTS public.workout_plans (
    id TEXT PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE, -- NULL if global system template
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    level TEXT DEFAULT 'intermediate' CHECK (level IN ('beginner', 'intermediate', 'advanced')),
    days_per_week INT DEFAULT 4,
    estimated_duration_minutes INT DEFAULT 45,
    exercises JSONB DEFAULT '[]'::JSONB NOT NULL,
    is_template BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- 6. WORKOUT SESSIONS TABLE
CREATE TABLE IF NOT EXISTS public.workout_sessions (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    plan_id TEXT REFERENCES public.workout_plans(id) ON DELETE SET NULL,
    workout_name TEXT NOT NULL,
    started_at TIMESTAMPTZ NOT NULL,
    completed_at TIMESTAMPTZ,
    duration_seconds INT DEFAULT 0,
    total_volume_kg NUMERIC(10,2) DEFAULT 0.0,
    sets_completed INT DEFAULT 0,
    exercises_completed INT DEFAULT 0,
    notes TEXT,
    sets JSONB DEFAULT '[]'::JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- 7. FOOD DATABASE TABLE (Indian Staples & Fitness Verified)
CREATE TABLE IF NOT EXISTS public.foods (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    local_name TEXT,
    category TEXT NOT NULL CHECK (category IN ('grains', 'lentils_legumes', 'dairy', 'vegetables', 'fruits', 'snacks', 'breakfast', 'meat_eggs', 'custom')),
    serving_size NUMERIC(6,2) NOT NULL,
    serving_unit TEXT NOT NULL,
    calories NUMERIC(6,2) NOT NULL,
    protein NUMERIC(6,2) NOT NULL,
    carbs NUMERIC(6,2) NOT NULL,
    fat NUMERIC(6,2) NOT NULL,
    fiber NUMERIC(6,2) DEFAULT 0.0,
    is_vegetarian BOOLEAN DEFAULT TRUE,
    is_vegan BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- 8. FOOD LOGS TABLE
CREATE TABLE IF NOT EXISTS public.food_logs (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    food_id TEXT REFERENCES public.foods(id) ON DELETE SET NULL,
    food_name TEXT NOT NULL,
    meal_type TEXT NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
    quantity NUMERIC(5,2) DEFAULT 1.0,
    serving_unit TEXT NOT NULL,
    calories NUMERIC(6,2) NOT NULL,
    protein NUMERIC(6,2) NOT NULL,
    carbs NUMERIC(6,2) NOT NULL,
    fat NUMERIC(6,2) NOT NULL,
    fiber NUMERIC(6,2) DEFAULT 0.0,
    logged_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- 9. BODY MEASUREMENTS TABLE
CREATE TABLE IF NOT EXISTS public.body_measurements (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    logged_date TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    weight_kg NUMERIC(5,2) NOT NULL,
    height_cm NUMERIC(5,2),
    bmi NUMERIC(4,1),
    waist_cm NUMERIC(5,2),
    chest_cm NUMERIC(5,2),
    hip_cm NUMERIC(5,2),
    arm_cm NUMERIC(5,2),
    thigh_cm NUMERIC(5,2),
    photo_url TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- 10. WATER LOGS TABLE
CREATE TABLE IF NOT EXISTS public.water_logs (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    amount_ml INT NOT NULL CHECK (amount_ml > 0),
    logged_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- 11. ACTIVITY LOGS TABLE
CREATE TABLE IF NOT EXISTS public.activity_logs (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    logged_date DATE NOT NULL,
    steps INT DEFAULT 0,
    active_minutes INT DEFAULT 0,
    calories_burned INT DEFAULT 0,
    is_device_data BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    CONSTRAINT unique_user_activity_day UNIQUE(user_id, logged_date)
);

-- 12. SLEEP LOGS TABLE
CREATE TABLE IF NOT EXISTS public.sleep_logs (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    logged_date DATE NOT NULL,
    duration_hours NUMERIC(4,2) NOT NULL,
    quality_rating INT CHECK (quality_rating BETWEEN 1 AND 5),
    bed_time TEXT,
    wake_time TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- 13. HABITS AND HABIT LOGS TABLE
CREATE TABLE IF NOT EXISTS public.habits (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    category TEXT DEFAULT 'general',
    target_value INT DEFAULT 1,
    unit TEXT DEFAULT 'times',
    current_streak INT DEFAULT 0,
    best_streak INT DEFAULT 0,
    is_completed_today BOOLEAN DEFAULT FALSE,
    reminder_time TEXT,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- 14. AI CONVERSATIONS & MESSAGES
CREATE TABLE IF NOT EXISTS public.ai_messages (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,
    suggested_questions TEXT[] DEFAULT ARRAY[]::TEXT[],
    timestamp TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- ==============================================================================
-- PERFORMANCE INDEXES
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_food_logs_user_date ON public.food_logs(user_id, logged_at);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_user_date ON public.workout_sessions(user_id, started_at);
CREATE INDEX IF NOT EXISTS idx_body_measurements_user_date ON public.body_measurements(user_id, logged_date);
CREATE INDEX IF NOT EXISTS idx_water_logs_user_date ON public.water_logs(user_id, logged_at);
CREATE INDEX IF NOT EXISTS idx_activity_logs_user_date ON public.activity_logs(user_id, logged_date);
CREATE INDEX IF NOT EXISTS idx_sleep_logs_user_date ON public.sleep_logs(user_id, logged_date);
CREATE INDEX IF NOT EXISTS idx_foods_category ON public.foods(category);
CREATE INDEX IF NOT EXISTS idx_exercises_category ON public.exercises(category);
