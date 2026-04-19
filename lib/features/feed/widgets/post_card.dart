import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        context.go('/post', extra: post);
      },
      child: Card(
        margin: theme.cardTheme.margin,
        elevation: theme.cardTheme.elevation,
        shape: theme.cardTheme.shape,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(post.userAvatar),
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    post.userName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Problem title
              Text(
                post.problemTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              // Platform and difficulty
              Row(
                children: [
                  Chip(
                    label: Text(post.platform),
                    backgroundColor: theme.colorScheme.primaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(post.difficulty),
                    backgroundColor: _getDifficultyColor(
                      post.difficulty,
                      theme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Tags
              Wrap(
                spacing: 6,
                children: post.tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag),
                        backgroundColor: theme.chipTheme.backgroundColor,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              // Approach preview
              Text(
                post.approachPreview,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Engagement row
              Row(
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text('${post.likes}', style: theme.textTheme.bodySmall),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.comment_outlined,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text('${post.comments}', style: theme.textTheme.bodySmall),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.visibility_outlined,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text('${post.views}', style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty, ThemeData theme) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green.shade100;
      case 'medium':
        return Colors.orange.shade100;
      case 'hard':
        return Colors.red.shade100;
      default:
        return theme.chipTheme.backgroundColor ?? Colors.grey.shade100;
    }
  }
}
