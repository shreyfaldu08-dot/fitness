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
    this.width = 62,
    this.height = 74,
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
      painter: _HumanAnatomyPainter(
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
        color: const Color(0xFF0F172A), // Dark slate aesthetic for medical/fitness anatomy
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: highlightColor.withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: highlightColor.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Subtle Grid Background
            Positioned.fill(
              child: Opacity(
                opacity: 0.08,
                child: CustomPaint(painter: _AnatomyGridPainter()),
              ),
            ),
            // The Anatomy Silhouette
            content,
            // Small Front/Back indicator badge
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
                    color: Colors.white70,
                    fontSize: 7.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
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

class FitoraAnatomyCard extends StatelessWidget {
  final String primaryMuscle;
  final List<String> secondaryMuscles;
  final String exerciseName;
  final String equipment;

  const FitoraAnatomyCard({
    super.key,
    required this.primaryMuscle,
    this.secondaryMuscles = const [],
    required this.exerciseName,
    this.equipment = 'Barbell',
  });

  @override
  Widget build(BuildContext context) {
    final highlightColor = FitoraMuscleBadge.getMuscleColor(primaryMuscle);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark slate pro aesthetic
        borderRadius: AppSpacing.roundedLg,
        boxShadow: [
          BoxShadow(
            color: highlightColor.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: highlightColor.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: highlightColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: highlightColor,
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'ANATOMICAL TARGET MAP',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
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
                  equipment.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Dual Body Map: Anterior (Front) and Posterior (Back)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Anterior (Front Body)
              Column(
                children: [
                  const Text(
                    'ANTERIOR (FRONT)',
                    style: TextStyle(color: Colors.white54, fontSize: 9.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 120,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: CustomPaint(
                      size: const Size(120, 160),
                      painter: _HumanAnatomyPainter(
                        muscle: primaryMuscle,
                        isBackView: false,
                        highlightColor: highlightColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),

              // Posterior (Back Body)
              Column(
                children: [
                  const Text(
                    'POSTERIOR (BACK)',
                    style: TextStyle(color: Colors.white54, fontSize: 9.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 120,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: CustomPaint(
                      size: const Size(120, 160),
                      painter: _HumanAnatomyPainter(
                        muscle: primaryMuscle,
                        isBackView: true,
                        highlightColor: highlightColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Muscle Target Callout Chips
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
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
                            'Primary Agonist',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        primaryMuscle,
                        style: TextStyle(
                          color: highlightColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (secondaryMuscles.isNotEmpty) ...[
                  Container(width: 1, height: 28, color: Colors.white12),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Synergists / Secondary',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          secondaryMuscles.join(', '),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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
}

class _HumanAnatomyPainter extends CustomPainter {
  final String muscle;
  final bool isBackView;
  final Color highlightColor;

  _HumanAnatomyPainter({
    required this.muscle,
    required this.isBackView,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Normalizing scale to reference 100 x 160
    final scaleX = size.width / 100.0;
    final scaleY = size.height / 160.0;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    final m = muscle.toLowerCase();

    // Muscle classification flags
    final isChest = !isBackView && (m.contains('chest') || m.contains('pec') || m.contains('bench') || m.contains('push-up') || m.contains('dip'));
    final isBack = isBackView && (m.contains('back') || m.contains('lat') || m.contains('pulldown') || m.contains('pull-up') || m.contains('row') || m.contains('rhomboid'));
    final isTraps = isBackView && (m.contains('trap') || m.contains('shrug') || m.contains('upper back'));
    final isShoulders = m.contains('shoulder') || m.contains('deltoid') || m.contains('lateral') || m.contains('overhead') || m.contains('military');
    final isBiceps = !isBackView && (m.contains('bicep') || m.contains('curl'));
    final isTriceps = isBackView && (m.contains('tricep') || m.contains('skull') || m.contains('pushdown'));
    final isAbs = !isBackView && (m.contains('ab') || m.contains('core') || m.contains('plank') || m.contains('crunch') || m.contains('leg raise'));
    final isQuads = !isBackView && (m.contains('quad') || m.contains('squat') || m.contains('lunge') || m.contains('leg press') || m.contains('leg'));
    final isGlutes = isBackView && (m.contains('glute') || m.contains('hip thrust') || m.contains('deadlift'));
    final isHamstrings = isBackView && (m.contains('hamstring') || m.contains('rdl') || m.contains('deadlift'));
    final isCalves = m.contains('calf') || m.contains('calves') || m.contains('gastrocnemius');
    final isFullBody = m.contains('full body') || m.contains('cardio') || m.contains('burpee');

    final neutralBasePaint = Paint()
      ..color = const Color(0xFF334155) // Slate-700 athletic base
      ..style = PaintingStyle.fill;

    Paint getMusclePaint(bool isTarget) {
      if (isTarget || isFullBody) {
        return Paint()
          ..color = highlightColor
          ..style = PaintingStyle.fill;
      }
      return neutralBasePaint;
    }

    Paint getMuscleGlowPaint() {
      return Paint()
        ..color = highlightColor.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0)
        ..style = PaintingStyle.fill;
    }

    // 1. HEAD & NECK
    canvas.drawCircle(const Offset(50, 14), 7.5, neutralBasePaint);
    final neckPath = Path()
      ..moveTo(47, 21)
      ..lineTo(53, 21)
      ..lineTo(55, 27)
      ..lineTo(45, 27)
      ..close();
    canvas.drawPath(neckPath, neutralBasePaint);

    // 2. SHOULDERS / DELTOIDS
    final leftDeltoid = Path()
      ..moveTo(43, 27)
      ..cubicTo(37, 27, 28, 30, 28, 36)
      ..cubicTo(28, 44, 34, 46, 36, 46)
      ..cubicTo(39, 44, 42, 38, 43, 27)
      ..close();

    final rightDeltoid = Path()
      ..moveTo(57, 27)
      ..cubicTo(63, 27, 72, 30, 72, 36)
      ..cubicTo(72, 44, 66, 46, 64, 46)
      ..cubicTo(61, 44, 58, 38, 57, 27)
      ..close();

    if (isShoulders) {
      canvas.drawPath(leftDeltoid, getMuscleGlowPaint());
      canvas.drawPath(rightDeltoid, getMuscleGlowPaint());
    }
    canvas.drawPath(leftDeltoid, getMusclePaint(isShoulders));
    canvas.drawPath(rightDeltoid, getMusclePaint(isShoulders));

    // 3. UPPER BODY: CHEST (Front) vs TRAPS & LATS (Back)
    if (!isBackView) {
      // Pectoralis Major (Chest) Left & Right
      final leftPec = Path()
        ..moveTo(49, 28)
        ..lineTo(43, 28)
        ..cubicTo(38, 31, 38, 43, 44, 44)
        ..lineTo(49, 44)
        ..close();

      final rightPec = Path()
        ..moveTo(51, 28)
        ..lineTo(57, 28)
        ..cubicTo(62, 31, 62, 43, 56, 44)
        ..lineTo(51, 44)
        ..close();

      if (isChest) {
        canvas.drawPath(leftPec, getMuscleGlowPaint());
        canvas.drawPath(rightPec, getMuscleGlowPaint());
      }
      canvas.drawPath(leftPec, getMusclePaint(isChest));
      canvas.drawPath(rightPec, getMusclePaint(isChest));

      // Rectus Abdominis (Abs / Core)
      final absPath = Path();
      // 6-pack segments
      final absSegments = [
        const Rect.fromLTWH(44, 46, 5.5, 7),
        const Rect.fromLTWH(50.5, 46, 5.5, 7),
        const Rect.fromLTWH(44, 54.5, 5.5, 7.5),
        const Rect.fromLTWH(50.5, 54.5, 5.5, 7.5),
        const Rect.fromLTWH(44.5, 63.5, 5, 8),
        const Rect.fromLTWH(50.5, 63.5, 5, 8),
      ];
      for (final r in absSegments) {
        absPath.addRRect(RRect.fromRectAndRadius(r, const Radius.circular(1.5)));
      }
      if (isAbs) canvas.drawPath(absPath, getMuscleGlowPaint());
      canvas.drawPath(absPath, getMusclePaint(isAbs));

      // Obliques / Torso sides
      final leftOblique = Path()
        ..moveTo(43, 45)
        ..lineTo(39, 46)
        ..lineTo(41, 68)
        ..lineTo(44, 68)
        ..close();
      final rightOblique = Path()
        ..moveTo(57, 45)
        ..lineTo(61, 46)
        ..lineTo(59, 68)
        ..lineTo(56, 68)
        ..close();
      canvas.drawPath(leftOblique, getMusclePaint(isAbs));
      canvas.drawPath(rightOblique, getMusclePaint(isAbs));
    } else {
      // POSTERIOR: Trapezius
      final traps = Path()
        ..moveTo(50, 22)
        ..lineTo(58, 28)
        ..lineTo(50, 48)
        ..lineTo(42, 28)
        ..close();
      if (isTraps || isBack) canvas.drawPath(traps, getMuscleGlowPaint());
      canvas.drawPath(traps, getMusclePaint(isTraps || isBack));

      // Latissimus Dorsi (Lats)
      final leftLat = Path()
        ..moveTo(42, 34)
        ..cubicTo(37, 40, 36, 56, 42, 66)
        ..lineTo(47, 65)
        ..lineTo(47, 46)
        ..close();
      final rightLat = Path()
        ..moveTo(58, 34)
        ..cubicTo(63, 40, 64, 56, 58, 66)
        ..lineTo(53, 65)
        ..lineTo(53, 46)
        ..close();
      if (isBack) {
        canvas.drawPath(leftLat, getMuscleGlowPaint());
        canvas.drawPath(rightLat, getMuscleGlowPaint());
      }
      canvas.drawPath(leftLat, getMusclePaint(isBack));
      canvas.drawPath(rightLat, getMusclePaint(isBack));
    }

    // 4. ARMS: BICEPS / TRICEPS & FOREARMS
    final leftUpperArm = Path()
      ..moveTo(35, 45)
      ..cubicTo(31, 48, 28, 56, 29, 64)
      ..lineTo(35, 63)
      ..cubicTo(36, 55, 37, 48, 35, 45)
      ..close();

    final rightUpperArm = Path()
      ..moveTo(65, 45)
      ..cubicTo(69, 48, 72, 56, 71, 64)
      ..lineTo(65, 63)
      ..cubicTo(64, 55, 63, 48, 65, 45)
      ..close();

    final isArmTarget = (!isBackView && isBiceps) || (isBackView && isTriceps);
    if (isArmTarget) {
      canvas.drawPath(leftUpperArm, getMuscleGlowPaint());
      canvas.drawPath(rightUpperArm, getMuscleGlowPaint());
    }
    canvas.drawPath(leftUpperArm, getMusclePaint(isArmTarget));
    canvas.drawPath(rightUpperArm, getMusclePaint(isArmTarget));

    // Forearms
    final leftForearm = Path()
      ..moveTo(29, 65)
      ..lineTo(24, 83)
      ..lineTo(29, 83)
      ..lineTo(35, 65)
      ..close();
    final rightForearm = Path()
      ..moveTo(71, 65)
      ..lineTo(76, 83)
      ..lineTo(71, 83)
      ..lineTo(65, 65)
      ..close();
    canvas.drawPath(leftForearm, neutralBasePaint);
    canvas.drawPath(rightForearm, neutralBasePaint);

    // 5. PELVIS / HIPS / GLUTES
    if (!isBackView) {
      // Pelvis / Groin
      final pelvis = Path()
        ..moveTo(41, 69)
        ..lineTo(59, 69)
        ..lineTo(56, 82)
        ..lineTo(44, 82)
        ..close();
      canvas.drawPath(pelvis, neutralBasePaint);
    } else {
      // Gluteus Maximus (Glutes)
      final leftGlute = Path()
        ..moveTo(49, 68)
        ..lineTo(39, 68)
        ..cubicTo(36, 76, 38, 86, 48, 87)
        ..lineTo(49, 87)
        ..close();
      final rightGlute = Path()
        ..moveTo(51, 68)
        ..lineTo(61, 68)
        ..cubicTo(64, 76, 62, 86, 52, 87)
        ..lineTo(51, 87)
        ..close();

      if (isGlutes) {
        canvas.drawPath(leftGlute, getMuscleGlowPaint());
        canvas.drawPath(rightGlute, getMuscleGlowPaint());
      }
      canvas.drawPath(leftGlute, getMusclePaint(isGlutes));
      canvas.drawPath(rightGlute, getMusclePaint(isGlutes));
    }

    // 6. THIGHS: QUADS (Front) vs HAMSTRINGS (Back)
    final leftThigh = Path()
      ..moveTo(43, 83)
      ..cubicTo(36, 86, 34, 104, 38, 116)
      ..lineTo(45, 116)
      ..cubicTo(47, 104, 48, 92, 48, 83)
      ..close();

    final rightThigh = Path()
      ..moveTo(57, 83)
      ..cubicTo(64, 86, 66, 104, 62, 116)
      ..lineTo(55, 116)
      ..cubicTo(53, 104, 52, 92, 52, 83)
      ..close();

    final isThighTarget = (!isBackView && isQuads) || (isBackView && isHamstrings);
    if (isThighTarget) {
      canvas.drawPath(leftThigh, getMuscleGlowPaint());
      canvas.drawPath(rightThigh, getMuscleGlowPaint());
    }
    canvas.drawPath(leftThigh, getMusclePaint(isThighTarget));
    canvas.drawPath(rightThigh, getMusclePaint(isThighTarget));

    // Knees
    canvas.drawCircle(const Offset(41.5, 118), 3, neutralBasePaint);
    canvas.drawCircle(const Offset(58.5, 118), 3, neutralBasePaint);

    // 7. CALVES & LOWER LEGS
    final leftCalf = Path()
      ..moveTo(39, 120)
      ..cubicTo(35, 126, 36, 138, 40, 149)
      ..lineTo(44, 149)
      ..cubicTo(45, 138, 44, 126, 44, 120)
      ..close();

    final rightCalf = Path()
      ..moveTo(61, 120)
      ..cubicTo(65, 126, 64, 138, 60, 149)
      ..lineTo(56, 149)
      ..cubicTo(55, 138, 56, 126, 56, 120)
      ..close();

    if (isCalves) {
      canvas.drawPath(leftCalf, getMuscleGlowPaint());
      canvas.drawPath(rightCalf, getMuscleGlowPaint());
    }
    canvas.drawPath(leftCalf, getMusclePaint(isCalves));
    canvas.drawPath(rightCalf, getMusclePaint(isCalves));

    // Feet
    final leftFoot = Path()
      ..moveTo(39, 150)
      ..lineTo(35, 156)
      ..lineTo(43, 156)
      ..close();
    final rightFoot = Path()
      ..moveTo(61, 150)
      ..lineTo(65, 156)
      ..lineTo(57, 156)
      ..close();
    canvas.drawPath(leftFoot, neutralBasePaint);
    canvas.drawPath(rightFoot, neutralBasePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HumanAnatomyPainter oldDelegate) {
    return oldDelegate.muscle != muscle ||
        oldDelegate.isBackView != isBackView ||
        oldDelegate.highlightColor != highlightColor;
  }
}

class _AnatomyGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 12) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 12) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
