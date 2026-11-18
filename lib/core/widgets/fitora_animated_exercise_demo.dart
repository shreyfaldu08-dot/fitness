import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../../data/models/exercise.dart';
import 'fitora_muscle_badge.dart';

/// Clean minimalist Apple Health / Whoop-inspired card featuring a smooth,
/// 60fps animated biomechanical motion demonstration of the exercise.
class FitoraAnimatedExerciseDemo extends StatefulWidget {
  final Exercise exercise;
  final double height;
  final bool showControls;
  final bool isCompact;

  const FitoraAnimatedExerciseDemo({
    super.key,
    required this.exercise,
    this.height = 240,
    this.showControls = true,
    this.isCompact = false,
  });

  @override
  State<FitoraAnimatedExerciseDemo> createState() => _FitoraAnimatedExerciseDemoState();
}

class _FitoraAnimatedExerciseDemoState extends State<FitoraAnimatedExerciseDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPlaying = true;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.stop();
        _isPlaying = false;
      } else {
        _controller.repeat();
        _isPlaying = true;
      }
    });
  }

  void _toggleSpeed() {
    setState(() {
      _playbackSpeed = _playbackSpeed == 1.0 ? 0.5 : 1.0;
      final newDuration = Duration(
        milliseconds: (2800 / _playbackSpeed).round(),
      );
      _controller.duration = newDuration;
      if (_isPlaying) {
        _controller.repeat();
      }
    });
  }

  String _getMovementPhase(double progress) {
    if (progress < 0.45) {
      return 'ECCENTRIC (Controlled Lowering)';
    } else if (progress < 0.55) {
      return 'APEX (Stretch Turnaround)';
    } else if (progress < 0.85) {
      return 'CONCENTRIC (Power Drive)';
    } else {
      return 'LOCKOUT & RESET';
    }
  }

  Color _getPhaseColor(double progress, Color baseColor) {
    if (progress < 0.45) {
      return const Color(0xFF38BDF8); // Electric Sky Blue
    } else if (progress < 0.55) {
      return const Color(0xFFF59E0B); // Amber Peak
    } else if (progress < 0.85) {
      return baseColor; // Primary highlight
    } else {
      return const Color(0xFF10B981); // Emerald Lockout
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryMuscle = widget.exercise.targetMuscle;
    final highlightColor = FitoraMuscleBadge.getMuscleColor(primaryMuscle);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.roundedLg,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ANIMATED CANVAS DISPLAY
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
            child: Container(
              height: widget.height,
              width: double.infinity,
              color: const Color(0xFF090D16), // Deep athletic midnight canvas
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Subtle Technical Motion Grid
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.08,
                      child: CustomPaint(painter: _DemoGridPainter()),
                    ),
                  ),

                  // Biomechanical Motion Animation Painter
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size(double.infinity, widget.height),
                        painter: _BiomechanicalFigurePainter(
                          progress: _controller.value,
                          exercise: widget.exercise,
                          highlightColor: highlightColor,
                        ),
                      );
                    },
                  ),

                  // TOP OVERLAY: Phase Status Pill & Badges
                  Positioned(
                    top: 12,
                    left: 14,
                    right: 14,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, _) {
                              final progress = _controller.value;
                              final phase = _getMovementPhase(progress);
                              final color = _getPhaseColor(progress, highlightColor);
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: color.withValues(alpha: 0.5)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        phase,
                                        style: TextStyle(
                                          color: color,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.4,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.exercise.equipment.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // BOTTOM OVERLAY: Player Controls (Play/Pause, Speed)
                  if (widget.showControls)
                    Positioned(
                      bottom: 10,
                      right: 12,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _toggleSpeed,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                '${_playbackSpeed}x SPEED',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _togglePlayPause,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Icon(
                                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // BOTTOM CARD INFO (Apple Health / Whoop Clean Minimalist Typography)
          if (!widget.isCompact)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.exercise.name,
                    style: AppTypography.headingSmall.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      FitoraMuscleBadge(muscle: primaryMuscle),
                      if (widget.exercise.secondaryMuscles.isNotEmpty)
                        FitoraMuscleBadge(
                          muscle: widget.exercise.secondaryMuscles.first,
                          isSecondary: true,
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${widget.exercise.defaultSets} sets × ${widget.exercise.defaultReps} reps',
                          style: AppTypography.labelSmall.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.exercise.instructions,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                      fontSize: 12.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DemoGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.6;

    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 60fps Biomechanical Figure Painter that computes joint angles & barbell trajectory
class _BiomechanicalFigurePainter extends CustomPainter {
  final double progress;
  final Exercise exercise;
  final Color highlightColor;

  _BiomechanicalFigurePainter({
    required this.progress,
    required this.exercise,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Movement Cycle Curve: Smooth sin wave (0 -> 1 -> 0)
    // 0 = top lockout, 1 = bottom apex
    final t = (1 - math.cos(progress * 2 * math.pi)) / 2;

    final lowerName = exercise.name.toLowerCase();
    final lowerMuscle = exercise.targetMuscle.toLowerCase();

    if (lowerName.contains('squat') || lowerMuscle.contains('quad') || lowerMuscle.contains('leg')) {
      _drawSquatMotion(canvas, size, cx, cy, t);
    } else if (lowerName.contains('deadlift') || lowerMuscle.contains('hamstring')) {
      _drawDeadliftMotion(canvas, size, cx, cy, t);
    } else if (lowerName.contains('press') || lowerName.contains('pushup') || lowerMuscle.contains('chest')) {
      _drawBenchPushMotion(canvas, size, cx, cy, t);
    } else if (lowerName.contains('pull') || lowerName.contains('row') || lowerMuscle.contains('lat') || lowerMuscle.contains('back')) {
      _drawPullingMotion(canvas, size, cx, cy, t);
    } else if (lowerMuscle.contains('shoulder') || lowerMuscle.contains('delt')) {
      _drawOverheadLateralMotion(canvas, size, cx, cy, t);
    } else if (lowerMuscle.contains('bicep') || lowerMuscle.contains('tricep')) {
      _drawArmMotion(canvas, size, cx, cy, t);
    } else {
      _drawGeneralCompoundMotion(canvas, size, cx, cy, t);
    }
  }

  // 1. SQUAT KINEMATICS
  void _drawSquatMotion(Canvas canvas, Size size, double cx, double cy, double t) {
    final bodyPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final musclePulse = Paint()
      ..color = highlightColor.withValues(alpha: 0.7 + 0.3 * t)
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = highlightColor.withValues(alpha: 0.35 * t)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final barPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 3.5;

    // Floor Baseline
    final floorY = cy + 65.0;
    canvas.drawLine(Offset(cx - 60, floorY), Offset(cx + 60, floorY), Paint()..color = Colors.white24..strokeWidth = 1.5);

    // Kinematics: Hip descends by up to 34px, knees bend forward and out
    final hipY = cy - 5 + (t * 34.0);
    final kneeY = cy + 30 + (t * 12.0);
    final kneeX = cx + 22 + (t * 8.0);
    final footX = cx + 18;
    final footY = floorY;

    final shoulderY = hipY - 42.0;
    final headY = shoulderY - 14.0;

    // Glow on Quads & Glutes
    canvas.drawLine(Offset(cx, hipY), Offset(kneeX, kneeY), glowPaint);

    // Spine & Torso (Slight 15 deg forward inclination on descent)
    canvas.drawLine(Offset(cx - (t * 8), hipY), Offset(cx - (t * 4), shoulderY), bodyPaint);

    // Head
    canvas.drawCircle(Offset(cx - (t * 4), headY), 9, Paint()..color = const Color(0xFF94A3B8));

    // Thigh (Quads - Active Agonist)
    canvas.drawLine(Offset(cx - (t * 8), hipY), Offset(kneeX, kneeY), musclePulse);

    // Shin & Calves
    canvas.drawLine(Offset(kneeX, kneeY), Offset(footX, footY), bodyPaint);

    // Foot
    canvas.drawLine(Offset(footX - 4, footY), Offset(footX + 12, footY), bodyPaint);

    // Barbell resting across rear shoulders
    final barY = shoulderY + 2;
    canvas.drawLine(Offset(cx - 45, barY), Offset(cx + 45, barY), barPaint);
    // Plates on bar
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx - 36, barY), width: 6, height: 26), const Radius.circular(2)), Paint()..color = const Color(0xFF94A3B8));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx + 36, barY), width: 6, height: 26), const Radius.circular(2)), Paint()..color = const Color(0xFF94A3B8));

    // Arm grasping the bar
    canvas.drawLine(Offset(cx - 4, shoulderY), Offset(cx + 12, shoulderY + 8), bodyPaint..strokeWidth = 3.5);
    canvas.drawLine(Offset(cx + 12, shoulderY + 8), Offset(cx + 25, barY), bodyPaint..strokeWidth = 3.5);
  }

  // 2. BENCH PRESS & PUSH MOTION
  void _drawBenchPushMotion(Canvas canvas, Size size, double cx, double cy, double t) {
    final bodyPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final chestGlow = Paint()
      ..color = highlightColor.withValues(alpha: 0.7 + 0.3 * (1 - t))
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final barPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 3.5;

    // Bench Flat Surface
    final benchY = cy + 20.0;
    canvas.drawLine(Offset(cx - 55, benchY), Offset(cx + 55, benchY), Paint()..color = const Color(0xFF334155)..strokeWidth = 5);
    canvas.drawLine(Offset(cx - 40, benchY), Offset(cx - 40, benchY + 35), Paint()..color = const Color(0xFF1E293B)..strokeWidth = 4);
    canvas.drawLine(Offset(cx + 40, benchY), Offset(cx + 40, benchY + 35), Paint()..color = const Color(0xFF1E293B)..strokeWidth = 4);

    // Torso lying flat
    final headX = cx - 35.0;
    final chestX = cx - 5.0;
    final hipX = cx + 25.0;
    final torsoY = benchY - 8.0;

    // Head on bench
    canvas.drawCircle(Offset(headX, torsoY), 8, Paint()..color = const Color(0xFF94A3B8));

    // Body on bench
    canvas.drawLine(Offset(headX + 8, torsoY), Offset(hipX, torsoY), bodyPaint);

    // Legs bent over bench to floor
    canvas.drawLine(Offset(hipX, torsoY), Offset(hipX + 15, benchY + 12), bodyPaint);
    canvas.drawLine(Offset(hipX + 15, benchY + 12), Offset(hipX + 15, benchY + 35), bodyPaint);

    // Chest Active Muscle
    canvas.drawLine(Offset(headX + 12, torsoY - 2), Offset(chestX + 6, torsoY - 2), chestGlow);

    // Barbell vertical movement: t=0 (lockout at top) to t=1 (touching chest)
    final barY = torsoY - 45.0 + (t * 36.0);
    canvas.drawLine(Offset(chestX - 35, barY), Offset(chestX + 35, barY), barPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(chestX - 28, barY), width: 6, height: 24), const Radius.circular(2)), Paint()..color = const Color(0xFF94A3B8));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(chestX + 28, barY), width: 6, height: 24), const Radius.circular(2)), Paint()..color = const Color(0xFF94A3B8));

    // Arms pressing
    final elbowY = torsoY - 10 + (t * 12);
    final elbowX = chestX - 14 + (t * 6);
    canvas.drawLine(Offset(chestX, torsoY - 2), Offset(elbowX, elbowY), bodyPaint);
    canvas.drawLine(Offset(elbowX, elbowY), Offset(chestX, barY), bodyPaint);
  }

  // 3. DEADLIFT & HIP HINGE
  void _drawDeadliftMotion(Canvas canvas, Size size, double cx, double cy, double t) {
    final bodyPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final posteriorGlow = Paint()
      ..color = highlightColor.withValues(alpha: 0.7 + 0.3 * t)
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final barPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 3.5;

    final floorY = cy + 65.0;
    canvas.drawLine(Offset(cx - 50, floorY), Offset(cx + 50, floorY), Paint()..color = Colors.white24..strokeWidth = 1.5);

    // Hinge parameters
    final hipX = cx - 10 - (t * 18);
    final hipY = cy - 2 + (t * 16);
    final shoulderX = cx + 8 - (t * 10);
    final shoulderY = cy - 42 + (t * 32);

    // Posterior Chain glow (Hamstring & Glute)
    canvas.drawLine(Offset(hipX, hipY), Offset(cx + 6, cy + 32 + (t * 8)), posteriorGlow);

    // Torso Spine
    canvas.drawLine(Offset(hipX, hipY), Offset(shoulderX, shoulderY), bodyPaint);

    // Head
    canvas.drawCircle(Offset(shoulderX + 6, shoulderY - 10), 8.5, Paint()..color = const Color(0xFF94A3B8));

    // Shin & Foot
    final footX = cx + 8;
    canvas.drawLine(Offset(cx + 6, cy + 32 + (t * 8)), Offset(footX, floorY), bodyPaint);
    canvas.drawLine(Offset(footX - 4, floorY), Offset(footX + 14, floorY), bodyPaint);

    // Barbell vertical path
    final barY = cy + 8 + (t * 45);
    final barX = footX + 2;
    canvas.drawLine(Offset(barX - 35, barY), Offset(barX + 35, barY), barPaint);
    canvas.drawCircle(Offset(barX - 25, barY), 13, Paint()..color = const Color(0xFF94A3B8));
    canvas.drawCircle(Offset(barX + 25, barY), 13, Paint()..color = const Color(0xFF94A3B8));

    // Arms hanging straight to barbell
    canvas.drawLine(Offset(shoulderX, shoulderY), Offset(barX, barY), bodyPaint..strokeWidth = 3.5);
  }

  // 4. PULLING & LAT DRIVE
  void _drawPullingMotion(Canvas canvas, Size size, double cx, double cy, double t) {
    final bodyPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final latGlow = Paint()
      ..color = highlightColor.withValues(alpha: 0.7 + 0.3 * (1 - t))
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Seated athlete
    final seatY = cy + 30.0;
    canvas.drawLine(Offset(cx - 30, seatY), Offset(cx + 20, seatY), Paint()..color = const Color(0xFF334155)..strokeWidth = 4);

    final hipY = seatY - 5;
    final shoulderY = cy - 25.0;

    // Lats Active Glow on back
    canvas.drawLine(Offset(cx - 8, shoulderY + 6), Offset(cx - 10, hipY), latGlow);

    // Torso & Head
    canvas.drawLine(Offset(cx - 6, hipY), Offset(cx - 4, shoulderY), bodyPaint);
    canvas.drawCircle(Offset(cx - 4, shoulderY - 14), 8.5, Paint()..color = const Color(0xFF94A3B8));

    // Legs on floor
    canvas.drawLine(Offset(cx - 6, hipY), Offset(cx + 15, seatY), bodyPaint);
    canvas.drawLine(Offset(cx + 15, seatY), Offset(cx + 15, seatY + 30), bodyPaint);

    // Pulldown Bar movement: t=0 (arms extended up) to t=1 (bar pulled to clavicle)
    final barY = cy - 65 + (t * 42.0);
    final barPaint = Paint()..color = const Color(0xFFCBD5E1)..strokeWidth = 3.5;
    canvas.drawLine(Offset(cx - 50, barY), Offset(cx + 50, barY), barPaint);

    // Cable to top pulley
    canvas.drawLine(Offset(cx, barY), Offset(cx, cy - 85), Paint()..color = Colors.white30..strokeWidth = 1.5);

    // Arms drawing down
    final elbowX = cx - 18 + (t * 6);
    final elbowY = shoulderY - 20 + (t * 30);
    canvas.drawLine(Offset(cx - 4, shoulderY), Offset(elbowX, elbowY), bodyPaint);
    canvas.drawLine(Offset(elbowX, elbowY), Offset(cx - 28, barY), bodyPaint);
    canvas.drawLine(Offset(cx - 4, shoulderY), Offset(elbowX + 26, elbowY), bodyPaint);
    canvas.drawLine(Offset(elbowX + 26, elbowY), Offset(cx + 28, barY), bodyPaint);
  }

  // 5. OVERHEAD & LATERAL RAISE
  void _drawOverheadLateralMotion(Canvas canvas, Size size, double cx, double cy, double t) {
    final bodyPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final deltGlow = Paint()
      ..color = highlightColor.withValues(alpha: 0.7 + 0.3 * (1 - t))
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Standing athlete
    final headY = cy - 45.0;
    final shoulderY = cy - 30.0;
    final hipY = cy + 10.0;
    final floorY = cy + 65.0;

    canvas.drawCircle(Offset(cx, headY), 9, Paint()..color = const Color(0xFF94A3B8));
    canvas.drawLine(Offset(cx, shoulderY), Offset(cx, hipY), bodyPaint);

    // Legs
    canvas.drawLine(Offset(cx, hipY), Offset(cx - 14, floorY), bodyPaint);
    canvas.drawLine(Offset(cx, hipY), Offset(cx + 14, floorY), bodyPaint);

    // Deltoids caps
    canvas.drawCircle(Offset(cx - 15, shoulderY + 2), 5, deltGlow);
    canvas.drawCircle(Offset(cx + 15, shoulderY + 2), 5, deltGlow);

    // Arms raise out to side: t=0 (at side) to t=1 (90 degrees lateral abduction)
    final angle = 0.2 + (t * 1.35); // Radians
    final armLen = 35.0;
    final leftHandX = cx - 14 - (math.sin(angle) * armLen);
    final leftHandY = shoulderY + (math.cos(angle) * armLen);
    final rightHandX = cx + 14 + (math.sin(angle) * armLen);
    final rightHandY = shoulderY + (math.cos(angle) * armLen);

    canvas.drawLine(Offset(cx - 14, shoulderY), Offset(leftHandX, leftHandY), bodyPaint);
    canvas.drawLine(Offset(cx + 14, shoulderY), Offset(rightHandX, rightHandY), bodyPaint);

    // Dumbbells in hands
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(leftHandX, leftHandY), width: 6, height: 16), const Radius.circular(2)), Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(rightHandX, rightHandY), width: 6, height: 16), const Radius.circular(2)), Paint()..color = const Color(0xFFCBD5E1));
  }

  // 6. ARMS (BICEPS / TRICEPS)
  void _drawArmMotion(Canvas canvas, Size size, double cx, double cy, double t) {
    final bodyPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final armGlow = Paint()
      ..color = highlightColor.withValues(alpha: 0.7 + 0.3 * (1 - t))
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final headY = cy - 45.0;
    final shoulderY = cy - 30.0;
    final hipY = cy + 12.0;
    final floorY = cy + 65.0;

    canvas.drawCircle(Offset(cx - 10, headY), 9, Paint()..color = const Color(0xFF94A3B8));
    canvas.drawLine(Offset(cx - 10, shoulderY), Offset(cx - 10, hipY), bodyPaint);
    canvas.drawLine(Offset(cx - 10, hipY), Offset(cx - 18, floorY), bodyPaint);
    canvas.drawLine(Offset(cx - 10, hipY), Offset(cx - 2, floorY), bodyPaint);

    // Upper Arm pinned at side
    final elbowX = cx - 6.0;
    final elbowY = cy - 2.0;
    canvas.drawLine(Offset(cx - 10, shoulderY), Offset(elbowX, elbowY), armGlow);

    // Forearm curls up: t=0 (bottom) to t=1 (curled to shoulder)
    final curlAngle = 0.2 + (t * 2.3);
    final handX = elbowX + (math.sin(curlAngle) * 32.0);
    final handY = elbowY - (math.cos(curlAngle) * 32.0);

    canvas.drawLine(Offset(elbowX, elbowY), Offset(handX, handY), bodyPaint);
    canvas.drawCircle(Offset(handX, handY), 7, Paint()..color = const Color(0xFFCBD5E1));
  }

  // 7. GENERAL COMPOUND
  void _drawGeneralCompoundMotion(Canvas canvas, Size size, double cx, double cy, double t) {
    _drawSquatMotion(canvas, size, cx, cy, t);
  }

  @override
  bool shouldRepaint(covariant _BiomechanicalFigurePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.exercise.id != exercise.id;
  }
}
