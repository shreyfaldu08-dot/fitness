import 'package:flutter/material.dart';
import 'fitora_muscle_badge.dart';

enum MuscleViewType { front, back, both }

/// Clean Minimalist Muscle Pill / Badge Component.
/// Replaces oversized geometric body silhouettes with sleek, high-contrast,
/// Apple Health-inspired muscle badges.
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

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: highlightColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              FitoraMuscleBadge.getMuscleIcon(muscle),
              color: highlightColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isBack ? 'POSTERIOR' : 'ANTERIOR',
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Clean Minimalist Targeted Anatomy & Biomechanics Card.
/// Displays primary agonist, synergist muscles, equipment, and form mechanics
/// in clean, elegant tags and chips without heavy, dark full-body diagrams.
class FitoraAnatomyCard extends StatelessWidget {
  final String primaryMuscle;
  final List<String> secondaryMuscles;
  final String exerciseName;
  final String equipment;
  final String demoImageUrl;

  const FitoraAnatomyCard({
    super.key,
    required this.primaryMuscle,
    this.secondaryMuscles = const [],
    this.exerciseName = '',
    this.equipment = 'Barbell',
    this.demoImageUrl = '',
  });

  @override
  Widget build(BuildContext context) {
    final highlightColor = FitoraMuscleBadge.getMuscleColor(primaryMuscle);
    final isBack = FitoraMuscleIllustration.isBackMuscle(primaryMuscle);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
          // HEADER ROW: Title + Kinetic Chain Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: highlightColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.track_changes_rounded, size: 16, color: highlightColor),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Target Anatomy & Activation',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isBack ? 'POSTERIOR CHAIN' : 'ANTERIOR CHAIN',
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // PRIMARY AGONIST (Target Muscle)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: highlightColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: highlightColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: highlightColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    FitoraMuscleBadge.getMuscleIcon(primaryMuscle),
                    color: highlightColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PRIMARY TARGET (AGONIST)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        primaryMuscle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: highlightColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: highlightColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '100% Load',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: highlightColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // SECONDARY / SYNERGIST MUSCLE CHIPS
          if (secondaryMuscles.isNotEmpty) ...[
            const Text(
              'Synergists & Stabilizers',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: secondaryMuscles.map((muscle) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF94A3B8),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        muscle,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
          ],

          // BIOMECHANICAL DETAILS GRID (Equipment, Kinetic Stance, Plane)
          Row(
            children: [
              Expanded(
                child: _buildDetailPill(
                  label: 'Equipment',
                  value: equipment.toUpperCase(),
                  icon: Icons.fitness_center_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDetailPill(
                  label: 'Movement Type',
                  value: secondaryMuscles.isEmpty ? 'ISOLATION' : 'COMPOUND',
                  icon: Icons.hub_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailPill({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8)),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
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
