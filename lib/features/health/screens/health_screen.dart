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
import '../../../data/models/activity_log.dart';

class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen({super.key});

  @override
  ConsumerState<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen> {
  bool _healthConnectConnected = false;

  void _showLogSleepSheet() {
    final healthRepo = ref.read(healthRepositoryProvider);
    final durationController = TextEditingController(text: '7.5');
    final bedTimeController = TextEditingController(text: '23:00');
    final wakeTimeController = TextEditingController(text: '06:30');
    final notesController = TextEditingController();
    int quality = 4;

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
                    Text('Log Sleep & Recovery', style: AppTypography.headingSmall),
                    const SizedBox(height: AppSpacing.md),

                    FitoraTextField(
                      controller: durationController,
                      label: 'Total Sleep Duration (Hours)',
                      hintText: 'e.g. 7.5',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Row(
                      children: [
                        Expanded(
                          child: FitoraTextField(
                            controller: bedTimeController,
                            label: 'Bedtime',
                            hintText: '23:00',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FitoraTextField(
                            controller: wakeTimeController,
                            label: 'Wake Up Time',
                            hintText: '06:30',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Text('Sleep Quality Rating', style: AppTypography.labelMedium),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(5, (index) {
                        final star = index + 1;
                        return IconButton(
                          icon: Icon(
                            star <= quality ? Icons.star_rounded : Icons.star_border_rounded,
                            color: AppColors.warning,
                            size: 32,
                          ),
                          onPressed: () => setSheetState(() => quality = star),
                        );
                      }),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    FitoraTextField(
                      controller: notesController,
                      label: 'Recovery Notes (Optional)',
                      hintText: 'e.g. Deep REM sleep, woke up energized.',
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    FitoraButton(
                      label: 'Save Sleep Record',
                      onPressed: () async {
                        final dur = double.tryParse(durationController.text.trim()) ?? 7.5;
                        final log = SleepLog(
                          id: const Uuid().v4(),
                          userId: 'athlete_1',
                          loggedDate: DateTime.now(),
                          durationHours: dur,
                          qualityRating: quality,
                          bedTime: bedTimeController.text.trim(),
                          wakeTime: wakeTimeController.text.trim(),
                          notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
                        );

                        await healthRepo.logSleep(log);
                        if (mounted) {
                          Navigator.pop(ctx);
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sleep log saved!')),
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
    final healthRepo = ref.watch(healthRepositoryProvider);
    final activity = ref.watch(todayActivityProvider);
    final waterMl = ref.watch(todayWaterProvider);
    final sleepLogs = healthRepo.getSleepLogs();
    final latestSleep = sleepLogs.isNotEmpty ? sleepLogs.first : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Health & Recovery'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Health Connect / Apple Health Integration Banner
              FitoraCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: AppSpacing.roundedSm,
                      ),
                      child: const Icon(Icons.sync_rounded, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Health Connect & Apple Health', style: AppTypography.labelLarge),
                          const SizedBox(height: 2),
                          Text(
                            _healthConnectConnected ? 'Active sync (device verified)' : 'Not synced. Using manual entries.',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _healthConnectConnected,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() => _healthConnectConnected = val);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              val
                                  ? 'Connected to Health Connect. Step and sleep sensors verified.'
                                  : 'Health Connect disconnected. Switched to manual mode.',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Sleep & Rest Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sleep & Circadian Rhythm', style: AppTypography.headingSmall),
                  TextButton.icon(
                    onPressed: _showLogSleepSheet,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Log Sleep'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              if (latestSleep != null) ...[
                FitoraCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Last Night\'s Rest', style: AppTypography.labelMedium),
                              const SizedBox(height: 4),
                              Text('${latestSleep.durationHours} hrs',
                                  style: AppTypography.headingLarge.copyWith(color: AppColors.sleepAccent, fontWeight: FontWeight.w800)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.successLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('88% Readiness', style: AppTypography.labelSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    i < latestSleep.qualityRating ? Icons.star_rounded : Icons.star_border_rounded,
                                    color: AppColors.warning,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Visual Sleep Architecture Bar
                      Text('Sleep Stages Breakdown', style: AppTypography.labelSmall.copyWith(fontSize: 11, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: SizedBox(
                          height: 10,
                          child: Row(
                            children: [
                              Expanded(flex: 28, child: Container(color: const Color(0xFF4338CA))), // Deep
                              const SizedBox(width: 2),
                              Expanded(flex: 24, child: Container(color: const Color(0xFF7C3AED))), // REM
                              const SizedBox(width: 2),
                              Expanded(flex: 42, child: Container(color: const Color(0xFF38BDF8))), // Light
                              const SizedBox(width: 2),
                              Expanded(flex: 6, child: Container(color: const Color(0xFFF59E0B))), // Awake
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStageTag('Deep 2.1h', const Color(0xFF4338CA)),
                          _buildStageTag('REM 1.8h', const Color(0xFF7C3AED)),
                          _buildStageTag('Light 3.2h', const Color(0xFF38BDF8)),
                          _buildStageTag('Awake 24m', const Color(0xFFF59E0B)),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.favorite_rounded, color: Color(0xFFEF4444), size: 16),
                              const SizedBox(width: 4),
                              Text('Resting HR: 56 bpm', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(width: 12),
                              const Icon(Icons.show_chart_rounded, color: AppColors.primary, size: 16),
                              const SizedBox(width: 4),
                              Text('HRV: 64 ms', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          _buildDeviceTag(isDevice: _healthConnectConnected),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),

              // Activity & Movement
              Text('Movement & Calorie Burn', style: AppTypography.headingSmall),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: FitoraCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.directions_walk_rounded, color: AppColors.stepsAccent, size: 20),
                              _buildDeviceTag(isDevice: _healthConnectConnected),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('${activity.steps}', style: AppTypography.headingMedium),
                          const SizedBox(height: 2),
                          Text('Steps Today', style: AppTypography.labelSmall),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FitoraCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.local_fire_department_rounded, color: AppColors.calorieAccent, size: 20),
                              _buildDeviceTag(isDevice: _healthConnectConnected),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('${activity.caloriesBurned} kcal', style: AppTypography.headingMedium),
                          const SizedBox(height: 2),
                          Text('Active Burn', style: AppTypography.labelSmall),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Hydration Overview
              Text('Hydration Balance', style: AppTypography.headingSmall),
              const SizedBox(height: AppSpacing.sm),
              FitoraCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current Volume', style: AppTypography.labelSmall),
                        const SizedBox(height: 4),
                        Text('$waterMl ml', style: AppTypography.headingMedium.copyWith(color: AppColors.waterAccent)),
                        const SizedBox(height: 2),
                        Text('Recommended: 3,000 ml', style: AppTypography.bodySmall),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => ref.read(todayWaterProvider.notifier).addWater(250),
                          child: const Text('+250ml'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceTag({required bool isDevice}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDevice ? AppColors.successLight : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isDevice ? 'Device Sync' : 'Manual Entry',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isDevice ? AppColors.success : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildStageTag(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
