import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../../data/models/exercise.dart';
import 'fitora_muscle_badge.dart';

/// Clean minimalist Apple Health-inspired exercise demonstration component.
/// Displays realistic 3D rendered animated exercise motion downloaded from verified
/// fitness datasets, complete with playback controls, movement phases, and coaching tips.
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
  late AnimationController _phaseController;
  bool _isPlaying = true;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _phaseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _phaseController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _phaseController.repeat();
      } else {
        _phaseController.stop();
      }
    });
  }

  void _toggleSpeed() {
    setState(() {
      _playbackSpeed = _playbackSpeed == 1.0 ? 0.5 : 1.0;
      final newDuration = Duration(milliseconds: (3000 / _playbackSpeed).round());
      _phaseController.duration = newDuration;
      if (_isPlaying) {
        _phaseController.repeat();
      }
    });
  }

  String _getMovementPhase(double progress) {
    if (progress < 0.40) {
      return 'ECCENTRIC (Lower with control)';
    } else if (progress < 0.55) {
      return 'APEX (Stretch turnaround)';
    } else if (progress < 0.85) {
      return 'CONCENTRIC (Drive up with power)';
    } else {
      return 'LOCKOUT & RESET';
    }
  }

  Color _getPhaseColor(double progress, Color baseColor) {
    if (progress < 0.40) {
      return const Color(0xFF0284C7); // Sky Blue
    } else if (progress < 0.55) {
      return const Color(0xFFF59E0B); // Amber
    } else if (progress < 0.85) {
      return baseColor;
    } else {
      return const Color(0xFF10B981); // Emerald
    }
  }

  Widget _buildMediaView() {
    final assetPath = widget.exercise.localAssetGif;
    final networkGif = widget.exercise.gifUrl;
    final fallbackImage = widget.exercise.imageUrl;

    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        // 1. Try Local Downloaded 3D Rendered GIF Asset
        Image.asset(
          assetPath,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) {
            // 2. Fallback to jsDelivr CDN Network GIF
            if (networkGif.isNotEmpty) {
              return Image.network(
                networkGif,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                          : null,
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  // 3. Fallback to static Photo
                  return _buildStaticPhotoFallback(fallbackImage);
                },
              );
            }
            return _buildStaticPhotoFallback(fallbackImage);
          },
        ),

        // Dimmer overlay when paused
        if (!_isPlaying)
          Container(
            color: Colors.black.withValues(alpha: 0.35),
            child: const Center(
              child: Icon(
                Icons.pause_circle_filled_rounded,
                color: Colors.white,
                size: 56,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStaticPhotoFallback(String url) {
    if (url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => const Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        ),
        errorWidget: (_, __, ___) => _buildPlaceholderIcon(),
      );
    }
    return _buildPlaceholderIcon();
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fitness_center_rounded, size: 40, color: AppColors.textMuted),
            const SizedBox(height: 8),
            Text(
              widget.exercise.name,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryMuscle = widget.exercise.targetMuscle;
    final highlightColor = FitoraMuscleBadge.getMuscleColor(primaryMuscle);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
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
          // 3D ANIMATION SCREEN CONTAINER
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Container(
              height: widget.height,
              width: double.infinity,
              color: const Color(0xFFF8FAFC), // Apple-style pristine light neutral canvas
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Real 3D Anatomical Rendered Exercise Looping Motion
                  _buildMediaView(),

                  // TOP OVERLAY: Phase Status Pill & 3D Badge
                  Positioned(
                    top: 12,
                    left: 14,
                    right: 14,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: AnimatedBuilder(
                            animation: _phaseController,
                            builder: (context, _) {
                              final progress = _phaseController.value;
                              final phase = _getMovementPhase(progress);
                              final color = _getPhaseColor(progress, highlightColor);
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: color.withValues(alpha: 0.5)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        phase,
                                        style: const TextStyle(
                                          color: Color(0xFF0F172A),
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                        ),
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
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.view_in_ar_rounded, size: 12, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                '3D FORM',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // BOTTOM OVERLAY CONTROLS (Play/Pause, Slow-Mo 0.5x)
                  if (widget.showControls)
                    Positioned(
                      bottom: 10,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: _togglePlayPause,
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Icon(
                                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: const Color(0xFF0F172A),
                                  size: 18,
                                ),
                              ),
                            ),
                            Container(width: 1, height: 14, color: const Color(0xFFE2E8F0)),
                            InkWell(
                              onTap: _toggleSpeed,
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                                child: Text(
                                  '${_playbackSpeed}x',
                                  style: TextStyle(
                                    color: _playbackSpeed == 0.5 ? AppColors.primary : const Color(0xFF0F172A),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // BOTTOM CARD CONTENT: Clean Minimalist Target & Form Info
          if (!widget.isCompact)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: highlightColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.track_changes_rounded, size: 12, color: highlightColor),
                            const SizedBox(width: 4),
                            Text(
                              primaryMuscle,
                              style: TextStyle(
                                color: highlightColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.exercise.equipment.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.exercise.instructions,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      height: 1.45,
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
