import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/fitora_card.dart';

class WorkoutHistoryScreen extends ConsumerWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutRepo = ref.watch(workoutRepositoryProvider);
    final sessions = workoutRepo.getWorkoutSessions();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Workout History'),
      ),
      body: SafeArea(
        child: sessions.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.history_rounded, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    Text('No workouts logged yet', style: AppTypography.headingSmall),
                    const SizedBox(height: 4),
                    Text('Complete your first workout to see your lifting history.', style: AppTypography.bodySmall),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: sessions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final s = sessions[index];
                  return FitoraCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(s.workoutName, style: AppTypography.headingSmall.copyWith(fontSize: 16)),
                            Text(
                              DateFormatter.formatShortDate(s.startedAt),
                              style: AppTypography.labelSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildHistoryMetric('Duration', DateFormatter.formatDuration(s.durationSeconds)),
                            _buildHistoryMetric('Volume', '${s.totalVolumeKg.round()} kg'),
                            _buildHistoryMetric('Sets', '${s.setsCompleted}'),
                            _buildHistoryMetric('Exercises', '${s.exercisesCompleted}'),
                          ],
                        ),
                        if (s.notes != null && s.notes!.isNotEmpty) ...[
                          const Divider(height: 20),
                          Text('Note: ${s.notes!}', style: AppTypography.bodySmall),
                        ],
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildHistoryMetric(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.labelSmall.copyWith(fontSize: 10)),
      ],
    );
  }
}
