import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:problem_solvers_hub/core/service_locator.dart';
import 'package:problem_solvers_hub/features/posts/domain/entities/comment.dart';
import 'package:problem_solvers_hub/features/posts/domain/repositories/posts_repository.dart';
import 'package:problem_solvers_hub/ui/models/dummy_data.dart';
import 'package:problem_solvers_hub/ui/widgets/difficulty_badge.dart';

class PostDetailScreen extends StatefulWidget {
  final PostPreview post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final PostsRepository _postsRepository = getIt<PostsRepository>();
  final TextEditingController _commentController = TextEditingController();
  late final Stream<List<PostComment>> _commentsStream;
  late final Stream<bool> _likeStatusStream;
  bool _isSendingComment = false;
  bool _isLiking = false;

  @override
  void initState() {
    super.initState();
    final postId = widget.post.id;
    if (postId.isNotEmpty) {
      _commentsStream = _postsRepository.getCommentsStream(postId);
      final currentUser = FirebaseAuth.instance.currentUser;
      _likeStatusStream = currentUser != null
          ? _postsRepository.getLikeStatusStream(postId, currentUser.uid)
          : Stream<bool>.value(false);
      _postsRepository.recordView(postId);
    } else {
      _commentsStream = const Stream.empty();
      _likeStatusStream = Stream<bool>.value(false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _toggleLike(String postId, bool isLiked) async {
    if (_isLiking) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showError('Login to like this post.');
      return;
    }

    setState(() {
      _isLiking = true;
    });

    try {
      if (isLiked) {
        await _postsRepository.unlikePost(postId, userId: currentUser.uid);
      } else {
        await _postsRepository.likePost(postId, userId: currentUser.uid);
      }
    } catch (e) {
      _showError('Unable to update like. Please try again.');
    } finally {
      setState(() {
        _isLiking = false;
      });
    }
  }

  Future<void> _addComment(String postId) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showError('You must be signed in to comment.');
      return;
    }

    final comment = PostComment(
      postId: postId,
      userId: currentUser.uid,
      userAvatar: currentUser.photoURL ?? 'https://via.placeholder.com/40',
      userName: currentUser.displayName ?? 'Anonymous',
      text: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _isSendingComment = true;
    });

    try {
      await _postsRepository.addComment(postId, comment);
      _commentController.clear();
    } catch (e) {
      _showError('Unable to add comment. Please try again.');
    } finally {
      setState(() {
        _isSendingComment = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          title: const Text('Post Detail'),
          leading: BackButton(color: theme.colorScheme.onSurface),
          actions: [
            StreamBuilder<bool>(
              stream: _likeStatusStream,
              builder: (context, likeSnapshot) {
                final isLiked = likeSnapshot.data ?? false;
                return IconButton(
                  onPressed: () => _toggleLike(widget.post.id, isLiked),
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : theme.colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.bookmark_border),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.post.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DifficultyBadge(label: widget.post.difficulty),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(widget.post.avatarUrl),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post.username,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.post.timestamp,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StreamBuilder<int>(
                          stream: _postsRepository.getLikesCountStream(widget.post.id),
                          builder: (context, likesSnapshot) {
                            final likesCount = likesSnapshot.data ?? widget.post.likes;
                            return _buildStatItem(
                              Icons.thumb_up_alt_outlined,
                              likesCount.toString(),
                              context,
                            );
                          },
                        ),
                        StreamBuilder<int>(
                          stream: _postsRepository.getCommentsCountStream(widget.post.id),
                          builder: (context, commentsSnapshot) {
                            final commentCount = commentsSnapshot.data ?? widget.post.comments;
                            return _buildStatItem(
                              Icons.chat_bubble_outline,
                              commentCount.toString(),
                              context,
                            );
                          },
                        ),
                        StreamBuilder<int>(
                          stream: _postsRepository.getViewsCountStream(widget.post.id),
                          builder: (context, viewsSnapshot) {
                            final viewsCount = viewsSnapshot.data ?? widget.post.views;
                            return _buildStatItem(
                              Icons.remove_red_eye_outlined,
                              viewsCount.toString(),
                              context,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TabBar(
                indicatorColor: theme.colorScheme.primary,
                labelColor: theme.colorScheme.onSurface,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                tabs: const [
                  Tab(text: 'Approach'),
                  Tab(text: 'Code'),
                  Tab(text: 'Discussion'),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildApproachTab(context),
                    _buildCodeTab(context),
                    _buildDiscussionTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          height: 88,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.comment_outlined,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Write a comment...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _addComment(widget.post.id),
                        icon: _isSendingComment
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(Icons.send, color: theme.colorScheme.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApproachTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        widget.post.approach,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.7),
      ),
    );
  }

  Widget _buildCodeTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            widget.post.code,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: Colors.white,
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscussionTab(BuildContext context) {
    return StreamBuilder<List<PostComment>>(
      stream: _commentsStream,
      builder: (context, snapshot) {
        final comments = snapshot.data ?? [];

        if (comments.isEmpty) {
          return Center(
            child: Text(
              'No comments yet. Be the first to start the discussion.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: comments.length,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            return _buildCommentRow(context, comments[index]);
          },
        );
      },
    );
  }

  Widget _buildCommentRow(BuildContext context, PostComment comment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(comment.userAvatar),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      comment.userName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _formatTimestamp(comment.timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  comment.text,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
    }
    return 'Just now';
  }

  Widget _buildStatItem(IconData icon, String label, BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
