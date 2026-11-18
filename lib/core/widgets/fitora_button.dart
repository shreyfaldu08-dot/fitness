import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

enum FitoraButtonVariant { primary, secondary, outline, text, danger, ghost }

class FitoraButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final FitoraButtonVariant variant;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;

  const FitoraButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = FitoraButtonVariant.primary,
    this.width,
    this.height = 50,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    BorderSide? borderSide;

    switch (variant) {
      case FitoraButtonVariant.primary:
        bgColor = AppColors.primary;
        fgColor = Colors.white;
        break;
      case FitoraButtonVariant.secondary:
        bgColor = AppColors.primaryLight;
        fgColor = AppColors.primary;
        break;
      case FitoraButtonVariant.outline:
        bgColor = Colors.white;
        fgColor = AppColors.textPrimary;
        borderSide = const BorderSide(color: AppColors.border, width: 1.2);
        break;
      case FitoraButtonVariant.text:
        bgColor = Colors.transparent;
        fgColor = AppColors.primary;
        break;
      case FitoraButtonVariant.danger:
        bgColor = AppColors.errorLight;
        fgColor = AppColors.error;
        break;
      case FitoraButtonVariant.ghost:
        bgColor = Colors.transparent;
        fgColor = AppColors.textSecondary;
        break;
    }

    final isInteractive = onPressed != null && !isLoading;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: isInteractive ? bgColor : AppColors.surfaceMuted,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.roundedMd,
          side: borderSide ?? BorderSide.none,
        ),
        child: InkWell(
          onTap: isInteractive ? onPressed : null,
          borderRadius: AppSpacing.roundedMd,
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          icon!,
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: AppTypography.labelLarge.copyWith(
                            color: isInteractive ? fgColor : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
