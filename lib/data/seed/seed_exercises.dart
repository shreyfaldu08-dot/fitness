import '../models/exercise.dart';

class SeedExercises {
  SeedExercises._();

  static const List<Exercise> list = [
    // --- CHEST ---
    Exercise(
      id: 'ex_chest_bench_press',
      name: 'Barbell Flat Bench Press',
      category: 'chest',
      targetMuscle: 'Pectoralis Major (Middle & Lower)',
      secondaryMuscles: ['Triceps Brachii', 'Anterior Deltoids'],
      equipment: 'barbell',
      difficulty: 'intermediate',
      instructions:
          'Lie flat on the bench with eyes under the bar. Plant feet firmly. Grip slightly wider than shoulder-width. Retract scapula. Lower bar smoothly to mid-chest, then press forcefully back up to full lockout without bouncing.',
      defaultSets: 4,
      defaultReps: 8,
      restSeconds: 120,
      safetyGuidance:
          'Never bounce the bar off your ribcage. Maintain a natural slight lumbar arch and keep wrists neutral.',
      imageUrl: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=600&auto=format&fit=crop',
      gifUrl: 'https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@v1.1.0/pectorals/barbell-bench-press.gif',
    ),
    Exercise(
      id: 'ex_chest_incline_db_press',
      name: 'Incline Dumbbell Press',
      category: 'chest',
      targetMuscle: 'Clavicular Pectoralis (Upper Chest)',
      secondaryMuscles: ['Anterior Deltoids', 'Triceps'],
      equipment: 'dumbbell',
      difficulty: 'intermediate',
      instructions:
          'Set bench to 30-45 degrees. Kick dumbbells up to shoulder level. Press upwards while keeping elbows angled at roughly 45-60 degrees from torso. Squeeze upper chest at apex, lower with control.',
      defaultSets: 3,
      defaultReps: 10,
      restSeconds: 90,
      safetyGuidance:
          'Avoid flaring elbows 90 degrees outward to protect the rotator cuff tendons.',
      imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=600&auto=format&fit=crop',
      gifUrl: 'https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@v1.1.0/pectorals/dumbbell-incline-bench-press.gif',
    ),
    Exercise(
      id: 'ex_chest_cable_flyes',
      name: 'Standing Cable Flyes',
      category: 'chest',
      targetMuscle: 'Sternal Pectoralis (Inner & Outer Chest)',
      secondaryMuscles: ['Anterior Deltoids'],
      equipment: 'cable',
      difficulty: 'beginner',
      instructions:
          'Set pulleys to chest height. Step forward into a staggered stance with arms outstretched and a slight bend at the elbows. Bring hands together in a hugging motion, squeeze chest for 1 second, control eccentric return.',
      defaultSets: 3,
      defaultReps: 12,
      restSeconds: 60,
      safetyGuidance:
          'Keep your torso stable and avoid swinging your back to initiate movement.',
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=600&auto=format&fit=crop',
      gifUrl: 'https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@v1.1.0/pectorals/cable-standing-fly.gif',
    ),
    Exercise(
      id: 'ex_chest_pushups',
      name: 'Standard Push-ups',
      category: 'chest',
      targetMuscle: 'Pectoralis Major',
      secondaryMuscles: ['Triceps', 'Core Stabilizers', 'Deltoids'],
      equipment: 'bodyweight',
      difficulty: 'beginner',
      instructions:
          'Assume plank position with hands slightly wider than shoulder width. Keep core braced and glutes squeezed. Lower chest until 2 inches off floor, push up explosively.',
      defaultSets: 3,
      defaultReps: 15,
      restSeconds: 60,
      safetyGuidance:
          'Do not let your hips sag toward the ground. Keep your cervical spine neutral.',
      imageUrl: 'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=600&auto=format&fit=crop',
      gifUrl: 'https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@v1.1.0/pectorals/push-up.gif',
    ),

    // --- BACK ---
    Exercise(
      id: 'ex_back_deadlift',
      name: 'Conventional Barbell Deadlift',
      category: 'back',
      targetMuscle: 'Erector Spinae & Latissimus Dorsi',
      secondaryMuscles: ['Gluteus Maximus', 'Hamstrings', 'Trapezius', 'Forearms'],
      equipment: 'barbell',
      difficulty: 'advanced',
      instructions:
          'Stand with feet hip-width, bar over mid-foot. Hinge at hips to grip the bar. Engage lats, pull slack out of the bar, drive through heels while extending hips and knees synchronously until standing upright.',
      defaultSets: 4,
      defaultReps: 5,
      restSeconds: 150,
      safetyGuidance:
          'Maintain a rigid neutral spine. Do not round upper or lower back under load.',
      imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=600&auto=format&fit=crop',
      gifUrl: 'https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@v1.1.0/glutes/barbell-deadlift.gif',
    ),
    Exercise(
      id: 'ex_back_lat_pulldown',
      name: 'Wide-Grip Lat Pulldown',
      category: 'back',
      targetMuscle: 'Latissimus Dorsi',
      secondaryMuscles: ['Biceps Brachii', 'Rhomboids', 'Teres Major'],
      equipment: 'cable',
      difficulty: 'beginner',
      instructions:
          'Secure knees under pads. Grip bar wider than shoulder-width with overhand grip. Lean back slightly (~10°). Drive elbows downward and back towards ribcage until bar touches upper chest. Squeeze lats, return smoothly.',
      defaultSets: 4,
      defaultReps: 10,
      restSeconds: 90,
      safetyGuidance:
          'Do not pull behind your neck. Never use excessive body momentum to jerk the weight down.',
      imageUrl: 'https://images.unsplash.com/photo-1605296867304-46d5465a13f1?w=600&auto=format&fit=crop',
      gifUrl: 'https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@v1.1.0/lats/cable-bar-lateral-pulldown.gif',
    ),
    Exercise(
      id: 'ex_back_barbell_row',
      name: 'Bent-Over Barbell Row',
      category: 'back',
      targetMuscle: 'Middle Trapezius & Rhomboids',
      secondaryMuscles: ['Lats', 'Posterior Deltoids', 'Biceps'],
      equipment: 'barbell',
      difficulty: 'intermediate',
      instructions:
          'Hinge forward at hips until torso is ~45 degrees to the floor with knees soft. Grip bar shoulder-width. Pull bar towards lower abdomen/bellybutton while pulling elbows high. Squeeze shoulder blades together.',
      defaultSets: 4,
      defaultReps: 8,
      restSeconds: 90,
      safetyGuidance:
          'Brace core to protect lower back. Keep neck in neutral alignment with your spine.',
      imageUrl: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=600&auto=format&fit=crop',
      gifUrl: 'https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@v1.1.0/upper-back/barbell-bent-over-row.gif',
    ),

    // --- SHOULDERS ---
    Exercise(
      id: 'ex_shoulders_overhead_press',
      name: 'Standing Overhead Barbell Press (OHP)',
      category: 'shoulders',
      targetMuscle: 'Anterior & Lateral Deltoids',
      secondaryMuscles: ['Triceps', 'Upper Pectorals', 'Core'],
      equipment: 'barbell',
      difficulty: 'intermediate',
      instructions:
          'Rest bar on clavicle, hands just outside shoulders. Tighten glutes and core. Press bar overhead in a vertical trajectory, moving head back slightly to clear chin, then locking out over mid-foot with head back through.',
      defaultSets: 4,
      defaultReps: 8,
      restSeconds: 120,
      safetyGuidance:
          'Do not hyper-extend lumbar spine. Keep ribcage pulled down throughout the press.',
      imageUrl: 'https://images.unsplash.com/photo-1532029837206-abbe2b7620e3?w=600&auto=format&fit=crop',
      gifUrl: 'https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@v1.1.0/delts/barbell-seated-overhead-press.gif',
    ),
    Exercise(
      id: 'ex_shoulders_lateral_raise',
      name: 'Dumbbell Lateral Raise',
      category: 'shoulders',
      targetMuscle: 'Lateral Deltoids',
      secondaryMuscles: ['Supraspinatus', 'Trapezius'],
      equipment: 'dumbbell',
      difficulty: 'beginner',
      instructions:
          'Stand tall with dumbbells at sides, slight bend in elbows. Raise arms out to the sides in the scapular plane (slightly in front of body) until elbows reach shoulder level. Pause briefly, lower with control.',
      defaultSets: 4,
      defaultReps: 12,
      restSeconds: 60,
      safetyGuidance:
          'Lead with elbows, not wrists. Avoid shrugging traps to heave dumbbells up.',
      imageUrl: 'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=600&auto=format&fit=crop',
      gifUrl: 'https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@v1.1.0/delts/dumbbell-lateral-raise.gif',
    ),

    // --- BICEPS ---
    Exercise(
      id: 'ex_biceps_barbell_curl',
      name: 'Barbell Standing Bicep Curl',
      category: 'biceps',
      targetMuscle: 'Biceps Brachii (Long & Short Head)',
      secondaryMuscles: ['Brachialis', 'Brachioradialis'],
      equipment: 'barbell',
      difficulty: 'beginner',
      instructions:
          'Stand upright holding EZ-bar or barbell shoulder-width with underhand grip. Pin elbows to your sides. Curl weight upwards towards shoulders, contract biceps peak, lower under 3-second negative control.',
      defaultSets: 3,
      defaultReps: 10,
      restSeconds: 75,
      safetyGuidance:
          'Do not swing hips or lean back. Keep upper arms perpendicular to the floor.',
      imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=600&auto=format&fit=crop',
      gifUrl: 'https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@v1.1.0/biceps/barbell-curl.gif',
    ),
    Exercise(
      id: 'ex_biceps_hammer_curl',
      name: 'Dumbbell Hammer Curl',
      category: 'biceps',
      targetMuscle: 'Brachialis & Brachioradialis',
      secondaryMuscles: ['Biceps Brachii'],
      equipment: 'dumbbell',
      difficulty: 'beginner',
      instructions:
          'Hold dumbbells with neutral grip (palms facing each other). Keeping elbows tucked, curl dumbbells upward while maintaining the neutral wrist position. Squeeze forearms and outer bicep.',
      defaultSets: 3,
      defaultReps: 12,
      restSeconds: 60,
      safetyGuidance:
          'Maintain stable wrists; do not let the wrists bend backwards under weight.',
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=600&auto=format&fit=crop',
      gifUrl: 'https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@v1.1.0/biceps/dumbbell-hammer-curl.gif',
    ),

    // --- TRICEPS ---
    Exercise(
      id: 'ex_triceps_rope_pushdown',
      name: 'Cable Tricep Rope Pushdown',
      category: 'triceps',
      targetMuscle: 'Triceps Lateral & Medial Head',
      secondaryMuscles: ['Anconeus'],
      equipment: 'cable',
      difficulty: 'beginner',
      instructions:
          'Attach rope to high pulley. Grip rope with neutral hands, elbows tucked tightly at sides. Extend elbows downward until arms are straight, then spread rope ends outward at the bottom for maximal peak contraction.',
      defaultSets: 3,
      defaultReps: 12,
      restSeconds: 60,
      safetyGuidance:
          'Do not let elbows drift forward or backward during the movement; keep them locked in place.',
      imageUrl: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=600&auto=format&fit=crop',
      gifUrl: 'https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@v1.1.0/triceps/cable-pushdown-with-rope-attachment.gif',
    ),
    Exercise(
      id: 'ex_triceps_skull_crusher',
      name: 'Lying EZ-Bar Skull Crusher',
      category: 'triceps',
      targetMuscle: 'Triceps Brachii Long Head',
      secondaryMuscles: ['Triceps Medial Head'],
      equipment: 'barbell',
      difficulty: 'intermediate',
      instructions:
          'Lie on flat bench holding EZ bar with arms vertical. Hinge only at the elbows to lower bar towards crown of forehead or just behind top of head. Contract triceps to press bar back to starting position.',
      defaultSets: 3,
      defaultReps: 10,
      restSeconds: 75,
      safetyGuidance:
          'Use a safe, controllable weight. Keep upper arms angled back slightly (10°) to protect elbows.',
      imageUrl: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=600&auto=format&fit=crop',
      gifUrl: 'https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@v1.1.0/triceps/barbell-lying-triceps-extension-skull-crusher.gif',
    ),

    // --- LEGS & GLUTES ---
    Exercise(
      id: 'ex_legs_barbell_squat',
      name: 'Barbell Back Squat',
      category: 'legs',
      targetMuscle: 'Quadriceps, Gluteus Maximus',
      secondaryMuscles: ['Hamstrings', 'Adductors', 'Calves', 'Spinal Erectors'],
      equipment: 'barbell',
      difficulty: 'intermediate',
      instructions:
          'Rest barbell securely across upper trapezius. Feet shoulder-width apart, toes turned slightly out (15-30°). Inhale, brace core, push hips back and bend knees until thighs are at or below parallel. Drive up through mid-foot.',
      defaultSets: 4,
      defaultReps: 8,
      restSeconds: 150,
      safetyGuidance:
          'Do not let knees cave inwards (valgus collapse). Keep chest proud and heels planted.',
      imageUrl: 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=600&auto=format&fit=crop',
      gifUrl: 'https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@v1.1.0/glutes/barbell-full-squat.gif',
    ),
    Exercise(
      id: 'ex_legs_romanian_deadlift',
      name: 'Romanian Deadlift (RDL)',
      category: 'legs',
      targetMuscle: 'Hamstrings & Gluteus Maximus',
      secondaryMuscles: ['Erector Spinae', 'Lats'],
      equipment: 'barbell',
      difficulty: 'intermediate',
      instructions:
          'Hold bar with overhand grip at thighs. Soften knees slightly and lock that knee angle. Push hips straight back towards the wall behind you while lowering bar along shins until deep hamstring stretch is felt. Drive hips forward to stand.',
      defaultSets: 3,
      defaultReps: 10,
      restSeconds: 90,
      safetyGuidance:
          'Hinge through hips, do not round lower back. Stop once hips cannot travel further backward.',
      imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=600&auto=format&fit=crop',
      gifUrl: 'https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@v1.1.0/glutes/barbell-romanian-deadlift.gif',
    ),
    Exercise(
      id: 'ex_legs_bulgarian_split_squat',
      name: 'Bulgarian Split Squat',
      category: 'legs',
      targetMuscle: 'Quadriceps & Gluteus Medius/Maximus',
      secondaryMuscles: ['Hamstrings', 'Calves', 'Core'],
      equipment: 'dumbbell',
      difficulty: 'advanced',
      instructions:
          'Place rear foot elevated on bench behind you. Step forward with front foot. Lower hips until front thigh is parallel to ground. Press through front heel to return to top.',
      defaultSets: 3,
      defaultReps: 10,
      restSeconds: 75,
      safetyGuidance:
          'Ensure front foot is positioned far enough forward so front knee stays tracked over foot.',
      imageUrl: 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=600&auto=format&fit=crop',
      gifUrl: 'https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@v1.1.0/quads/dumbbell-single-leg-split-squat.gif',
    ),

    // --- ABS & CORE ---
    Exercise(
      id: 'ex_abs_hanging_leg_raise',
      name: 'Hanging Leg / Knee Raise',
      category: 'abs',
      targetMuscle: 'Rectus Abdominis (Lower) & Hip Flexors',
      secondaryMuscles: ['Obliques', 'Forearms'],
      equipment: 'bodyweight',
      difficulty: 'intermediate',
      instructions:
          'Hang from pull-up bar with overhand grip. Engage lats and core to eliminate body sway. Flex hips and curl pelvis upwards as you raise knees or straight legs to chest height. Lower slowly.',
      defaultSets: 3,
      defaultReps: 12,
      restSeconds: 60,
      safetyGuidance:
          'Focus on posterior pelvic tilt at the top to target abdominal muscles rather than hip flexors only.',
      imageUrl: 'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=600&auto=format&fit=crop',
      gifUrl: 'https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@v1.1.0/abs/hanging-leg-raise.gif',
    ),
    Exercise(
      id: 'ex_abs_plank',
      name: 'Forearm Plank',
      category: 'abs',
      targetMuscle: 'Transverse Abdominis & Rectus Abdominis',
      secondaryMuscles: ['Glutes', 'Deltoids', 'Lower Back'],
      equipment: 'bodyweight',
      difficulty: 'beginner',
      instructions:
          'Support body on forearms and toes. Align elbows directly under shoulders. Form a straight line from crown of head to heels. Squeeze glutes, tuck pelvis, pull belly button inward and hold.',
      defaultSets: 3,
      defaultReps: 45,
      restSeconds: 60,
      safetyGuidance:
          'Never let hips sag down or pike into the air. Breathe steadily; do not hold breath.',
      imageUrl: 'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=600&auto=format&fit=crop',
      gifUrl: 'https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@v1.1.0/abs/weighted-front-plank.gif',
    ),

    // --- CARDIO ---
    Exercise(
      id: 'ex_cardio_hiit_sprints',
      name: 'Treadmill HIIT Sprints',
      category: 'cardio',
      targetMuscle: 'Cardiovascular System & Legs',
      secondaryMuscles: ['Calves', 'Core', 'Glutes'],
      equipment: 'cardio',
      difficulty: 'intermediate',
      instructions:
          'Warm up for 3 minutes. Perform 30 seconds of maximal effort sprint at 14-18 km/h, followed by 60 seconds of walking recovery at 4 km/h. Repeat for 8-10 rounds.',
      defaultSets: 8,
      defaultReps: 1,
      restSeconds: 60,
      safetyGuidance:
          'Step onto side rails safely before adjusting high speeds. Wear properly cushioned running footwear.',
      imageUrl: 'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=600&auto=format&fit=crop',
      gifUrl: 'https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@v1.1.0/cardio/run.gif',
    ),
    Exercise(
      id: 'ex_cardio_jump_rope',
      name: 'Speed Jump Rope Intervals',
      category: 'cardio',
      targetMuscle: 'Calves & Cardiovascular System',
      secondaryMuscles: ['Forearms', 'Shoulders', 'Core'],
      equipment: 'cardio',
      difficulty: 'beginner',
      instructions:
          'Jump on the balls of your feet with knees softly bent. Turn rope using small circular wrist movements rather than large arm swings. Perform 1-minute high-cadence sets with 30s rest.',
      defaultSets: 5,
      defaultReps: 60,
      restSeconds: 30,
      safetyGuidance:
          'Stay light on your feet; jump only 1 to 2 inches off the ground to minimize joint impact.',
      imageUrl: 'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=600&auto=format&fit=crop',
      gifUrl: 'https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@v1.1.0/cardio/jump-rope.gif',
    ),

    // --- FULL BODY ---
    Exercise(
      id: 'ex_fullbody_kettlebell_swing',
      name: 'Russian Kettlebell Swing',
      category: 'full_body',
      targetMuscle: 'Posterior Chain (Glutes, Hamstrings, Lats)',
      secondaryMuscles: ['Core', 'Forearms', 'Shoulders'],
      equipment: 'kettlebell',
      difficulty: 'intermediate',
      instructions:
          'Stand with feet wider than shoulder-width, bell 1 foot in front. Hinge at hips to grab bell, hike it between legs like a football snap. Explosively extend hips and squeeze glutes to propel bell to chest height.',
      defaultSets: 4,
      defaultReps: 15,
      restSeconds: 60,
      safetyGuidance:
          'The swing is a hip hinge power movement, not a shoulder front raise or squat. Do not lift with arms.',
      imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=600&auto=format&fit=crop',
      gifUrl: 'https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@v1.1.0/glutes/kettlebell-swing.gif',
    ),
    Exercise(
      id: 'ex_fullbody_burpees',
      name: 'Full Body Burpees',
      category: 'full_body',
      targetMuscle: 'Full Body Conditioning',
      secondaryMuscles: ['Chest', 'Quadriceps', 'Core', 'Shoulders'],
      equipment: 'bodyweight',
      difficulty: 'intermediate',
      instructions:
          'From standing, drop into a squat and place hands on floor. Kick feet back into pushup position. Perform a full pushup with chest to floor, jump feet back under hips, and explode vertically into a jump with hands overhead.',
      defaultSets: 3,
      defaultReps: 12,
      restSeconds: 60,
      safetyGuidance:
          'Land softly on the balls of your feet to dissipate shock into ankles and knees.',
      imageUrl: 'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=600&auto=format&fit=crop',
      gifUrl: 'https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@v1.1.0/cardio/burpee.gif',
    ),
  ];
}
