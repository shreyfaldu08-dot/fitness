import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

class FitoraConcentricRings extends StatelessWidget {
  final double moveProgress; // Active calories (0.0 - 1.0+)
  final double exerciseProgress; // Active minutes (0.0 - 1.0+)
  final double standProgress; // Steps (0.0 - 1.0+)
  final int moveValue;
  final int moveTarget;
  final int exerciseValue;
  final int exerciseTarget;
  final int standValue;
  final int standTarget;
  final double size;

  const FitoraConcentricRings({
    super.key,
    required this.moveProgress,
    required this.exerciseProgress,
    required this.standProgress,
    required this.moveValue,
    required this.moveTarget,
    required this.exerciseValue,
    required this.exerciseTarget,
    required this.standValue,
    required this.standTarget,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Concentric Rings Canvas
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            size: Size(size, size),
            painter: _ConcentricRingsPainter(
              moveProgress: moveProgress,
              exerciseProgress: exerciseProgress,
              standProgress: standProgress,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 24),
                  Text(
                    '${((moveProgress + exerciseProgress + standProgress) / 3 * 100).round()}%',
                    style: AppTypography.headingSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),

        // Visual Legends & Metric Tiles
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendRow(
                color: const Color(0xFFEF4444), // Coral Red: Move/Burned
                icon: Icons.local_fire_department_rounded,
                label: 'Move / Burned',
                value: '$moveValue kcal',
                target: '/ $moveTarget kcal',
                progress: moveProgress,
              ),
              const SizedBox(height: 10),
              _buildLegendRow(
                color: const Color(0xFF10B981), // Emerald Green: Exercise
                icon: Icons.timer_outlined,
                label: 'Exercise',
                value: '${exerciseValue}m',
                target: '/ ${exerciseTarget}m',
                progress: exerciseProgress,
              ),
              const SizedBox(height: 10),
              _buildLegendRow(
                color: const Color(0xFF06B6D4), // Sky Blue: Steps
                icon: Icons.directions_walk_rounded,
                label: 'Steps',
                value: '$standValue',
                target: '/ $standTarget',
                progress: standProgress,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendRow({
    required Color color,
    required IconData icon,
    required String label,
    required String value,
    required String target,
    required double progress,
  }) {
    final pct = (progress * 100).round();
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 15),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary)),
                  Text('$pct%', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold, color: color)),
                ],
              ),
              const SizedBox(height: 1),
              Row(
                children: [
                  Text(value, style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(width: 3),
                  Text(target, style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConcentricRingsPainter extends CustomPainter {
  final double moveProgress;
  final double exerciseProgress;
  final double standProgress;

  _ConcentricRingsPainter({
    required this.moveProgress,
    required this.exerciseProgress,
    required this.standProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 9.0;
    const spacing = 3.5;

    final outerRadius = (size.width - strokeWidth) / 2;
    final middleRadius = outerRadius - strokeWidth - spacing;
    final innerRadius = middleRadius - strokeWidth - spacing;

    // Draw Outer Ring (Move / Burned - Red/Coral)
    _drawRing(
      canvas,
      center,
      outerRadius,
      strokeWidth,
      const Color(0xFFEF4444),
      moveProgress,
    );

    // Draw Middle Ring (Exercise - Emerald Green)
    _drawRing(
      canvas,
      center,
      middleRadius,
      strokeWidth,
      const Color(0xFF10B981),
      exerciseProgress,
    );

    // Draw Inner Ring (Steps / Stand - Sky Blue)
    _drawRing(
      canvas,
      center,
      innerRadius,
      strokeWidth,
      const Color(0xFF06B6D4),
      standProgress,
    );
  }

  void _drawRing(
    Canvas canvas,
    Offset center,
    double radius,
    double strokeWidth,
    Color color,
    double progress,
  ) {
    // Background track
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, bgPaint);

    // Active Arc
    if (progress > 0) {
      final fgPaint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConcentricRingsPainter oldDelegate) {
    return oldDelegate.moveProgress != moveProgress ||
        oldDelegate.exerciseProgress != exerciseProgress ||
        oldDelegate.standProgress != standProgress;
  }
}
