import 'package:flutter/material.dart';

/// Clean minimalist Capsule Week Streak Tracker.
/// Displays daily consistency as vertical stadium pills.
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER ROW: Capsule Streak Pill + Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                    Text(
                      '$streakDays-DAY STREAK',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB45309),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Week 4 Consistency',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 7 VERTICAL CAPSULE PILLS ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isToday = (index + 1) == todayWeekday;
              final isDone = index < daysCompleted.length ? daysCompleted[index] : false;
              final isPast = (index + 1) < todayWeekday;

              Color capsuleBg;
              Color capsuleBorder;
              Color textColor;
              Widget statusWidget;

              if (isDone) {
                capsuleBg = const Color(0xFFDCFCE7);
                capsuleBorder = const Color(0xFF86EFAC);
                textColor = const Color(0xFF166534);
                statusWidget = Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                );
              } else if (isToday) {
                capsuleBg = const Color(0xFFEFF6FF);
                capsuleBorder = const Color(0xFF3B82F6);
                textColor = const Color(0xFF1D4ED8);
                statusWidget = Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
                );
              } else if (isPast) {
                capsuleBg = const Color(0xFFF8FAFC);
                capsuleBorder = const Color(0xFFE2E8F0);
                textColor = const Color(0xFF94A3B8);
                statusWidget = Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFCBD5E1),
                    shape: BoxShape.circle,
                  ),
                );
              } else {
                capsuleBg = Colors.white;
                capsuleBorder = const Color(0xFFE2E8F0);
                textColor = const Color(0xFF94A3B8);
                statusWidget = Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                  ),
                );
              }

              return Container(
                width: 38,
                height: 68,
                decoration: BoxDecoration(
                  color: capsuleBg,
                  borderRadius: BorderRadius.circular(999), // Stadium Capsule Shape
                  border: Border.all(
                    color: capsuleBorder,
                    width: isToday ? 1.8 : 1.0,
                  ),
                  boxShadow: isToday
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      dayLabels[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    statusWidget,
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
