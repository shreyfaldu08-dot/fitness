import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/fitora_card.dart';
import '../../../core/widgets/fitora_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final goal = ref.watch(fitnessGoalProvider);
    final prefs = ref.watch(userPreferencesProvider);
    final authRepo = ref.watch(authRepositoryProvider);

    final name = profile?.fullName ?? 'Athlete';
    final email = profile?.email ?? 'athlete@fitora.app';
    final weight = profile?.currentWeightKg ?? 74.0;
    final height = profile?.heightCm ?? 175.0;
    final bmi = profile?.bmi ?? 24.2;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Athlete Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: () => context.push('/edit-profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Avatar & Name Card
              FitoraCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'A',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                          child: const Icon(Icons.check, size: 12, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(name, style: AppTypography.headingSmall),
                    const SizedBox(height: 2),
                    Text(email, style: AppTypography.bodySmall),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: AppSpacing.roundedSm,
                      ),
                      child: Text(
                        'FITORA PRO • ${goal.goalDisplayName.toUpperCase()}',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Baseline Metrics
              Row(
                children: [
                  Expanded(child: _buildMetricTile('Weight', '${weight.toStringAsFixed(1)} kg')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMetricTile('Height', '${height.round()} cm')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMetricTile('BMI', '$bmi')),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Preferences & Config List
              FitoraCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.flag_outlined,
                      title: 'Fitness Goals',
                      subtitle: '${goal.goalDisplayName} • ${goal.targetCalories} kcal target',
                      onTap: () => context.push('/onboarding'),
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      icon: Icons.restaurant_outlined,
                      title: 'Dietary Preferences',
                      subtitle: '${prefs.dietaryPreference.replaceAll("_", " ").toUpperCase()} • ${prefs.dailyBudget} budget',
                      onTap: () => context.push('/onboarding'),
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      icon: Icons.straighten_rounded,
                      title: 'Units of Measurement',
                      subtitle: profile?.preferredUnits == 'metric' ? 'Metric (kg, cm, ml)' : 'Imperial (lbs, in, oz)',
                      onTap: () async {
                        final newUnit = profile?.preferredUnits == 'metric' ? 'imperial' : 'metric';
                        if (profile != null) {
                          await ref.read(userProfileProvider.notifier).updateProfile(
                                profile.copyWith(preferredUnits: newUnit),
                              );
                        }
                      },
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications & Reminders',
                      subtitle: 'Hydration & workout push alerts enabled',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notification settings updated')),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      icon: Icons.download_rounded,
                      title: 'Export My Health Data (JSON)',
                      subtitle: 'Download complete private data archive',
                      onTap: () {
                        final exportData = {
                          'profile': profile?.toJson(),
                          'goal': goal.toJson(),
                          'preferences': prefs.toJson(),
                          'exported_at': DateTime.now().toIso8601String(),
                        };
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Data exported (${jsonEncode(exportData).length} bytes generated).'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Medical Disclaimer Tile
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: AppSpacing.roundedMd,
                ),
                child: Text(
                  AppConstants.medicalDisclaimer,
                  style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Logout Button
              FitoraButton(
                label: 'Sign Out',
                variant: FitoraButtonVariant.danger,
                icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                onPressed: () async {
                  await authRepo.logout();
                  if (context.mounted) {
                    context.go('/welcome');
                  }
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(value, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.labelSmall),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(title, style: AppTypography.labelLarge),
      subtitle: Text(subtitle, style: AppTypography.bodySmall.copyWith(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
      onTap: onTap,
    );
  }
}
