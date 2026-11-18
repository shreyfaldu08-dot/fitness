import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import 'fitora_muscle_badge.dart';

enum MuscleViewType { front, back, both }

class FitoraMuscleIllustration extends StatelessWidget {
  final String muscle;
  final double width;
  final double height;
  final bool showContainer;
  final bool? forceBackView;

  const FitoraMuscleIllustration({
    super.key,
    required this.muscle,
    this.width = 64,
    this.height = 78,
    this.showContainer = true,
    this.forceBackView,
  });

  static bool isBackMuscle(String muscleName) {
    final lower = muscleName.toLowerCase();
    if (lower.contains('back') ||
        lower.contains('lat') ||
        lower.contains('pull') ||
        lower.contains('row') ||
        lower.contains('trapezius') ||
        lower.contains('trap') ||
        lower.contains('tricep') ||
        lower.contains('glute') ||
        lower.contains('hamstring') ||
        lower.contains('deadlift') ||
        lower.contains('rhomboid') ||
        lower.contains('rear')) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isBack = forceBackView ?? isBackMuscle(muscle);
    final highlightColor = FitoraMuscleBadge.getMuscleColor(muscle);

    final content = CustomPaint(
      size: Size(width, height),
      painter: _RealisticAnatomyPainter(
        muscle: muscle,
        isBackView: isBack,
        highlightColor: highlightColor,
      ),
    );

    if (!showContainer) return content;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120), // Premium midnight athletic slate
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: highlightColor.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: highlightColor.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Subtle Grid & Lighting Vignette
            Positioned.fill(
              child: Opacity(
                opacity: 0.12,
                child: CustomPaint(painter: _AnatomyGridPainter()),
              ),
            ),
            // The Realistic Anatomy Silhouette
            content,
            // Small Anterior/Posterior indicator badge
            Positioned(
              top: 3,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isBack ? 'POST' : 'ANT',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 7.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FitoraAnatomyCard extends StatefulWidget {
  final String primaryMuscle;
  final List<String> secondaryMuscles;
  final String exerciseName;
  final String equipment;
  final String? demoImageUrl;

  const FitoraAnatomyCard({
    super.key,
    required this.primaryMuscle,
    this.secondaryMuscles = const [],
    required this.exerciseName,
    this.equipment = 'Barbell',
    this.demoImageUrl,
  });

  @override
  State<FitoraAnatomyCard> createState() => _FitoraAnatomyCardState();
}

class _FitoraAnatomyCardState extends State<FitoraAnatomyCard> {
  int _selectedView = 0; // 0: Dual Anatomy Map, 1: Movement Photo Demo

  @override
  Widget build(BuildContext context) {
    final highlightColor = FitoraMuscleBadge.getMuscleColor(widget.primaryMuscle);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120), // Deep midnight pro slate
        borderRadius: AppSpacing.roundedLg,
        boxShadow: [
          BoxShadow(
            color: highlightColor.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: highlightColor.withValues(alpha: 0.45), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info & View Switcher
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: highlightColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: highlightColor,
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'MUSCLE TARGET ARCHITECTURE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.equipment.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // View mode pill switcher
          Row(
            children: [
              _buildViewTab(0, '3D Muscle Scan', Icons.accessibility_new_rounded, highlightColor),
              const SizedBox(width: 8),
              _buildViewTab(1, 'Exercise Movement Demo', Icons.play_circle_fill_rounded, highlightColor),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Content body
          if (_selectedView == 0) ...[
            // Dual Body Map: Anterior (Front) and Posterior (Back)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Anterior (Front Body)
                Expanded(
                  child: Container(
                    height: 190,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'ANTERIOR (FRONT)',
                          style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.4),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: CustomPaint(
                            size: const Size(double.infinity, 160),
                            painter: _RealisticAnatomyPainter(
                              muscle: widget.primaryMuscle,
                              isBackView: false,
                              highlightColor: highlightColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Posterior (Back Body)
                Expanded(
                  child: Container(
                    height: 190,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'POSTERIOR (BACK)',
                          style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.4),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: CustomPaint(
                            size: const Size(double.infinity, 160),
                            painter: _RealisticAnatomyPainter(
                              muscle: widget.primaryMuscle,
                              isBackView: true,
                              highlightColor: highlightColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Photo Demonstration Mode
            Container(
              height: 190,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: highlightColor.withValues(alpha: 0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      widget.demoImageUrl ?? 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=600&auto=format&fit=crop',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fitness_center_rounded, size: 48, color: highlightColor),
                            const SizedBox(height: 8),
                            Text(widget.exerciseName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    // Dark Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.75),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 14,
                      right: 14,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.exerciseName,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: highlightColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.primaryMuscle,
                              style: const TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),

          // High-Contrast Muscle Callout Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: highlightColor.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: highlightColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Target Muscle (Primary)',
                            style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.primaryMuscle,
                        style: TextStyle(
                          color: highlightColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.secondaryMuscles.isNotEmpty) ...[
                  Container(width: 1, height: 32, color: Colors.white12),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Secondary Synergists',
                          style: TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.secondaryMuscles.join(', '),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewTab(int index, String label, IconData icon, Color color) {
    final isSelected = _selectedView == index;
    return InkWell(
      onTap: () => setState(() => _selectedView = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.white10,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? color : Colors.white60),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ultra-Realistic, organically contoured athletic humanoid anatomy painter.
class _RealisticAnatomyPainter extends CustomPainter {
  final String muscle;
  final bool isBackView;
  final Color highlightColor;

  _RealisticAnatomyPainter({
    required this.muscle,
    required this.isBackView,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Normalizing scale to reference coordinate space 100 x 160
    final scale = math.min(size.width / 100.0, size.height / 160.0);
    final dx = (size.width - 100.0 * scale) / 2.0;
    final dy = (size.height - 160.0 * scale) / 2.0;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale, scale);

    final m = muscle.toLowerCase();

    // Muscle classification flags
    final isChest = !isBackView && (m.contains('chest') || m.contains('pec') || m.contains('bench') || m.contains('push-up') || m.contains('dip'));
    final isBack = isBackView && (m.contains('back') || m.contains('lat') || m.contains('pulldown') || m.contains('pull-up') || m.contains('row') || m.contains('rhomboid'));
    final isTraps = isBackView && (m.contains('trap') || m.contains('shrug') || m.contains('upper back'));
    final isShoulders = m.contains('shoulder') || m.contains('deltoid') || m.contains('lateral') || m.contains('overhead') || m.contains('military');
    final isBiceps = !isBackView && (m.contains('bicep') || m.contains('curl'));
    final isTriceps = isBackView && (m.contains('tricep') || m.contains('skull') || m.contains('pushdown') || m.contains('extension'));
    final isAbs = !isBackView && (m.contains('ab') || m.contains('core') || m.contains('plank') || m.contains('crunch') || m.contains('oblique'));
    final isQuads = !isBackView && (m.contains('quad') || m.contains('squat') || m.contains('lunge') || m.contains('leg press') || m.contains('leg'));
    final isGlutes = isBackView && (m.contains('glute') || m.contains('hip thrust') || m.contains('deadlift'));
    final isHamstrings = isBackView && (m.contains('hamstring') || m.contains('rdl') || m.contains('deadlift'));
    final isCalves = m.contains('calf') || m.contains('calves') || m.contains('gastrocnemius');
    final isFullBody = m.contains('full body') || m.contains('cardio') || m.contains('burpee');

    // Anatomical base slate body (dark 3D gradient)
    final baseBodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2D3748), Color(0xFF1E293B)],
      ).createShader(const Rect.fromLTWH(0, 0, 100, 160))
      ..style = PaintingStyle.fill;

    // Active Highlight Shader
    Paint createHighlightPaint(Rect bounds) {
      return Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.8,
          colors: [
            highlightColor,
            Color.lerp(highlightColor, Colors.black, 0.3)!,
          ],
        ).createShader(bounds)
        ..style = PaintingStyle.fill;
    }

    Paint createGlowPaint() {
      return Paint()
        ..color = highlightColor.withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0)
        ..style = PaintingStyle.fill;
    }

    final contourLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // 1. HEAD & ATHLETIC JAWLINE
    final headPath = Path()
      ..addOval(const Rect.fromLTWH(42.5, 6, 15, 17));
    canvas.drawPath(headPath, baseBodyPaint);
    canvas.drawPath(headPath, contourLinePaint);

    // Neck with Trapezius taper
    final neckPath = Path()
      ..moveTo(46, 21)
      ..lineTo(54, 21)
      ..cubicTo(56, 24, 58, 27, 62, 28)
      ..lineTo(38, 28)
      ..cubicTo(42, 27, 44, 24, 46, 21)
      ..close();
    canvas.drawPath(neckPath, baseBodyPaint);

    // 2. SHOULDERS / DELTOIDS (Natural sculpted rounded caps)
    final leftDeltoidPath = Path()
      ..moveTo(38, 28)
      ..cubicTo(32, 29, 25, 33, 24, 39)
      ..cubicTo(23, 46, 28, 51, 33, 50)
      ..cubicTo(36, 48, 38, 41, 38, 35)
      ..close();

    final rightDeltoidPath = Path()
      ..moveTo(62, 28)
      ..cubicTo(68, 29, 75, 33, 76, 39)
      ..cubicTo(77, 46, 72, 51, 67, 50)
      ..cubicTo(64, 48, 62, 41, 62, 35)
      ..close();

    if (isShoulders || isFullBody) {
      canvas.drawPath(leftDeltoidPath, createGlowPaint());
      canvas.drawPath(rightDeltoidPath, createGlowPaint());
      canvas.drawPath(leftDeltoidPath, createHighlightPaint(leftDeltoidPath.getBounds()));
      canvas.drawPath(rightDeltoidPath, createHighlightPaint(rightDeltoidPath.getBounds()));
    } else {
      canvas.drawPath(leftDeltoidPath, baseBodyPaint);
      canvas.drawPath(rightDeltoidPath, baseBodyPaint);
      canvas.drawPath(leftDeltoidPath, contourLinePaint);
      canvas.drawPath(rightDeltoidPath, contourLinePaint);
    }

    // 3. ANTERIOR (FRONT) TORSO: PECTORALS & ABDOMINALS
    if (!isBackView) {
      // Pectoralis Major (Realistic curved anatomical chest plates)
      final leftPecPath = Path()
        ..moveTo(49, 29)
        ..lineTo(39, 29)
        ..cubicTo(33, 33, 34, 44, 40, 46)
        ..cubicTo(44, 47, 48, 46, 49, 45)
        ..close();

      final rightPecPath = Path()
        ..moveTo(51, 29)
        ..lineTo(61, 29)
        ..cubicTo(67, 33, 66, 44, 60, 46)
        ..cubicTo(56, 47, 52, 46, 51, 45)
        ..close();

      if (isChest || isFullBody) {
        canvas.drawPath(leftPecPath, createGlowPaint());
        canvas.drawPath(rightPecPath, createGlowPaint());
        canvas.drawPath(leftPecPath, createHighlightPaint(leftPecPath.getBounds()));
        canvas.drawPath(rightPecPath, createHighlightPaint(rightPecPath.getBounds()));
      } else {
        canvas.drawPath(leftPecPath, baseBodyPaint);
        canvas.drawPath(rightPecPath, baseBodyPaint);
        canvas.drawPath(leftPecPath, contourLinePaint);
        canvas.drawPath(rightPecPath, contourLinePaint);
      }

      // Rectus Abdominis (Athletic 6-pack with smooth tendinous intersections)
      final absBounds = const Rect.fromLTWH(42, 48, 16, 26);
      final absPath = Path();
      final absSegments = [
        RRect.fromLTRBAndCorners(43.5, 48, 49, 55, topLeft: const Radius.circular(2), bottomLeft: const Radius.circular(2)),
        RRect.fromLTRBAndCorners(51, 48, 56.5, 55, topRight: const Radius.circular(2), bottomRight: const Radius.circular(2)),
        RRect.fromLTRBAndCorners(43.5, 56.5, 49, 64, topLeft: const Radius.circular(2), bottomLeft: const Radius.circular(2)),
        RRect.fromLTRBAndCorners(51, 56.5, 56.5, 64, topRight: const Radius.circular(2), bottomRight: const Radius.circular(2)),
        RRect.fromLTRBAndCorners(44, 65.5, 49, 73, topLeft: const Radius.circular(2), bottomLeft: const Radius.circular(3)),
        RRect.fromLTRBAndCorners(51, 65.5, 56, 73, topRight: const Radius.circular(2), bottomRight: const Radius.circular(3)),
      ];
      for (final r in absSegments) {
        absPath.addRRect(r);
      }

      // External Obliques (Athletic V-taper flank)
      final leftObliquePath = Path()
        ..moveTo(37, 47)
        ..cubicTo(36, 55, 38, 67, 43, 74)
        ..lineTo(44, 73)
        ..cubicTo(41, 65, 40, 55, 40, 47)
        ..close();

      final rightObliquePath = Path()
        ..moveTo(63, 47)
        ..cubicTo(64, 55, 62, 67, 57, 74)
        ..lineTo(56, 73)
        ..cubicTo(59, 65, 60, 55, 60, 47)
        ..close();

      if (isAbs || isFullBody) {
        canvas.drawPath(absPath, createGlowPaint());
        canvas.drawPath(absPath, createHighlightPaint(absBounds));
        canvas.drawPath(leftObliquePath, createGlowPaint());
        canvas.drawPath(rightObliquePath, createGlowPaint());
        canvas.drawPath(leftObliquePath, createHighlightPaint(leftObliquePath.getBounds()));
        canvas.drawPath(rightObliquePath, createHighlightPaint(rightObliquePath.getBounds()));
      } else {
        canvas.drawPath(absPath, baseBodyPaint);
        canvas.drawPath(absPath, contourLinePaint);
        canvas.drawPath(leftObliquePath, baseBodyPaint);
        canvas.drawPath(rightObliquePath, baseBodyPaint);
      }

      // Pelvis / Waist
      final pelvisPath = Path()
        ..moveTo(43, 74)
        ..lineTo(57, 74)
        ..lineTo(55, 83)
        ..lineTo(45, 83)
        ..close();
      canvas.drawPath(pelvisPath, baseBodyPaint);
    } else {
      // POSTERIOR (BACK) TORSO: TRAPEZIUS, LATS & ERECTORS
      // Diamond Trapezius
      final trapsPath = Path()
        ..moveTo(50, 21)
        ..lineTo(59, 28)
        ..lineTo(50, 47)
        ..lineTo(41, 28)
        ..close();

      if (isTraps || isBack || isFullBody) {
        canvas.drawPath(trapsPath, createGlowPaint());
        canvas.drawPath(trapsPath, createHighlightPaint(trapsPath.getBounds()));
      } else {
        canvas.drawPath(trapsPath, baseBodyPaint);
        canvas.drawPath(trapsPath, contourLinePaint);
      }

      // Latissimus Dorsi (Dramatic V-Taper Back Wings)
      final leftLatPath = Path()
        ..moveTo(41, 33)
        ..cubicTo(34, 40, 33, 58, 41, 68)
        ..lineTo(47, 67)
        ..lineTo(47, 46)
        ..close();

      final rightLatPath = Path()
        ..moveTo(59, 33)
        ..cubicTo(66, 40, 67, 58, 59, 68)
        ..lineTo(53, 67)
        ..lineTo(53, 46)
        ..close();

      if (isBack || isFullBody) {
        canvas.drawPath(leftLatPath, createGlowPaint());
        canvas.drawPath(rightLatPath, createGlowPaint());
        canvas.drawPath(leftLatPath, createHighlightPaint(leftLatPath.getBounds()));
        canvas.drawPath(rightLatPath, createHighlightPaint(rightLatPath.getBounds()));
      } else {
        canvas.drawPath(leftLatPath, baseBodyPaint);
        canvas.drawPath(rightLatPath, baseBodyPaint);
        canvas.drawPath(leftLatPath, contourLinePaint);
        canvas.drawPath(rightLatPath, contourLinePaint);
      }

      // Erector Spinae (Lower back columns)
      final lowerBackPath = Path()
        ..addRect(const Rect.fromLTWH(47, 67, 6, 8));
      canvas.drawPath(lowerBackPath, baseBodyPaint);
    }

    // 4. ARMS: BICEPS (Front), TRICEPS (Back) & FOREARMS
    final leftArmPath = Path()
      ..moveTo(33, 48)
      ..cubicTo(28, 51, 26, 60, 28, 67)
      ..lineTo(34, 66)
      ..cubicTo(35, 59, 36, 52, 33, 48)
      ..close();

    final rightArmPath = Path()
      ..moveTo(67, 48)
      ..cubicTo(72, 51, 74, 60, 72, 67)
      ..lineTo(66, 66)
      ..cubicTo(65, 59, 64, 52, 67, 48)
      ..close();

    final isArmActive = (!isBackView && isBiceps) || (isBackView && isTriceps) || isFullBody;
    if (isArmActive) {
      canvas.drawPath(leftArmPath, createGlowPaint());
      canvas.drawPath(rightArmPath, createGlowPaint());
      canvas.drawPath(leftArmPath, createHighlightPaint(leftArmPath.getBounds()));
      canvas.drawPath(rightArmPath, createHighlightPaint(rightArmPath.getBounds()));
    } else {
      canvas.drawPath(leftArmPath, baseBodyPaint);
      canvas.drawPath(rightArmPath, baseBodyPaint);
      canvas.drawPath(leftArmPath, contourLinePaint);
      canvas.drawPath(rightArmPath, contourLinePaint);
    }

    // Muscular Forearms tapering to Hands
    final leftForearmPath = Path()
      ..moveTo(28, 67)
      ..cubicTo(26, 73, 23, 83, 25, 87)
      ..lineTo(29, 87)
      ..cubicTo(32, 81, 33, 73, 34, 66)
      ..close();

    final rightForearmPath = Path()
      ..moveTo(72, 67)
      ..cubicTo(74, 73, 77, 83, 75, 87)
      ..lineTo(71, 87)
      ..cubicTo(68, 81, 67, 73, 66, 66)
      ..close();

    canvas.drawPath(leftForearmPath, baseBodyPaint);
    canvas.drawPath(rightForearmPath, baseBodyPaint);
    canvas.drawPath(leftForearmPath, contourLinePaint);
    canvas.drawPath(rightForearmPath, contourLinePaint);

    // Sculpted Hands
    canvas.drawOval(const Rect.fromLTWH(24, 87, 5, 7), baseBodyPaint);
    canvas.drawOval(const Rect.fromLTWH(71, 87, 5, 7), baseBodyPaint);

    // 5. POSTERIOR: GLUTEUS MAXIMUS (Sculpted Glutes)
    if (isBackView) {
      final leftGlutePath = Path()
        ..moveTo(49, 74)
        ..lineTo(39, 74)
        ..cubicTo(34, 82, 37, 91, 48, 92)
        ..lineTo(49, 92)
        ..close();

      final rightGlutePath = Path()
        ..moveTo(51, 74)
        ..lineTo(61, 74)
        ..cubicTo(66, 82, 63, 91, 52, 92)
        ..lineTo(51, 92)
        ..close();

      if (isGlutes || isFullBody) {
        canvas.drawPath(leftGlutePath, createGlowPaint());
        canvas.drawPath(rightGlutePath, createGlowPaint());
        canvas.drawPath(leftGlutePath, createHighlightPaint(leftGlutePath.getBounds()));
        canvas.drawPath(rightGlutePath, createHighlightPaint(rightGlutePath.getBounds()));
      } else {
        canvas.drawPath(leftGlutePath, baseBodyPaint);
        canvas.drawPath(rightGlutePath, baseBodyPaint);
        canvas.drawPath(leftGlutePath, contourLinePaint);
        canvas.drawPath(rightGlutePath, contourLinePaint);
      }
    }

    // 6. THIGHS: QUADRICEPS (Front) vs HAMSTRINGS (Back)
    final thighTopY = isBackView ? 92.0 : 83.0;

    final leftThighPath = Path()
      ..moveTo(45, thighTopY)
      ..cubicTo(35, thighTopY + 3, 31, 108, 38, 120)
      ..lineTo(45, 120)
      ..cubicTo(47, 106, 48, 94, 48, thighTopY)
      ..close();

    final rightThighPath = Path()
      ..moveTo(55, thighTopY)
      ..cubicTo(65, thighTopY + 3, 69, 108, 62, 120)
      ..lineTo(55, 120)
      ..cubicTo(53, 106, 52, 94, 52, thighTopY)
      ..close();

    final isThighActive = (!isBackView && isQuads) || (isBackView && isHamstrings) || isFullBody;
    if (isThighActive) {
      canvas.drawPath(leftThighPath, createGlowPaint());
      canvas.drawPath(rightThighPath, createGlowPaint());
      canvas.drawPath(leftThighPath, createHighlightPaint(leftThighPath.getBounds()));
      canvas.drawPath(rightThighPath, createHighlightPaint(rightThighPath.getBounds()));
    } else {
      canvas.drawPath(leftThighPath, baseBodyPaint);
      canvas.drawPath(rightThighPath, baseBodyPaint);
      canvas.drawPath(leftThighPath, contourLinePaint);
      canvas.drawPath(rightThighPath, contourLinePaint);
    }

    // Patella Knees
    final leftKnee = Path()..addOval(const Rect.fromLTWH(39.5, 120, 5, 5));
    final rightKnee = Path()..addOval(const Rect.fromLTWH(55.5, 120, 5, 5));
    canvas.drawPath(leftKnee, baseBodyPaint);
    canvas.drawPath(rightKnee, baseBodyPaint);

    // 7. CALVES & LOWER LEGS (Diamond Gastrocnemius)
    final leftCalfPath = Path()
      ..moveTo(39, 125)
      ..cubicTo(33, 131, 35, 142, 40, 152)
      ..lineTo(44, 152)
      ..cubicTo(46, 141, 45, 131, 44, 125)
      ..close();

    final rightCalfPath = Path()
      ..moveTo(61, 125)
      ..cubicTo(67, 131, 65, 142, 60, 152)
      ..lineTo(56, 152)
      ..cubicTo(54, 141, 55, 131, 56, 125)
      ..close();

    if (isCalves || isFullBody) {
      canvas.drawPath(leftCalfPath, createGlowPaint());
      canvas.drawPath(rightCalfPath, createGlowPaint());
      canvas.drawPath(leftCalfPath, createHighlightPaint(leftCalfPath.getBounds()));
      canvas.drawPath(rightCalfPath, createHighlightPaint(rightCalfPath.getBounds()));
    } else {
      canvas.drawPath(leftCalfPath, baseBodyPaint);
      canvas.drawPath(rightCalfPath, baseBodyPaint);
      canvas.drawPath(leftCalfPath, contourLinePaint);
      canvas.drawPath(rightCalfPath, contourLinePaint);
    }

    // Sculpted Athletic Feet
    final leftFootPath = Path()
      ..moveTo(39, 152)
      ..lineTo(33, 158)
      ..lineTo(43, 158)
      ..close();
    final rightFootPath = Path()
      ..moveTo(61, 152)
      ..lineTo(67, 158)
      ..lineTo(57, 158)
      ..close();
    canvas.drawPath(leftFootPath, baseBodyPaint);
    canvas.drawPath(rightFootPath, baseBodyPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RealisticAnatomyPainter oldDelegate) {
    return oldDelegate.muscle != muscle ||
        oldDelegate.isBackView != isBackView ||
        oldDelegate.highlightColor != highlightColor;
  }
}

class _AnatomyGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF38BDF8) // High-tech cyan grid
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 14) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 14) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
