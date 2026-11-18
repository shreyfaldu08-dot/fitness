-- ==============================================================================
-- FITORA INITIAL SEED DATA
-- Verified Exercise Catalog & Verified Indian Food Nutrition Items
-- ==============================================================================

-- 1. SEED EXERCISES
INSERT INTO public.exercises (id, name, category, target_muscle, secondary_muscles, equipment, difficulty, instructions, default_sets, default_reps, rest_seconds, safety_guidance)
VALUES
('ex_chest_bench_press', 'Barbell Flat Bench Press', 'chest', 'Pectoralis Major', ARRAY['Triceps Brachii', 'Anterior Deltoids'], 'barbell', 'intermediate', 'Lie flat on bench. Grip bar slightly wider than shoulder width. Lower bar smoothly to mid-chest, then press upwards to lockout.', 4, 8, 120, 'Never bounce the bar off ribcage. Maintain natural lumbar arch and keep wrists neutral.'),
('ex_chest_incline_db_press', 'Incline Dumbbell Press', 'chest', 'Upper Pectorals', ARRAY['Anterior Deltoids', 'Triceps'], 'dumbbell', 'intermediate', 'Set bench to 30-45 degrees. Press dumbbells upwards while angling elbows 45-60 degrees from torso.', 3, 10, 90, 'Avoid flaring elbows 90 degrees outward to safeguard rotator cuff.'),
('ex_chest_pushups', 'Standard Push-ups', 'chest', 'Pectoralis Major', ARRAY['Triceps', 'Core'], 'bodyweight', 'beginner', 'Plank posture with braced core. Lower chest to 2 inches off floor, explode upwards.', 3, 15, 60, 'Do not allow hips to sag.'),
('ex_back_deadlift', 'Conventional Barbell Deadlift', 'back', 'Erector Spinae & Lats', ARRAY['Glutes', 'Hamstrings', 'Trapezius'], 'barbell', 'advanced', 'Feet hip-width apart. Hinge at hips to grip bar. Extend hips and knees synchronously until standing tall.', 4, 5, 150, 'Maintain a rigid neutral spine. Do not round back under load.'),
('ex_back_lat_pulldown', 'Wide-Grip Lat Pulldown', 'back', 'Latissimus Dorsi', ARRAY['Biceps', 'Rhomboids'], 'cable', 'beginner', 'Grip bar wider than shoulder width. Drive elbows down towards ribcage until bar touches upper chest.', 4, 10, 90, 'Do not pull behind neck or swing torso excessively.'),
('ex_back_barbell_row', 'Bent-Over Barbell Row', 'back', 'Middle Trapezius & Rhomboids', ARRAY['Lats', 'Posterior Deltoids', 'Biceps'], 'barbell', 'intermediate', 'Hinge torso to 45 degrees. Pull bar to lower abdomen while driving elbows high.', 4, 8, 90, 'Brace core tightly to protect lumbar spine.'),
('ex_shoulders_overhead_press', 'Overhead Barbell Press', 'shoulders', 'Anterior & Lateral Deltoids', ARRAY['Triceps', 'Upper Chest'], 'barbell', 'intermediate', 'Press bar from clavicle vertically overhead until locked out above crown of head.', 4, 8, 120, 'Do not hyper-extend lower back.'),
('ex_shoulders_lateral_raise', 'Dumbbell Lateral Raise', 'shoulders', 'Lateral Deltoids', ARRAY['Trapezius'], 'dumbbell', 'beginner', 'Raise dumbbells outwards in scapular plane to shoulder level. Control negative.', 4, 12, 60, 'Lead with elbows rather than hands.'),
('ex_biceps_barbell_curl', 'Barbell Bicep Curl', 'biceps', 'Biceps Brachii', ARRAY['Brachialis', 'Forearms'], 'barbell', 'beginner', 'Pin elbows to torso. Curl bar upwards, contract peak, lower under 3-second negative.', 3, 10, 75, 'Do not rock hips or heave weights with back momentum.'),
('ex_triceps_rope_pushdown', 'Cable Rope Pushdown', 'triceps', 'Lateral & Medial Triceps', ARRAY['Anconeus'], 'cable', 'beginner', 'Pin elbows at sides. Extend elbows straight down, spreading rope tips apart at bottom.', 3, 12, 60, 'Keep upper arms completely stationary.'),
('ex_legs_barbell_squat', 'Barbell Back Squat', 'legs', 'Quadriceps & Gluteus Maximus', ARRAY['Hamstrings', 'Calves', 'Spinal Erectors'], 'barbell', 'intermediate', 'Rest bar on upper traps. Squat down until thighs are parallel to ground. Drive up through mid-foot.', 4, 8, 150, 'Track knees in line with toes, prevent valgus knee collapse.'),
('ex_legs_romanian_deadlift', 'Romanian Deadlift (RDL)', 'legs', 'Hamstrings & Glutes', ARRAY['Erector Spinae'], 'barbell', 'intermediate', 'Soften knees. Push hips straight back until deep hamstring stretch is felt. Extend hips to return.', 3, 10, 90, 'Hinge at hips, do not round lumbar spine.'),
('ex_abs_hanging_leg_raise', 'Hanging Leg / Knee Raise', 'abs', 'Rectus Abdominis (Lower)', ARRAY['Hip Flexors', 'Obliques'], 'bodyweight', 'intermediate', 'Hang from bar with zero momentum swing. Curl knees/legs towards chest height, lower slowly.', 3, 12, 60, 'Curl pelvis forward at apex for direct abdominal stimulus.'),
('ex_abs_plank', 'Forearm Plank', 'abs', 'Core & Transverse Abdominis', ARRAY['Glutes', 'Deltoids'], 'bodyweight', 'beginner', 'Maintain horizontal body alignment from head to heels on forearms and toes. Squeeze glutes.', 3, 45, 60, 'Do not allow hips to sag downward.'),
('ex_cardio_jump_rope', 'Speed Jump Rope Intervals', 'cardio', 'Cardiovascular System', ARRAY['Calves', 'Forearms'], 'cardio', 'beginner', 'Light bounding on balls of feet. Turn rope with wrist motion.', 5, 60, 30, 'Jump only 1-2 inches off floor to protect joints.')
ON CONFLICT (id) DO NOTHING;

