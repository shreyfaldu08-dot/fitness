import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/fitora_card.dart';
import '../../../core/widgets/fitora_button.dart';
import '../../../core/widgets/fitora_text_field.dart';
import '../../../data/models/habit.dart';

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  void _showCreateHabitSheet() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final targetController = TextEditingController(text: '1');
    final unitController = TextEditingController(text: 'times');
    String category = 'nutrition';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 16),
                    Text('Create Custom Habit', style: AppTypography.headingSmall),
                    const SizedBox(height: 4),
                    Text('Build consistency through daily tracked behaviors.', style: AppTypography.bodySmall),
                    const SizedBox(height: AppSpacing.lg),

                    FitoraTextField(
                      controller: titleController,
                      label: 'Habit Title',
                      hintText: 'e.g. 15 Min Post-Meal Walk',
                    ),
                    const SizedBox(height: AppSpacing.md),

                    FitoraTextField(
                      controller: descController,
                      label: 'Description & Cue',
                      hintText: 'e.g. Walk around the block immediately after lunch.',
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Row(
                      children: [
                        Expanded(
                          child: FitoraTextField(
                            controller: targetController,
                            label: 'Daily Target',
                            hintText: '1',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FitoraTextField(
                            controller: unitController,
                            label: 'Unit',
                            hintText: 'times, mins, glasses',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    FitoraButton(
                      label: 'Save Habit',
                      onPressed: () async {
                        final title = titleController.text.trim();
                        if (title.isEmpty) return;

                        final newHabit = Habit(
                          id: const Uuid().v4(),
                          userId: 'athlete_1',
                          title: title,
                          description: descController.text.trim(),
                          category: category,
                          targetValue: int.tryParse(targetController.text.trim()) ?? 1,
                          unit: unitController.text.trim(),
                          currentStreak: 0,
                          bestStreak: 0,
                          isCompletedToday: false,
                        );

                        await ref.read(habitsListProvider.notifier).addHabit(newHabit);
                        if (mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Habit created!')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsListProvider);
    final completedCount = habits.where((h) => h.isCompletedToday).length;
    final totalCount = habits.length;
    final progress = totalCount > 0 ? (completedCount / totalCount).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Habits & Streaks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'New Habit',
            onPressed: _showCreateHabitSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Consistency Banner
              FitoraCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Today\'s Habit Execution', style: AppTypography.labelLarge),
                        Text(
                          '$completedCount / $totalCount Done',
                          style: AppTypography.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.surfaceMuted,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text('Daily Habits ($totalCount)', style: AppTypography.headingSmall),
              const SizedBox(height: AppSpacing.sm),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: habits.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  return FitoraCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            habit.isCompletedToday ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            color: habit.isCompletedToday ? AppColors.success : AppColors.borderDark,
                            size: 26,
                          ),
                          onPressed: () => ref.read(habitsListProvider.notifier).toggleHabit(habit.id),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habit.title,
                                style: AppTypography.labelLarge.copyWith(
                                  decoration: habit.isCompletedToday ? TextDecoration.lineThrough : null,
                                  color: habit.isCompletedToday ? AppColors.textMuted : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(habit.description, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warningLight,
                            borderRadius: AppSpacing.roundedSm,
                          ),
                          child: Row(
                            children: [
                              const Text('🔥 ', style: TextStyle(fontSize: 12)),
                              Text(
                                '${habit.currentStreak}d',
                                style: AppTypography.labelSmall.copyWith(
                                  color: const Color(0xFFB45309),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
