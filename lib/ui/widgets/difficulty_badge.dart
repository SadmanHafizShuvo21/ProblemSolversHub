import 'package:flutter/material.dart';

class DifficultyBadge extends StatelessWidget {
  final String label;

  const DifficultyBadge({super.key, required this.label});

  Color _baseColor(BuildContext context) {
    final t = Theme.of(context);
    switch (label.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.blue;
      case 'advanced':
        return Colors.orange;
      case 'expert':
        return Colors.red;
      default:
        return t.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = _baseColor(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: base.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: base.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: base.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: base,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
