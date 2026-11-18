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
    switch (muscle.toLowerCase()) {
      case 'chest':
        return const Color(0xFFEF4444); // Red
      case 'back':
      case 'lats':
        return const Color(0xFF2563EB); // Royal Blue
      case 'shoulders':
      case 'deltoids':
        return const Color(0xFFF97316); // Orange
      case 'legs':
      case 'quadriceps':
      case 'hamstrings':
      case 'glutes':
      case 'calves':
        return const Color(0xFF10B981); // Emerald
      case 'biceps':
      case 'triceps':
      case 'arms':
        return const Color(0xFF8B5CF6); // Purple
      case 'abs':
      case 'core':
        return const Color(0xFFEAB308); // Gold/Amber
      case 'cardio':
        return const Color(0xFFEC4899); // Pink
      default:
        return const Color(0xFF64748B); // Slate
    }
  }

  static IconData getMuscleIcon(String muscle) {
    switch (muscle.toLowerCase()) {
      case 'chest':
        return Icons.shield_outlined;
      case 'back':
      case 'lats':
        return Icons.view_sidebar_rounded;
      case 'shoulders':
      case 'deltoids':
        return Icons.fitness_center_rounded;
      case 'legs':
      case 'quadriceps':
      case 'hamstrings':
        return Icons.directions_walk_rounded;
      case 'biceps':
      case 'triceps':
      case 'arms':
        return Icons.sports_gymnastics_rounded;
      case 'abs':
      case 'core':
        return Icons.bolt_rounded;
      case 'cardio':
        return Icons.favorite_rounded;
      default:
        return Icons.accessibility_new_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getMuscleColor(muscle);
    final icon = getMuscleIcon(muscle);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSecondary ? 6 : 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isSecondary ? 0.08 : 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: isSecondary ? 0.2 : 0.4),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSecondary ? 11 : 13, color: color),
          const SizedBox(width: 4),
          Text(
            muscle,
            style: AppTypography.labelSmall.copyWith(
              fontSize: isSecondary ? 10 : 11,
              fontWeight: isSecondary ? FontWeight.normal : FontWeight.bold,
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(3, (i) {
            final filled = i < _level;
            return Container(
              margin: const EdgeInsets.only(right: 2),
              width: 5,
              height: 10,
              decoration: BoxDecoration(
                color: filled ? _color : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
        const SizedBox(width: 4),
        Text(
          difficulty.toUpperCase(),
          style: AppTypography.labelSmall.copyWith(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: _color,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
