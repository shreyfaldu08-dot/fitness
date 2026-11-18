import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/fitora_card.dart';
import '../../../core/widgets/fitora_button.dart';

class PhotoComparisonScreen extends StatefulWidget {
  const PhotoComparisonScreen({super.key});

  @override
  State<PhotoComparisonScreen> createState() => _PhotoComparisonScreenState();
}

class _PhotoComparisonScreenState extends State<PhotoComparisonScreen> {
  double _splitPosition = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Progress Photos'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Privacy Guarantee Callout
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: AppSpacing.roundedMd,
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded, color: AppColors.success, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Zero-knowledge isolation: Your photos are strictly confidential and encrypted in your personal storage.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text('Side-by-Side Comparison', style: AppTypography.headingSmall),
              const SizedBox(height: 6),
              Text('Compare day 1 starting photo against current posture.', style: AppTypography.bodySmall),
              const SizedBox(height: AppSpacing.md),

              // Comparison Card
              FitoraCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    SizedBox(
                      height: 320,
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: (_splitPosition * 100).round(),
                                child: Container(
                                  color: AppColors.surfaceMuted,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.person_rounded, size: 54, color: AppColors.textMuted),
                                        const SizedBox(height: 8),
                                        Text('Day 1 Baseline', style: AppTypography.labelLarge),
                                        Text('74.5 kg', style: AppTypography.bodySmall),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(width: 2, color: AppColors.primary),
                              Expanded(
                                flex: ((1.0 - _splitPosition) * 100).round(),
                                child: Container(
                                  color: AppColors.primaryLight,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.fitness_center_rounded, size: 54, color: AppColors.primary),
                                        const SizedBox(height: 8),
                                        Text('Week 4 (Current)',
                                            style: AppTypography.labelLarge.copyWith(color: AppColors.primaryDark)),
                                        Text('71.2 kg (-3.3 kg)', style: AppTypography.bodySmall),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Text('Day 1', style: AppTypography.labelSmall),
                          Expanded(
                            child: Slider(
                              value: _splitPosition,
                              min: 0.1,
                              max: 0.9,
                              activeColor: AppColors.primary,
                              inactiveColor: AppColors.border,
                              onChanged: (val) => setState(() => _splitPosition = val),
                            ),
                          ),
                          Text('Today', style: AppTypography.labelSmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              FitoraButton(
                label: 'Upload New Progress Photo',
                icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Camera & storage integration initialized.')),
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
