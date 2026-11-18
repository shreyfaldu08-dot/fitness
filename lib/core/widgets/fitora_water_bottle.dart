import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

class FitoraWaterBottle extends StatefulWidget {
  final int consumedMl;
  final int targetMl;
  final void Function(int deltaMl) onAddWater;

  const FitoraWaterBottle({
    super.key,
    required this.consumedMl,
    required this.targetMl,
    required this.onAddWater,
  });

  @override
  State<FitoraWaterBottle> createState() => _FitoraWaterBottleState();
}

class _FitoraWaterBottleState extends State<FitoraWaterBottle> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fillRatio = widget.targetMl > 0 ? (widget.consumedMl / widget.targetMl).clamp(0.0, 1.0) : 0.0;
    final percentage = (fillRatio * 100).round();
    final remainingMl = (widget.targetMl - widget.consumedMl).clamp(0, 10000);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Visual Water Bottle
            SizedBox(
              width: 84,
              height: 150,
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(84, 150),
                    painter: _WaterBottlePainter(
                      fillRatio: fillRatio,
                      wavePhase: _animController.value * 2 * math.pi,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.lg),

            // Hydration Details & Indicators
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.waterAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.water_drop_rounded, size: 14, color: AppColors.waterAccent),
                            const SizedBox(width: 4),
                            Text(
                              '$percentage% Hydrated',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.waterAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${widget.consumedMl} ml',
                        style: AppTypography.headingSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    remainingMl > 0
                        ? '$remainingMl ml left to reach your ${widget.targetMl} ml goal'
                        : 'Goal reached! Outstanding hydration today 🎉',
                    style: AppTypography.bodySmall.copyWith(
                      color: remainingMl > 0 ? AppColors.textSecondary : AppColors.success,
                      fontWeight: remainingMl > 0 ? FontWeight.normal : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Quick-Add Water Buttons
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickAddChip(
                        label: '+250ml',
                        icon: Icons.local_drink_rounded,
                        ml: 250,
                      ),
                      _buildQuickAddChip(
                        label: '+500ml',
                        icon: Icons.sports_bar_rounded,
                        ml: 500,
                      ),
                      _buildQuickAddChip(
                        label: '+100ml',
                        icon: Icons.opacity_rounded,
                        ml: 100,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAddChip({
    required String label,
    required IconData icon,
    required int ml,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => widget.onAddWater(ml),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.waterAccent.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AppColors.waterAccent),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.waterAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaterBottlePainter extends CustomPainter {
  final double fillRatio; // 0.0 to 1.0
  final double wavePhase;

  _WaterBottlePainter({
    required this.fillRatio,
    required this.wavePhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const capWidth = 32.0;
    const capHeight = 12.0;
    const neckWidth = 44.0;
    const neckHeight = 14.0;
    const cornerRadius = 14.0;

    final bodyTop = capHeight + neckHeight;
    final bodyHeight = size.height - bodyTop;
    final bodyWidth = size.width;

    // 1. Draw Bottle Cap
    final capRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, capHeight / 2),
        width: capWidth,
        height: capHeight,
      ),
      const Radius.circular(3),
    );
    final capPaint = Paint()..color = const Color(0xFF64748B);
    canvas.drawRRect(capRect, capPaint);

    // 2. Draw Bottle Neck
    final neckRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, capHeight + neckHeight / 2),
        width: neckWidth,
        height: neckHeight,
      ),
      const Radius.circular(2),
    );
    final neckPaint = Paint()..color = const Color(0xFF94A3B8);
    canvas.drawRRect(neckRect, neckPaint);

    // 3. Define Bottle Body Path
    final bodyPath = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0, bodyTop, bodyWidth, bodyHeight),
          topLeft: const Radius.circular(cornerRadius),
          topRight: const Radius.circular(cornerRadius),
          bottomLeft: const Radius.circular(cornerRadius),
          bottomRight: const Radius.circular(cornerRadius),
        ),
      );

    // Background bottle container (empty glass)
    final glassBgPaint = Paint()..color = const Color(0xFFF1F5F9);
    canvas.drawPath(bodyPath, glassBgPaint);

    // 4. Draw Animated Liquid Water Inside Clip
    canvas.save();
    canvas.clipPath(bodyPath);

    final waterTop = bodyTop + bodyHeight * (1.0 - fillRatio);
    final waterHeight = bodyTop + bodyHeight - waterTop;

    if (fillRatio > 0) {
      final waterPath = Path();
      waterPath.moveTo(0, size.height);
      waterPath.lineTo(0, waterTop);

      // Draw subtle wave
      final waveAmplitude = fillRatio > 0.98 || fillRatio < 0.02 ? 0.0 : 2.5;
      for (double x = 0; x <= bodyWidth; x += 2) {
        final y = waterTop + math.sin((x / bodyWidth * 2 * math.pi) + wavePhase) * waveAmplitude;
        waterPath.lineTo(x, y);
      }

      waterPath.lineTo(bodyWidth, size.height);
      waterPath.close();

      final waterGradient = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF38BDF8), // Light water cyan
          Color(0xFF0284C7), // Deep oceanic blue
        ],
      ).createShader(Rect.fromLTWH(0, waterTop, bodyWidth, waterHeight));

      final waterPaint = Paint()..shader = waterGradient;
      canvas.drawPath(waterPath, waterPaint);

      // Light reflection shimmer line on left
      final reflectionPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(8, waterTop + 10),
        Offset(8, size.height - 15),
        reflectionPaint,
      );
    }
    canvas.restore();

    // 5. Draw Measurement Tick Marks (1L, 2L, 3L)
    final tickPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1.2;

    final ticks = [0.25, 0.5, 0.75];
    for (final t in ticks) {
      final y = bodyTop + bodyHeight * (1.0 - t);
      canvas.drawLine(Offset(bodyWidth - 12, y), Offset(bodyWidth - 4, y), tickPaint);
    }

    // 6. Bottle Glass Border Outline
    final borderPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(bodyPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _WaterBottlePainter oldDelegate) {
    return oldDelegate.fillRatio != fillRatio || oldDelegate.wavePhase != wavePhase;
  }
}
