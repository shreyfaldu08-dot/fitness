import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/fitora_app_bar.dart';
import '../../../core/widgets/fitora_button.dart';
import '../../../core/widgets/fitora_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final userRepo = ref.read(userRepositoryProvider);
      final isOnboardingDone = userRepo.isOnboardingCompleted();

      if (mounted) {
        if (isOnboardingDone) {
          context.go('/');
        } else {
          context.go('/onboarding');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FitoraAppBar(title: ''),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome Back',
                  style: AppTypography.headingLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Sign in to sync your personalized workouts, meals, and body metrics.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xl),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: AppSpacing.roundedSm,
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                FitoraTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hintText: 'alex.vance@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary, size: 20),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter your email';
                    if (!val.contains('@') || !val.contains('.')) return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                FitoraTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: '••••••••',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary, size: 20),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Please enter your password';
                    if (val.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xs),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text(
                      'Forgot Password?',
                      style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                FitoraButton(
                  label: 'Sign In',
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: AppSpacing.md),

                FitoraButton(
                  label: 'Continue with Google',
                  variant: FitoraButtonVariant.outline,
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 26, color: AppColors.textPrimary),
                  onPressed: () {
                    _emailController.text = 'google.athlete@fitora.app';
                    _passwordController.text = 'athleteGoogle2026!';
                    _handleLogin();
                  },
                ),
                const SizedBox(height: AppSpacing.sm),

                FitoraButton(
                  label: 'Skip Sign-In (Continue as Guest)',
                  variant: FitoraButtonVariant.ghost,
                  onPressed: () => context.go('/'),
                ),
                const SizedBox(height: AppSpacing.lg),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account?',
                      style: AppTypography.bodySmall,
                    ),
                    TextButton(
                      onPressed: () => context.push('/signup'),
                      child: Text(
                        'Create One',
                        style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
