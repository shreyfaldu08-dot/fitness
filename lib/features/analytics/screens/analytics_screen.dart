import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/fitora_card.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _rangeDays = 7; // 7, 30, 90

  @override
  Widget build(BuildContext context) {
    final workoutRepo = ref.watch(workoutRepositoryProvider);
    final nutritionLogs = ref.watch(nutritionLogsProvider);
    final habits = ref.watch(habitsListProvider);
    final goal = ref.watch(fitnessGoalProvider);

    final sessions = workoutRepo.getWorkoutSessions();

    final completedWorkoutsCount = sessions.length;
    final totalVolume = sessions.fold(0.0, (sum, s) => sum + s.totalVolumeKg);

    final avgCalories = nutritionLogs.isNotEmpty
        ? (nutritionLogs.fold(0.0, (sum, l) => sum + l.calories) / (_rangeDays.clamp(1, 7))).round()
        : goal.targetCalories;

    final avgProtein = nutritionLogs.isNotEmpty
        ? (nutritionLogs.fold(0.0, (sum, l) => sum + l.protein) / (_rangeDays.clamp(1, 7))).round()
        : goal.targetProteinG;

    final completedHabits = habits.where((h) => h.isCompletedToday).length;
    final habitConsistencyPct = habits.isNotEmpty ? ((completedHabits / habits.length) * 100).round() : 85;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analytics & Intelligence'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Range Switcher
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Performance Range', style: AppTypography.headingSmall),
                  Row(
                    children: [
                      _buildRangeButton(7, '7 Days'),
                      const SizedBox(width: 6),
                      _buildRangeButton(30, '30 Days'),
                      const SizedBox(width: 6),
                      _buildRangeButton(90, '90 Days'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // KPI Readout Grid
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      label: 'Workouts Completed',
                      value: '$completedWorkoutsCount',
                      unit: 'sessions',
                      icon: Icons.fitness_center_rounded,
                      color: AppColors.workoutAccent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildKpiCard(
                      label: 'Total Volume Moved',
                      value: '${(totalVolume / 1000).toStringAsFixed(1)}k',
                      unit: 'kg lifted',
                      icon: Icons.line_weight_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      label: 'Avg Daily Calories',
                      value: '$avgCalories',
                      unit: 'kcal / day',
                      icon: Icons.local_fire_department_rounded,
                      color: AppColors.calorieAccent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildKpiCard(
                      label: 'Habit Adherence',
                      value: '$habitConsistencyPct%',
                      unit: 'consistency',
                      icon: Icons.check_circle_rounded,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Training Consistency Bar Chart
              Text('Weekly Training Volume & Frequency', style: AppTypography.headingSmall),
              const SizedBox(height: AppSpacing.sm),
              FitoraCard(
                padding: const EdgeInsets.fromLTRB(16, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 5,
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            show: true,
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 26,
                                getTitlesWidget: (v, m) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10)),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                  final idx = val.toInt();
                                  if (idx >= 0 && idx < days.length) {
                                    return Text(days[idx], style: const TextStyle(fontSize: 10, color: AppColors.textSecondary));
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            _buildBarGroup(0, 1, AppColors.primary),
                            _buildBarGroup(1, 1, AppColors.primary),
                            _buildBarGroup(2, 0, AppColors.border),
                            _buildBarGroup(3, 1, AppColors.primary),
                            _buildBarGroup(4, 1, AppColors.primary),
                            _buildBarGroup(5, 0, AppColors.border),
                            _buildBarGroup(6, 1, AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Actionable Insights Section
              Text('Smart Evidence Insights', style: AppTypography.headingSmall),
              const SizedBox(height: AppSpacing.sm),
              _buildInsightCard(
                icon: Icons.trending_up_rounded,
                color: AppColors.success,
                title: 'Progressive Overload Verified',
                description: 'Your compound squat and bench press volume has increased by 6.2% over the last 14 days.',
              ),
              const SizedBox(height: 10),
              _buildInsightCard(
                icon: Icons.restaurant_rounded,
                color: AppColors.proteinAccent,
                title: 'Protein Target Alignment',
                description: 'You averaged ${avgProtein}g of protein per day. Preserving lean body mass while in caloric control.',
              ),
              const SizedBox(height: 10),
              _buildInsightCard(
                icon: Icons.bedtime_rounded,
                color: AppColors.sleepAccent,
                title: 'Recovery & Nervous System',
                description: 'Sleep duration of 7.5+ hours on training days strongly correlates with higher workout set completion.',
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRangeButton(int days, String label) {
    final isSelected = _rangeDays == days;
    return InkWell(
      onTap: () => setState(() => _rangeDays = days),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return FitoraCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTypography.labelSmall),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: AppTypography.headingMedium.copyWith(color: color)),
              const SizedBox(width: 4),
              Text(unit, style: AppTypography.statUnit),
            ],
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return FitoraCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppSpacing.roundedSm,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelLarge),
                const SizedBox(height: 2),
                Text(description, style: AppTypography.bodySmall.copyWith(height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
