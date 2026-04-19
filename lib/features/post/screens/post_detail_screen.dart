import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:problem_solvers_hub/core/service_locator.dart';
import 'package:problem_solvers_hub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:problem_solvers_hub/features/posts/domain/entities/comment.dart';
import 'package:problem_solvers_hub/features/posts/domain/repositories/posts_repository.dart';
import 'package:problem_solvers_hub/shared/models/post.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _commentController = TextEditingController();
  bool _isSendingComment = false;
  bool _isLiking = false;
  bool _liked = false;
  int _pendingLikeDelta = 0;
  int _pendingCommentDelta = 0;
  late final Stream<Post?> _postStream;
  late final Stream<List<PostComment>> _commentsStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    final postId = widget.post.id;
    if (postId == null) {
      throw StateError('Post id is required to load details.');
    }

    _postStream = getIt<PostsRepository>().getPostByIdStream(postId);
    _commentsStream = getIt<PostsRepository>().getCommentsStream(postId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<Post?>(
      stream: _postStream,
      builder: (context, snapshot) {
        final post = snapshot.data ?? widget.post;
        final likes = post.likes + _pendingLikeDelta;
        final commentsCount = post.comments + _pendingCommentDelta;

        return Scaffold(
          appBar: AppBar(title: const Text('Post Detail')),
          body: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.problemTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      runSpacing: 8,
                      spacing: 8,
                      children: [
                        Chip(
                          label: Text(post.difficulty),
                          backgroundColor: _getDifficultyColor(
                            post.difficulty,
                            theme,
                          ),
                        ),
                        Chip(
                          label: Text('$likes likes'),
                          backgroundColor: theme.colorScheme.primaryContainer,
                        ),
                        Chip(
                          label: Text('$commentsCount comments'),
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Author Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(post.userAvatar),
                      radius: 20,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.userName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatTimestamp(post.timestamp),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Tabs
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Approach'),
                  Tab(text: 'Code'),
                  Tab(text: 'Discussion'),
                ],
              ),
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Approach Tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        post.approachFull,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    // Code Tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          post.codeSnippet,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                    // Discussion Tab
                    Column(
                      children: [
                        Expanded(
                          child: StreamBuilder<List<PostComment>>(
                            stream: _commentsStream,
                            builder: (context, commentsSnapshot) {
                              final comments = commentsSnapshot.data ?? [];

                              if (comments.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No comments yet. Be the first to share your insight!',
                                    style: theme.textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }

                              return ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: comments.length,
                                itemBuilder: (context, index) {
                                  return _buildCommentItem(comments[index]);
                                },
                              );
                            },
                          ),
                        ),
                        // Comment Input
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            border: Border(
                              top: BorderSide(
                                color: theme.colorScheme.outline,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _commentController,
                                  decoration: const InputDecoration(
                                    hintText: 'Add a comment...',
                                    border: OutlineInputBorder(),
                                  ),
                                  minLines: 1,
                                  maxLines: 4,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: _isSendingComment
                                    ? const CircularProgressIndicator()
                                    : const Icon(Icons.send),
                                onPressed: _isSendingComment
                                    ? null
                                    : () => _addComment(post.id!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Bottom Reaction Buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(color: theme.colorScheme.outline, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildReactionButton(
                      Icons.thumb_up,
                      'Like',
                      isActive: _liked,
                      isLoading: _isLiking,
                      onTap: () => _toggleLike(post.id!),
                    ),
                    _buildReactionButton(Icons.lightbulb_outlined, 'Helpful'),
                    _buildReactionButton(Icons.insights_outlined, 'Insightful'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleLike(String postId) async {
    if (_isLiking) return;

    final repository = getIt<PostsRepository>();
    setState(() {
      _isLiking = true;
      _pendingLikeDelta += _liked ? -1 : 1;
    });

    try {
      if (_liked) {
        await repository.unlikePost(postId);
      } else {
        await repository.likePost(postId);
      }
      setState(() {
        _liked = !_liked;
      });
    } catch (e) {
      setState(() {
        _pendingLikeDelta += _liked ? 1 : -1;
      });
      _showError('Unable to update like. Please try again.');
    } finally {
      setState(() {
        _isLiking = false;
      });
    }
  }

  Future<void> _addComment(String postId) async {
    final rawText = _commentController.text.trim();
    if (rawText.isEmpty) {
      _showError('Please enter a comment before posting.');
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      _showError('You must be signed in to comment.');
      return;
    }

    final comment = PostComment(
      postId: postId,
      userId: authState.user.id,
      userAvatar: authState.user.photoUrl ?? 'https://via.placeholder.com/40',
      userName: authState.user.displayName,
      text: rawText,
      timestamp: DateTime.now(),
    );

    setState(() {
      _isSendingComment = true;
      _pendingCommentDelta += 1;
    });

    try {
      await getIt<PostsRepository>().addComment(postId, comment);
      _commentController.clear();
    } catch (e) {
      setState(() {
        _pendingCommentDelta -= 1;
      });
      _showError('Unable to add comment. Please try again.');
    } finally {
      setState(() {
        _isSendingComment = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildCommentItem(PostComment comment) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(comment.userAvatar),
            radius: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.userName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(comment.text, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(comment.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionButton(
    IconData icon,
    String label, {
    bool isActive = false,
    bool isLoading = false,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? theme.colorScheme.primary : null),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isActive ? theme.colorScheme.primary : null,
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
