import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

class FitoraMuscleBadge extends StatelessWidget {
  final String muscle;
  final bool isSecondary;

  const FitoraMuscleBadge({
    super.key,
    required this.muscle,
    this.isSecondary = false,
  });

  static Color getMuscleColor(String muscle) {
    final lower = muscle.toLowerCase();
    if (lower.contains('chest') || lower.contains('pec') || lower.contains('bench')) {
      return const Color(0xFFFF2A4B); // Vibrant Electric Crimson
    }
    if (lower.contains('back') || lower.contains('lat') || lower.contains('pulldown') || lower.contains('rhomboid')) {
      return const Color(0xFF0070F3); // Vibrant Sapphire Blue
    }
    if (lower.contains('shoulder') || lower.contains('deltoid') || lower.contains('lateral') || lower.contains('overhead')) {
      return const Color(0xFFFF6D00); // Glowing Electric Orange / Flame
    }
    if (lower.contains('quad') || lower.contains('squat') || lower.contains('thigh') || lower.contains('lunge')) {
      return const Color(0xFF00E676); // Radiant Neon Emerald
    }
    if (lower.contains('glute') || lower.contains('hip')) {
      return const Color(0xFF10B981); // Vivid Jade
    }
    if (lower.contains('hamstring') || lower.contains('rdl')) {
      return const Color(0xFF059669); // Deep Emerald
    }
    if (lower.contains('bicep') || lower.contains('curl')) {
      return const Color(0xFFA855F7); // Electric Neon Purple
    }
    if (lower.contains('tricep') || lower.contains('pushdown') || lower.contains('skull')) {
      return const Color(0xFF8B5CF6); // Vibrant Indigo-Violet
    }
    if (lower.contains('arm')) {
      return const Color(0xFFA855F7);
    }
    if (lower.contains('ab') || lower.contains('core') || lower.contains('plank') || lower.contains('crunch')) {
      return const Color(0xFFFFB300); // Glowing Warm Amber / Gold
    }
    if (lower.contains('calf') || lower.contains('calves') || lower.contains('gastrocnemius')) {
      return const Color(0xFF06B6D4); // Electric Cyan
    }
    if (lower.contains('cardio') || lower.contains('full body') || lower.contains('burpee')) {
      return const Color(0xFFEC4899); // Electric Hot Pink
    }
    return const Color(0xFF38BDF8); // Electric Sky Blue default
  }

  static IconData getMuscleIcon(String muscle) {
    final lower = muscle.toLowerCase();
    if (lower.contains('chest') || lower.contains('pec') || lower.contains('bench')) {
      return Icons.shield_outlined;
    }
    if (lower.contains('back') || lower.contains('lat') || lower.contains('pull') || lower.contains('row')) {
      return Icons.view_sidebar_rounded;
    }
    if (lower.contains('shoulder') || lower.contains('deltoid') || lower.contains('lateral')) {
      return Icons.fitness_center_rounded;
    }
    if (lower.contains('quad') || lower.contains('squat') || lower.contains('leg')) {
      return Icons.directions_walk_rounded;
    }
    if (lower.contains('bicep') || lower.contains('curl') || lower.contains('arm') || lower.contains('tricep')) {
      return Icons.sports_gymnastics_rounded;
    }
    if (lower.contains('ab') || lower.contains('core') || lower.contains('plank')) {
      return Icons.bolt_rounded;
    }
    if (lower.contains('cardio') || lower.contains('full body')) {
      return Icons.favorite_rounded;
    }
    return Icons.accessibility_new_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final color = getMuscleColor(muscle);
    final icon = getMuscleIcon(muscle);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSecondary ? 8 : 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isSecondary ? 0.08 : 0.12),
        borderRadius: BorderRadius.circular(999), // Minimalist Capsule Pill
        border: Border.all(
          color: color.withValues(alpha: isSecondary ? 0.25 : 0.4),
          width: 0.9,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSecondary ? 11 : 12.5, color: color),
          const SizedBox(width: 4),
          Text(
            muscle,
            style: AppTypography.labelSmall.copyWith(
              fontSize: isSecondary ? 10 : 11,
              fontWeight: isSecondary ? FontWeight.w500 : FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class FitoraDifficultyIndicator extends StatelessWidget {
  final String difficulty; // beginner, intermediate, advanced

  const FitoraDifficultyIndicator({
    super.key,
    required this.difficulty,
  });

  int get _level {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 1;
      case 'intermediate':
        return 2;
      case 'advanced':
        return 3;
      default:
        return 1;
    }
  }

  Color get _color {
    switch (_level) {
      case 1:
        return const Color(0xFF10B981); // Green
      case 2:
        return const Color(0xFFF59E0B); // Amber
      case 3:
        return const Color(0xFFEF4444); // Red
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999), // Capsule Pill
        border: Border.all(color: _color.withValues(alpha: 0.3), width: 0.9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(3, (i) {
              final filled = i < _level;
              return Container(
                margin: const EdgeInsets.only(right: 2.5),
                width: 4.5,
                height: 4.5,
                decoration: BoxDecoration(
                  color: filled ? _color : const Color(0xFFCBD5E1),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
          const SizedBox(width: 4),
          Text(
            difficulty.toUpperCase(),
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: _color,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
