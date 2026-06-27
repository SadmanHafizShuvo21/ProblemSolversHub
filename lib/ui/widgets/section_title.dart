import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String label;

  const SectionTitle({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 220),
        style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: theme.colorScheme.onBackground,
            ) ?? const TextStyle(fontSize: 16),
        child: Text(label),
      ),
    );
  }
}
