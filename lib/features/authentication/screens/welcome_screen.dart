import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/fitora_button.dart';
import '../../../core/widgets/fitora_card.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Brand Logo & Header
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: AppColors.buttonShadow,
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                AppConstants.appName,
                textAlign: TextAlign.center,
                style: AppTypography.displayLarge.copyWith(
                  letterSpacing: -1.0,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppConstants.appTagline,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Value Proposition Feature Cards
              FitoraCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildFeatureRow(
                      icon: Icons.fitness_center_rounded,
                      color: AppColors.workoutAccent,
                      title: 'Smart Strength & Conditioning',
                      subtitle: 'Structured workout splits with active rest timing & logging.',
                    ),
                    const Divider(height: 20),
                    _buildFeatureRow(
                      icon: Icons.restaurant_rounded,
                      color: AppColors.carbAccent,
                      title: 'Verified Nutrition Database',
                      subtitle: 'Accurate Indian staple foods, macro breakdown & meal swaps.',
                    ),
                    const Divider(height: 20),
                    _buildFeatureRow(
                      icon: Icons.auto_awesome_rounded,
                      color: AppColors.primary,
                      title: 'Intelligent AI Fitness Coach',
                      subtitle: 'Personalized guidance bounded by clinical & evidence-based safety.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Action Buttons
              FitoraButton(
                label: 'Get Started',
                onPressed: () => context.push('/signup'),
              ),
              const SizedBox(height: AppSpacing.sm),
              FitoraButton(
                label: 'I Already Have an Account',
                variant: FitoraButtonVariant.outline,
                onPressed: () => context.push('/login'),
              ),
              const SizedBox(height: AppSpacing.sm),
              FitoraButton(
                label: 'Skip Sign-In (Continue as Guest)',
                variant: FitoraButtonVariant.ghost,
                onPressed: () => context.go('/'),
              ),
              const SizedBox(height: AppSpacing.md),

              // Disclaimer
              Text(
                'By proceeding, you agree to FITORA\'s Terms of Service and Privacy Policy.',
                textAlign: TextAlign.center,
                style: AppTypography.labelSmall.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppSpacing.roundedSm,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
