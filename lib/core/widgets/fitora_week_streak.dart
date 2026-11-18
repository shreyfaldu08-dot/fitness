import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

class FitoraWeekStreak extends StatelessWidget {
  final int streakDays;
  final List<bool> daysCompleted; // 7 booleans for Monday through Sunday

  const FitoraWeekStreak({
    super.key,
    required this.streakDays,
    required this.daysCompleted,
  });

  @override
  Widget build(BuildContext context) {
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final todayWeekday = DateTime.now().weekday; // 1 = Mon, 7 = Sun

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text('$streakDays-Day Consistency Streak', style: AppTypography.labelLarge),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Week 4',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // 7-Day Visual Circles Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isToday = (index + 1) == todayWeekday;
              final isDone = index < daysCompleted.length ? daysCompleted[index] : false;
              final isPast = (index + 1) < todayWeekday;

              Color circleBg;
              Color borderColor;
              Widget iconChild;

              if (isDone) {
                circleBg = const Color(0xFF10B981);
                borderColor = const Color(0xFF10B981);
                iconChild = const Icon(Icons.check_rounded, color: Colors.white, size: 16);
              } else if (isToday) {
                circleBg = AppColors.primaryLight;
                borderColor = AppColors.primary;
                iconChild = const Icon(Icons.fitness_center_rounded, color: AppColors.primary, size: 14);
              } else if (isPast) {
                circleBg = const Color(0xFFF1F5F9);
                borderColor = const Color(0xFFE2E8F0);
                iconChild = const Icon(Icons.remove_rounded, color: Color(0xFF94A3B8), size: 14);
              } else {
                circleBg = Colors.white;
                borderColor = AppColors.border;
                iconChild = const SizedBox();
              }

              return Column(
                children: [
                  Text(
                    dayLabels[index],
                    style: AppTypography.labelSmall.copyWith(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: circleBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor, width: isToday ? 2.0 : 1.2),
                      boxShadow: isDone
                          ? [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Center(child: iconChild),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
