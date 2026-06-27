import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/post.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _hover = false;
  bool _pressed = false;

  void _onEnter(bool value) => setState(() => _hover = value);
  void _onPress(bool value) => setState(() => _pressed = value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final cardMargin = theme.cardTheme.margin ?? EdgeInsets.zero;

    final transform = _pressed
        ? (Matrix4.identity()..scale(0.99))
        : (_hover ? (Matrix4.identity()..translate(0, -6, 0)) : Matrix4.identity());

    return MouseRegion(
      onEnter: (_) => _onEnter(true),
      onExit: (_) => _onEnter(false),
      child: GestureDetector(
        onTapDown: (_) => _onPress(true),
        onTapCancel: () => _onPress(false),
        onTapUp: (_) {
          _onPress(false);
          context.go('/post', extra: widget.post);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          transform: transform,
          margin: cardMargin,
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.colorScheme.surface,
            borderRadius: (theme.cardTheme.shape as RoundedRectangleBorder?)?.borderRadius ?? BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_hover ? 0.10 : 0.04),
                blurRadius: _hover ? 30 : 16,
                offset: Offset(0, _hover ? 14 : 8),
              ),
            ],
            border: Border.all(color: accent.withOpacity(0.06)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.post.userAvatar),
                      radius: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.userName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.post.platform,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _difficultyBg(widget.post.difficulty, theme),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        widget.post.difficulty,
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.post.problemTitle,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.post.tags.take(5).map((tag) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.chipTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accent.withOpacity(0.04)),
                      ),
                      child: Text(tag, style: theme.textTheme.bodySmall),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                Text(
                  widget.post.approachPreview,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStat(Icons.favorite_border, widget.post.likes, theme),
                    _buildStat(Icons.comment_outlined, widget.post.comments, theme),
                    _buildStat(Icons.remove_red_eye_outlined, widget.post.views, theme),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, int count, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(count.toString(), style: theme.textTheme.bodySmall),
      ],
    );
  }

  Color _difficultyBg(String difficulty, ThemeData theme) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
      case 'beginner':
        return Colors.green.withOpacity(0.12);
      case 'medium':
      case 'intermediate':
        return Colors.blue.withOpacity(0.12);
      case 'hard':
      case 'advanced':
        return Colors.orange.withOpacity(0.12);
      case 'expert':
        return Colors.red.withOpacity(0.12);
      default:
        return theme.chipTheme.backgroundColor ?? Colors.grey.shade100;
    }
  }
}
