import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:problem_solvers_hub/features/auth/presentation/providers/auth_providers.dart';
import 'package:problem_solvers_hub/ui/widgets/section_title.dart';

final userPostsStreamProvider = StreamProvider.autoDispose.family<List<Map<String, dynamic>>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('posts')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) {
        final posts = snapshot.docs
            .map((doc) => doc.data())
            .cast<Map<String, dynamic>>()
            .toList();
        posts.sort((a, b) {
          final aTs = a['timestamp'] as Timestamp?;
          final bTs = b['timestamp'] as Timestamp?;
          if (aTs == null && bTs == null) return 0;
          if (aTs == null) return 1;
          if (bTs == null) return -1;
          return bTs.compareTo(aTs);
        });
        return posts;
      });
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(77)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeItem(String badge, String subtitle, IconData icon, Color color, {required bool active}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: active ? color.withAlpha(38) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active ? color.withAlpha(77) : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? color : Colors.grey, size: 24),
          const SizedBox(height: 8),
          Text(
            badge,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: active ? const Color(0xFF334155) : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: active ? color.withAlpha(204) : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(79, 70, 229, 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF4F46E5), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 18),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    return authState.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      ),
      data: (user) {
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Not Authenticated',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please log in to view your profile',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            ),
          );
        }

        final postsAsync = ref.watch(userPostsStreamProvider(user.id));
        final userPosts = postsAsync.value ?? [];
        final postCount = userPosts.length;
        final totalComments = userPosts.fold<int>(0, (total, post) =>
            total + (post['comments'] as int? ?? 0));
        final totalLikes = userPosts.fold<int>(0, (total, post) =>
            total + (post['likes'] as int? ?? 0));
        final hasProblemSolver = postCount >= 1;
        final hasTopContributor = totalLikes >= 10 || postCount >= 3;
        final hasCodeMaster = userPosts.any((post) =>
            (post['codeSnippet'] as String?)?.trim().isNotEmpty == true);
        final hasDiscussionExpert = totalComments >= 5 || postCount >= 2;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 0,
                pinned: true,
                title: const Text('Profile'),
                actions: [
                  IconButton(
                    onPressed: () {
                      // Edit profile
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit profile coming soon')),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/auth');
                      }
                    },
                    icon: const Icon(Icons.logout_outlined),
                  ),
                ],
              ),
              // Content
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Cover Image Section
                    Container(
                      height: 140,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Decorative circles
                          Positioned(
                            right: -30,
                            top: -30,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(255, 255, 255, 0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            left: -20,
                            bottom: -20,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(255, 255, 255, 0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Profile Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Transform.translate(
                        offset: const Offset(0, -50),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                                const BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.08),
                                  blurRadius: 24,
                                  offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // Avatar
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromRGBO(0, 0, 0, 0.1),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: user.photoUrl != null
                                    ? CircleAvatar(
                                        backgroundImage: NetworkImage(user.photoUrl!),
                                      )
                                    : Center(
                                        child: Text(
                                          user.displayName.isNotEmpty
                                              ? user.displayName[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 16),
                              // Name
                              Text(
                                user.displayName,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22,
                                ) ?? const TextStyle(),
                              ),
                              const SizedBox(height: 4),
                              // Email
                              Text(
                                user.email,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF64748B),
                                ) ?? const TextStyle(),
                              ),
                              const SizedBox(height: 4),
                              // Member since
                              Text(
                                'Member since ${user.createdAt.year}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Stats
                              Row(
                                children: [
                                  _buildStatCard('Solved', '$postCount', const Color(0xFF10B981)),
                                  const SizedBox(width: 8),
                                  _buildStatCard('Comments', '$totalComments', const Color(0xFF3B82F6)),
                                  const SizedBox(width: 8),
                                  _buildStatCard('Likes', '$totalLikes', const Color(0xFFF59E0B)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Badges Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionTitle(label: 'Achievements'),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.1,
                            children: [
                              _buildBadgeItem(
                                'Problem Solver',
                                '$postCount post${postCount == 1 ? '' : 's'}',
                                Icons.check_circle_outline,
                                const Color(0xFF10B981),
                                active: hasProblemSolver,
                              ),
                              _buildBadgeItem(
                                'Top Contributor',
                                '$totalLikes likes',
                                Icons.star_outline,
                                const Color(0xFFF59E0B),
                                active: hasTopContributor,
                              ),
                              _buildBadgeItem(
                                'Code Master',
                                hasCodeMaster ? 'Code examples added' : 'Add code snippets',
                                Icons.code,
                                const Color(0xFF3B82F6),
                                active: hasCodeMaster,
                              ),
                              _buildBadgeItem(
                                'Discussion Expert',
                                '$totalComments comments',
                                Icons.chat_bubble_outline,
                                const Color(0xFF8B5CF6),
                                active: hasDiscussionExpert,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Skills Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionTitle(label: 'Skills & Interests'),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              'Flutter',
                              'Dart',
                              'Firebase',
                              'UI/UX',
                              'API Design',
                              'Database',
                            ]
                                .map(
                                  (skill) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(79, 70, 229, 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color.fromRGBO(79, 70, 229, 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      skill,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF4F46E5),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Recent Activity Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionTitle(label: 'Recent Activity'),
                          const SizedBox(height: 12),
                          postsAsync.when(
                            data: (posts) {
                              if (posts.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Text(
                                    'You have not posted yet. Create your first post to see it here.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                );
                              }

                              final recentPosts = posts.take(3).toList();
                              return Column(
                                children: recentPosts.map((post) {
                                  final title = (post['problemTitle'] as String?)?.trim().isNotEmpty == true
                                      ? post['problemTitle'] as String
                                      : 'Untitled Problem';
                                  final description = '${post['platform'] ?? 'Unknown platform'} · ${post['difficulty'] ?? 'Unknown difficulty'}';
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _buildActivityItem(
                                      title,
                                      description,
                                      Icons.edit_note_outlined,
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (error, _) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'Failed to load recent activity.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Account Settings Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Settings coming soon'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.settings_outlined),
                          label: const Text('Account Settings'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}