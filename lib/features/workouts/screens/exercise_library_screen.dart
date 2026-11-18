import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/fitora_card.dart';
import '../../../core/widgets/fitora_chip.dart';
import '../../../core/widgets/fitora_muscle_badge.dart';
import '../../../core/widgets/fitora_muscle_illustration.dart';
import '../../../data/models/exercise.dart';

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const ExerciseLibraryScreen({
    super.key,
    this.initialCategory,
  });

  @override
  ConsumerState<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
  late String _selectedCategory;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<(String id, String label)> _categories = const [
    ('all', 'All'),
    ('chest', 'Chest'),
    ('back', 'Back'),
    ('shoulders', 'Shoulders'),
    ('biceps', 'Biceps'),
    ('triceps', 'Triceps'),
    ('legs', 'Legs & Glutes'),
    ('abs', 'Abs & Core'),
    ('cardio', 'Cardio'),
    ('full_body', 'Full Body'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'all';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workoutRepo = ref.watch(workoutRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Exercise Library'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: TextFormField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                decoration: InputDecoration(
                  hintText: 'Search exercises, muscle targets...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Horizontal Categories Scroll
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat.$1;
                  return FitoraChip(
                    label: cat.$2,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedCategory = cat.$1),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Exercise List
            Expanded(
              child: FutureBuilder<List<Exercise>>(
                future: workoutRepo.getExercises(
                  category: _selectedCategory,
                  query: _searchQuery,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final exercises = snapshot.data ?? [];

                  if (exercises.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.fitness_center_rounded, size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text('No exercises found', style: AppTypography.headingSmall),
                          const SizedBox(height: 4),
                          Text('Try adjusting your search or category filter.', style: AppTypography.bodySmall),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: exercises.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return _buildExerciseTile(context, exercise);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseTile(BuildContext context, Exercise exercise) {
    return FitoraCard(
      onTap: () => context.push('/exercise-detail', extra: exercise),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Anatomical Body Target Illustration
          FitoraMuscleIllustration(
            muscle: exercise.targetMuscle,
            width: 54,
            height: 68,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.name, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    FitoraMuscleBadge(muscle: exercise.targetMuscle),
                    FitoraDifficultyIndicator(difficulty: exercise.difficulty),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.fitness_center_rounded, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(exercise.equipment, style: AppTypography.labelSmall.copyWith(fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(width: 10),
                    const Icon(Icons.timer_outlined, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text('${exercise.restSeconds}s rest', style: AppTypography.labelSmall.copyWith(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 22),
        ],
      ),
    );
  }
}
