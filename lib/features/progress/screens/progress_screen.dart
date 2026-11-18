import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/fitness_calculator.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/fitora_card.dart';
import '../../../core/widgets/fitora_button.dart';
import '../../../core/widgets/fitora_text_field.dart';
import '../../../data/models/body_measurement.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  int _selectedDaysFilter = 30; // 7, 30, 90, 365

  void _showLogMeasurementSheet() {
    final progressRepo = ref.read(progressRepositoryProvider);
    final latest = progressRepo.getLatestMeasurement();

    final weightController = TextEditingController(text: '${latest?.weightKg ?? 72.0}');
    final waistController = TextEditingController(text: '${latest?.waistCm ?? 83.0}');
    final chestController = TextEditingController(text: '${latest?.chestCm ?? 100.0}');
    final hipController = TextEditingController(text: '${latest?.hipCm ?? 96.0}');
    final armController = TextEditingController(text: '${latest?.armCm ?? 35.0}');
    final thighController = TextEditingController(text: '${latest?.thighCm ?? 56.0}');
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
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
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 16),
                Text('Log Body Metrics', style: AppTypography.headingSmall),
                const SizedBox(height: 4),
                Text('Record morning weight after waking and circumferences.', style: AppTypography.bodySmall),
                const SizedBox(height: AppSpacing.lg),

                FitoraTextField(
                  controller: weightController,
                  label: 'Scale Weight (kg)',
                  hintText: 'e.g. 71.5',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSpacing.md),

                Row(
                  children: [
                    Expanded(
                      child: FitoraTextField(
                        controller: waistController,
                        label: 'Waist (cm)',
                        hintText: '83',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FitoraTextField(
                        controller: chestController,
                        label: 'Chest (cm)',
                        hintText: '100',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                Row(
                  children: [
                    Expanded(
                      child: FitoraTextField(
                        controller: hipController,
                        label: 'Hips (cm)',
                        hintText: '96',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FitoraTextField(
                        controller: armController,
                        label: 'Arms (cm)',
                        hintText: '35',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                FitoraTextField(
                  controller: notesController,
                  label: 'Wellness / Body Composition Notes',
                  hintText: 'e.g. Waist feels tighter, veins showing on forearms.',
                ),
                const SizedBox(height: AppSpacing.xl),

                FitoraButton(
                  label: 'Save Measurement',
                  onPressed: () async {
                    final weight = double.tryParse(weightController.text.trim()) ?? 72.0;
                    final newMeas = BodyMeasurement(
                      id: const Uuid().v4(),
                      userId: 'athlete_1',
                      loggedDate: DateTime.now(),
                      weightKg: weight,
                      heightCm: 175,
                      bmi: FitnessCalculator.calculateBmi(weightKg: weight, heightCm: 175),
                      waistCm: double.tryParse(waistController.text.trim()),
                      chestCm: double.tryParse(chestController.text.trim()),
                      hipCm: double.tryParse(hipController.text.trim()),
                      armCm: double.tryParse(armController.text.trim()),
                      thighCm: double.tryParse(thighController.text.trim()),
                      notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
                    );

                    await progressRepo.logMeasurement(newMeas);
                    if (mounted) {
                      Navigator.pop(ctx);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Measurement logged successfully!')),
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
  }

  @override
  Widget build(BuildContext context) {
    final progressRepo = ref.watch(progressRepositoryProvider);
    final profile = ref.watch(userProfileProvider);
    final allMeasurements = progressRepo.getMeasurements();
    final latest = progressRepo.getLatestMeasurement();

    final currentWeight = latest?.weightKg ?? profile?.currentWeightKg ?? 72.0;
    final bmi = latest?.bmi ?? profile?.bmi ?? 24.2;
    final bmiCategory = FitnessCalculator.getBmiCategory(bmi);
    final targetWeight = profile?.targetWeightKg ?? 68.0;
    final toTarget = currentWeight - targetWeight;

    // Filter measurements for chart
    final cutoff = DateTime.now().subtract(Duration(days: _selectedDaysFilter));
    final filtered = allMeasurements.where((m) => m.loggedDate.isAfter(cutoff)).toList();
    // Reverse to chronological order for line chart
    final chartData = filtered.reversed.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Body Progress & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            tooltip: 'Progress Photos',
            onPressed: () => context.push('/photo-comparison'),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Log Metric',
            onPressed: _showLogMeasurementSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Metrics Row
              Row(
                children: [
                  Expanded(
                    child: FitoraCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current Weight', style: AppTypography.labelSmall),
                          const SizedBox(height: 4),
                          Text('${currentWeight.toStringAsFixed(1)} kg',
                              style: AppTypography.headingLarge.copyWith(color: AppColors.primary)),
                          const SizedBox(height: 4),
                          Text(
                            toTarget > 0 ? '${toTarget.toStringAsFixed(1)} kg to goal' : 'Goal Achieved!',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FitoraCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Body Mass Index', style: AppTypography.labelSmall),
                          const SizedBox(height: 4),
                          Text('$bmi', style: AppTypography.headingLarge),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius: AppSpacing.roundedSm,
                            ),
                            child: Text(
                              bmiCategory,
                              style: AppTypography.labelSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Weight Trend Chart Header & Filters
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Weight Progression', style: AppTypography.headingSmall),
                  Row(
                    children: [
                      _buildFilterChip(7, '7D'),
                      const SizedBox(width: 6),
                      _buildFilterChip(30, '30D'),
                      const SizedBox(width: 6),
                      _buildFilterChip(90, '90D'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // FL Chart Line Graph
              FitoraCard(
                padding: const EdgeInsets.fromLTRB(16, 20, 20, 16),
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: chartData.length >= 2
                          ? LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 1,
                                  getDrawingHorizontalLine: (value) => const FlLine(
                                    color: AppColors.border,
                                    strokeWidth: 1,
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 38,
                                      getTitlesWidget: (val, meta) {
                                        return Text('${val.round()}kg', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary));
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 22,
                                      getTitlesWidget: (val, meta) {
                                        final int index = val.toInt();
                                        if (index >= 0 && index < chartData.length) {
                                          return Text(
                                            DateFormatter.formatMonthDay(chartData[index].loggedDate),
                                            style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                minX: 0,
                                maxX: (chartData.length - 1).toDouble(),
                                minY: (chartData.map((e) => e.weightKg).reduce((a, b) => a < b ? a : b) - 1.5).floorToDouble(),
                                maxY: (chartData.map((e) => e.weightKg).reduce((a, b) => a > b ? a : b) + 1.5).ceilToDouble(),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: chartData.asMap().entries.map((entry) {
                                      return FlSpot(entry.key.toDouble(), entry.value.weightKg);
                                    }).toList(),
                                    isCurved: true,
                                    color: AppColors.primary,
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(show: true),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: AppColors.primary.withValues(alpha: 0.08),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const Center(
                              child: Text('Log at least 2 measurements to plot line chart progression.'),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Circumference Measurements Grid
              if (latest != null) ...[
                Text('Body Circumferences', style: AppTypography.headingSmall),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(child: _buildCircumferenceTile('Waist', '${latest.waistCm ?? "--"} cm', Icons.straighten_rounded)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildCircumferenceTile('Chest', '${latest.chestCm ?? "--"} cm', Icons.fitness_center_rounded)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildCircumferenceTile('Hips', '${latest.hipCm ?? "--"} cm', Icons.accessibility_rounded)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildCircumferenceTile('Arms', '${latest.armCm ?? "--"} cm', Icons.sports_gymnastics_rounded)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildCircumferenceTile('Thighs', '${latest.thighCm ?? "--"} cm', Icons.directions_walk_rounded)),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Medical & Fluctuations Educational Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: AppSpacing.roundedMd,
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.insights_rounded, color: AppColors.info, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Understanding Daily Fluctuations',
                              style: AppTypography.labelLarge.copyWith(color: AppColors.info)),
                          const SizedBox(height: 4),
                          Text(
                            'Short-term 1-2 kg changes are primarily water, glycogen replenishment, sodium balance, and food volume in transit. Real fat loss or muscle gain is measured in weekly moving averages.',
                            style: AppTypography.bodySmall.copyWith(color: const Color(0xFF0C4A6E), height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(int days, String label) {
    final isSelected = _selectedDaysFilter == days;
    return InkWell(
      onTap: () => setState(() => _selectedDaysFilter = days),
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

  Widget _buildCircumferenceTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(value, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.labelSmall.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
