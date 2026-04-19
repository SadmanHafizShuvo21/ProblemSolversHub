import 'package:flutter/material.dart';

class DifficultyBadge extends StatelessWidget {
  final String label;

  const DifficultyBadge({super.key, required this.label});

  Color get _backgroundColor {
    switch (label.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF22C55E).withOpacity(0.16);
      case 'intermediate':
        return const Color(0xFF3B82F6).withOpacity(0.16);
      case 'advanced':
        return const Color(0xFFF97316).withOpacity(0.16);
      case 'expert':
        return const Color(0xFFEF4444).withOpacity(0.16);
      default:
        return Colors.grey.shade200;
    }
  }

  Color get _textColor {
    switch (label.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF22C55E);
      case 'intermediate':
        return const Color(0xFF3B82F6);
      case 'advanced':
        return const Color(0xFFF97316);
      case 'expert':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
