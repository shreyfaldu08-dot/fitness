import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/fitora_button.dart';
import '../../../core/widgets/fitora_card.dart';
import '../../../core/widgets/fitora_chip.dart';
import '../../../core/widgets/fitora_text_field.dart';
import '../../../core/widgets/fitora_exercise_visual_tile.dart';
import '../../../data/models/workout_plan.dart';
import '../../../data/seed/seed_exercises.dart';

class WorkoutPlanBuilderScreen extends ConsumerStatefulWidget {
  final WorkoutPlan? existingPlan;

  const WorkoutPlanBuilderScreen({
    super.key,
    this.existingPlan,
  });

  @override
  ConsumerState<WorkoutPlanBuilderScreen> createState() => _WorkoutPlanBuilderScreenState();
}

class _WorkoutPlanBuilderScreenState extends ConsumerState<WorkoutPlanBuilderScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _level = 'intermediate';
  int _daysPerWeek = 4;
  int _durationMinutes = 45;
  final List<PlanExercise> _selectedExercises = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingPlan != null) {
      _titleController.text = widget.existingPlan!.title;
      _descController.text = widget.existingPlan!.description;
      _level = widget.existingPlan!.level;
      _daysPerWeek = widget.existingPlan!.daysPerWeek;
      _durationMinutes = widget.existingPlan!.estimatedDurationMinutes;
      _selectedExercises.addAll(widget.existingPlan!.exercises);
    } else {
      _titleController.text = 'Custom Hypertrophy Split';
      _descController.text = 'Personalized high volume training routine.';
      // Pre-populate with 2 default exercises
      final ex1 = SeedExercises.list[0];
      final ex2 = SeedExercises.list[5];
      _selectedExercises.add(
        PlanExercise(
          exerciseId: ex1.id,
          exercise: ex1,
          orderIndex: 0,
          targetSets: 4,
          targetReps: 8,
          defaultWeightKg: 40.0,
        ),
      );
      _selectedExercises.add(
        PlanExercise(
          exerciseId: ex2.id,
          exercise: ex2,
          orderIndex: 1,
          targetSets: 4,
          targetReps: 10,
          defaultWeightKg: 45.0,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _addExercise() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, controller) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Select Exercise to Add', style: AppTypography.headingSmall),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: controller,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: SeedExercises.list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (c, i) {
                      final ex = SeedExercises.list[i];
                      return FitoraExerciseVisualTile(
                        exercise: ex,
                        index: i + 1,
                        onTap: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _selectedExercises.add(
                              PlanExercise(
                                exerciseId: ex.id,
                                exercise: ex,
                                orderIndex: _selectedExercises.length,
                                targetSets: ex.defaultSets,
                                targetReps: ex.defaultReps,
                                restSeconds: ex.restSeconds,
                                defaultWeightKg: 20.0,
                              ),
                            );
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _savePlan() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a plan title')),
      );
      return;
    }
    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one exercise')),
      );
      return;
    }

    final newPlan = WorkoutPlan(
      id: widget.existingPlan?.id ?? const Uuid().v4(),
      userId: 'athlete_1',
      title: title,
      description: _descController.text.trim(),
      level: _level,
      daysPerWeek: _daysPerWeek,
      estimatedDurationMinutes: _durationMinutes,
      exercises: _selectedExercises,
      createdAt: DateTime.now(),
    );

    final workoutRepo = ref.read(workoutRepositoryProvider);
    await workoutRepo.saveCustomPlan(newPlan);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Custom Workout Plan saved!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Workout Builder'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FitoraTextField(
                controller: _titleController,
                label: 'Workout Routine Name',
                hintText: 'e.g. Upper Body Hypertrophy',
              ),
              const SizedBox(height: AppSpacing.md),

              FitoraTextField(
                controller: _descController,
                label: 'Description & Focus',
                hintText: 'e.g. 4-day push/pull split focused on chest & back.',
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.lg),

              Text('Experience Tier', style: AppTypography.labelMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FitoraChip(
                      label: 'Beginner',
                      isSelected: _level == 'beginner',
                      onTap: () => setState(() => _level = 'beginner'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FitoraChip(
                      label: 'Intermediate',
                      isSelected: _level == 'intermediate',
                      onTap: () => setState(() => _level = 'intermediate'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FitoraChip(
                      label: 'Advanced',
                      isSelected: _level == 'advanced',
                      onTap: () => setState(() => _level = 'advanced'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Exercises List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Scheduled Exercises (${_selectedExercises.length})', style: AppTypography.headingSmall),
                  TextButton.icon(
                    onPressed: _addExercise,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Exercise'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              if (_selectedExercises.isEmpty) ...[
                FitoraCard(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.fitness_center_rounded, color: AppColors.textMuted, size: 36),
                        const SizedBox(height: 8),
                        Text('No exercises selected yet', style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _selectedExercises.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final item = _selectedExercises.removeAt(oldIndex);
                      _selectedExercises.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    final pEx = _selectedExercises[index];
                    final name = pEx.exercise?.name ?? 'Exercise';

                    return FitoraCard(
                      key: ValueKey('builder_ex_${pEx.exerciseId}_$index'),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.drag_indicator_rounded, color: AppColors.textMuted),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: AppTypography.labelLarge),
                                const SizedBox(height: 4),
                                Text(
                                  '${pEx.targetSets} sets × ${pEx.targetReps} reps • ${pEx.defaultWeightKg} kg • ${pEx.restSeconds}s rest',
                                  style: AppTypography.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                            onPressed: () {
                              setState(() {
                                _selectedExercises.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.xl),

              FitoraButton(
                label: 'Save Workout Plan',
                icon: const Icon(Icons.save_rounded, color: Colors.white),
                onPressed: _savePlan,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
