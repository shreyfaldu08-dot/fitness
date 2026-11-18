-- ==============================================================================
-- FITORA ROW LEVEL SECURITY (RLS) POLICIES
-- Complete User Data Isolation and Access Control
-- ==============================================================================

-- 1. Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fitness_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.foods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.food_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.body_measurements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.water_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sleep_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_messages ENABLE ROW LEVEL SECURITY;

-- 2. PROFILES POLICIES
CREATE POLICY "Users can view own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- 3. USER PREFERENCES POLICIES
CREATE POLICY "Users can view own preferences"
    ON public.user_preferences FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert/update own preferences"
    ON public.user_preferences FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- 4. FITNESS GOALS POLICIES
CREATE POLICY "Users can view own fitness goals"
    ON public.fitness_goals FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert/update own fitness goals"
    ON public.fitness_goals FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- 5. EXERCISES POLICIES (Global exercise catalog is readable by all authenticated athletes)
CREATE POLICY "Anyone can view exercise catalog"
    ON public.exercises FOR SELECT
    USING (true);

-- 6. WORKOUT PLANS POLICIES (Templates are readable by all; custom plans only by creator)
CREATE POLICY "Users can view templates and own plans"
    ON public.workout_plans FOR SELECT
    USING (is_template = true OR auth.uid() = user_id);

CREATE POLICY "Users can manage own workout plans"
    ON public.workout_plans FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- 7. WORKOUT SESSIONS POLICIES
CREATE POLICY "Users can manage own workout sessions"
    ON public.workout_sessions FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- 8. FOODS POLICIES (Verified catalog is public read; custom entries are user-specific)
CREATE POLICY "Anyone can view verified foods"
    ON public.foods FOR SELECT
    USING (is_verified = true);

-- 9. FOOD LOGS POLICIES
CREATE POLICY "Users can manage own food logs"
    ON public.food_logs FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- 10. BODY MEASUREMENTS POLICIES
CREATE POLICY "Users can manage own body measurements"
    ON public.body_measurements FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- 11. WATER LOGS POLICIES
CREATE POLICY "Users can manage own water logs"
    ON public.water_logs FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- 12. ACTIVITY LOGS POLICIES
CREATE POLICY "Users can manage own activity logs"
    ON public.activity_logs FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- 13. SLEEP LOGS POLICIES
CREATE POLICY "Users can manage own sleep logs"
    ON public.sleep_logs FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- 14. HABITS POLICIES
CREATE POLICY "Users can manage own habits"
    ON public.habits FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- 15. AI MESSAGES POLICIES
CREATE POLICY "Users can manage own AI messages"
    ON public.ai_messages FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);