-- 2. SEED VERIFIED FOODS (Indian Staples & High-Protein Essentials)
INSERT INTO public.foods (id, name, local_name, category, serving_size, serving_unit, calories, protein, carbs, fat, fiber, is_vegetarian, is_vegan, is_verified)
VALUES
('food_roti_wheat', 'Whole Wheat Roti / Chapati', 'गेहूं की रोटी (फुल्का)', 'grains', 1.0, 'roti (35g dough)', 85.0, 3.1, 17.2, 0.5, 2.3, true, true, true),
('food_roti_bajra', 'Bajra Roti (Pearl Millet)', 'बाजरे की रोटी', 'grains', 1.0, 'roti (50g)', 115.0, 3.5, 21.0, 1.6, 3.2, true, true, true),
('food_thepla_methi', 'Methi Thepla', 'मेथी थेपला', 'grains', 1.0, 'thepla (45g)', 125.0, 3.8, 18.5, 4.2, 2.8, true, false, true),
('food_rice_basmati', 'Steamed Basmati Rice', 'उबले हुए चावल', 'grains', 150.0, 'g (1 katori cooked)', 195.0, 4.2, 43.5, 0.4, 0.8, true, true, true),
('food_rice_brown', 'Steamed Brown Rice', 'ब्राउन राइस', 'grains', 150.0, 'g (1 katori cooked)', 168.0, 4.0, 35.0, 1.4, 2.8, true, true, true),
('food_khichdi_moong', 'Moong Dal Khichdi (Homestyle)', 'मूंग दाल खिचड़ी', 'grains', 200.0, 'g (1 bowl)', 230.0, 8.5, 41.0, 3.5, 4.2, true, false, true),
('food_dal_moong_tadka', 'Yellow Moong Dal Tadka', 'मूंग दाल तड़का', 'lentils_legumes', 180.0, 'g (1 katori)', 150.0, 9.2, 21.0, 3.2, 4.5, true, false, true),
('food_dal_toor', 'Toor Dal Fry', 'तूर दाल फ्राई', 'lentils_legumes', 180.0, 'g (1 katori)', 165.0, 8.8, 23.5, 4.1, 4.8, true, false, true),
('food_rajma_curry', 'Rajma Masala (Kidney Beans)', 'राजमा मसाला करी', 'lentils_legumes', 200.0, 'g (1 cup cooked)', 220.0, 12.4, 34.0, 4.5, 8.5, true, true, true),
('food_chana_masala', 'Chole / Chickpeas Curry', 'काबुली चना मसाला', 'lentils_legumes', 200.0, 'g (1 cup cooked)', 240.0, 11.8, 38.0, 5.2, 8.0, true, true, true),
('food_kala_chana_boiled', 'Boiled Black Chana', 'उबला हुआ काला चना', 'lentils_legumes', 100.0, 'g (1 katori)', 164.0, 9.8, 27.0, 2.6, 7.6, true, true, true),
('food_sprouts_salad', 'Sprouted Moong Salad', 'अंकुरित मूंग सलाद', 'lentils_legumes', 120.0, 'g (1 bowl)', 110.0, 8.6, 18.0, 0.8, 5.2, true, true, true),
('food_soya_chunks', 'Soya Chunks (Dry Measured)', 'सोया बड़ी', 'lentils_legumes', 50.0, 'g', 172.0, 26.0, 16.5, 0.5, 6.5, true, true, true),
('food_paneer_raw', 'Fresh Cow Milk Paneer', 'देसी पनीर', 'dairy', 100.0, 'g', 265.0, 18.3, 3.4, 20.8, 0.0, true, false, true),
('food_paneer_lowfat', 'Low Fat / Skim Milk Paneer', 'कम वसा वाला पनीर', 'dairy', 100.0, 'g', 160.0, 25.0, 4.5, 4.5, 0.0, true, false, true),
('food_curd_dahi', 'Curd / Plain Dahi (Homestyle)', 'ताज़ा दही', 'dairy', 150.0, 'g (1 katori)', 98.0, 5.4, 6.8, 5.0, 0.0, true, false, true),
('food_greek_yogurt', 'Plain Greek Yogurt (Unsweetened)', 'ग्रीक योगर्ट', 'dairy', 150.0, 'g (1 cup)', 105.0, 15.0, 5.2, 2.5, 0.0, true, false, true),
('food_milk_toned', 'Cow Milk (Toned)', 'गाय का दूध', 'dairy', 200.0, 'ml (1 glass)', 120.0, 6.4, 9.6, 6.0, 0.0, true, false, true),
('food_chaas_buttermilk', 'Spiced Buttermilk (Chaas)', 'मसाला छाछ', 'dairy', 250.0, 'ml (1 tall glass)', 45.0, 2.8, 4.5, 1.5, 0.3, true, false, true),
('food_poha', 'Poha with Peanuts', 'कांदा पोहा', 'breakfast', 180.0, 'g (1 plate)', 220.0, 4.8, 38.0, 5.8, 3.2, true, true, true),
('food_idli_steamed', 'Steamed Rice Idli', 'इडली', 'breakfast', 2.0, 'pieces (80g)', 128.0, 4.2, 27.0, 0.4, 1.8, true, true, true),
('food_dosa_plain', 'Crispy Plain Dosa', 'सादा डोसा', 'breakfast', 1.0, 'dosa (90g)', 170.0, 4.0, 29.0, 4.2, 1.5, true, true, true),
('food_besan_chilla', 'Besan Chilla', 'बेसन का चीला', 'breakfast', 1.0, 'chilla (70g)', 135.0, 6.8, 18.0, 4.5, 3.4, true, true, true),
('food_moong_chilla', 'Moong Dal Chilla', 'मूंग दाल का चीला', 'breakfast', 1.0, 'chilla (80g)', 145.0, 9.5, 20.0, 3.2, 4.1, true, true, true),
('food_bhindi_masala', 'Bhindi Masala (Okra)', 'भिंडी मसाला', 'vegetables', 150.0, 'g (1 katori)', 110.0, 2.8, 12.0, 6.0, 4.5, true, true, true),
('food_palak_paneer', 'Palak Paneer', 'पालक पनीर', 'vegetables', 200.0, 'g (1 bowl)', 225.0, 12.5, 9.0, 16.0, 4.0, true, false, true),
('food_banana', 'Banana (Medium)', 'केला', 'fruits', 1.0, 'fruit (110g)', 100.0, 1.2, 25.0, 0.3, 3.0, true, true, true),
('food_apple', 'Fresh Crisp Apple', 'सेब', 'fruits', 1.0, 'fruit (140g)', 75.0, 0.4, 19.0, 0.2, 3.5, true, true, true),
('food_papaya', 'Fresh Diced Papaya', 'पपीता', 'fruits', 150.0, 'g (1 cup)', 65.0, 0.8, 16.0, 0.4, 2.8, true, true, true),
('food_egg_whole', 'Whole Boiled Egg', 'उबला हुआ अंडा', 'meat_eggs', 1.0, 'egg (50g)', 74.0, 6.3, 0.4, 5.0, 0.0, false, false, true),
('food_egg_white', 'Boiled Egg White', 'अंडे का सफेद भाग', 'meat_eggs', 1.0, 'egg white (33g)', 17.0, 3.6, 0.2, 0.1, 0.0, false, false, true),
('food_chicken_breast', 'Grilled Chicken Breast', 'ग्रिल्ड चिकन ब्रेस्ट', 'meat_eggs', 100.0, 'g', 165.0, 31.0, 0.0, 3.6, 0.0, false, false, true),
('food_whey_protein', 'Whey Protein Isolate', 'व्हे प्रोटीन', 'snacks', 1.0, 'scoop (30g)', 120.0, 25.0, 1.5, 1.0, 0.0, true, false, true),
('food_almonds', 'Raw California Almonds', 'बादाम', 'snacks', 15.0, 'g (12-14 nuts)', 88.0, 3.2, 3.0, 7.5, 1.8, true, true, true)
ON CONFLICT (id) DO NOTHING;
