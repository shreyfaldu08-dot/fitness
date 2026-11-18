import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/fitora_button.dart';
import '../../../core/widgets/fitora_text_field.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _targetWeightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    if (profile != null) {
      _nameController.text = profile.fullName;
      _heightController.text = '${profile.heightCm.round()}';
      _weightController.text = '${profile.currentWeightKg}';
      _targetWeightController.text = '${profile.targetWeightKg}';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final profile = ref.read(userProfileProvider);
    if (profile == null) return;

    final updated = profile.copyWith(
      fullName: _nameController.text.trim(),
      heightCm: double.tryParse(_heightController.text.trim()) ?? profile.heightCm,
      currentWeightKg: double.tryParse(_weightController.text.trim()) ?? profile.currentWeightKg,
      targetWeightKg: double.tryParse(_targetWeightController.text.trim()) ?? profile.targetWeightKg,
      updatedAt: DateTime.now(),
    );

    await ref.read(userProfileProvider.notifier).updateProfile(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FitoraTextField(
                controller: _nameController,
                label: 'Full Name',
                hintText: 'Alex Vance',
              ),
              const SizedBox(height: AppSpacing.md),

              FitoraTextField(
                controller: _heightController,
                label: 'Height (cm)',
                hintText: '175',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.md),

              FitoraTextField(
                controller: _weightController,
                label: 'Current Weight (kg)',
                hintText: '74.0',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.md),

              FitoraTextField(
                controller: _targetWeightController,
                label: 'Target Weight Goal (kg)',
                hintText: '70.0',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.xl),

              FitoraButton(
                label: 'Save Changes',
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
