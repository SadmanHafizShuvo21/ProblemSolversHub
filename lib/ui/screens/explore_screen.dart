import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:problem_solvers_hub/core/service_locator.dart';
import 'package:problem_solvers_hub/features/posts/domain/repositories/posts_repository.dart';
import 'package:problem_solvers_hub/shared/models/post.dart';
import 'package:problem_solvers_hub/ui/widgets/section_title.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final PostsRepository _postsRepository = getIt<PostsRepository>();

  String _searchQuery = '';
  String _selectedTopic = 'All';
  bool _isLoading = true;
  String? _errorMessage;
  bool _searchFocused = false;
  int _hoveredTopicIndex = -1;
  int _hoveredPostIndex = -1;
  final Set<String> _viewedPostKeys = {};
  final Set<String> _likedPostKeys = {};

  final FocusNode _searchFocusNode = FocusNode();

  List<Post> _allPosts = [];
  List<Post> _displayedPosts = [];
  List<String> _topics = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final posts = await _postsRepository.getAllPosts();
      final topics = _extractTopics(posts);

      setState(() {
        _allPosts = posts;
        _topics = ['All', ...topics];
        _displayedPosts = _applyFilters(posts, _searchQuery, _selectedTopic);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load posts: $e';
        _isLoading = false;
      });
    }
  }

  List<String> _extractTopics(List<Post> posts) {
    final topics = <String>{};
    for (final post in posts) {
      topics.addAll(post.tags);
    }
    final sortedTopics = topics.toList()..sort();
    return sortedTopics;
  }

  List<Post> _applyFilters(List<Post> posts, String query, String topic) {
    final normalizedQuery = query.toLowerCase().trim();

    return posts.where((post) {
      final matchesTopic = topic == 'All' || post.tags.contains(topic);
      final matchesSearch =
          normalizedQuery.isEmpty ||
          post.problemTitle.toLowerCase().contains(normalizedQuery) ||
          post.userName.toLowerCase().contains(normalizedQuery) ||
          post.tags.any((tag) => tag.toLowerCase().contains(normalizedQuery));
      return matchesTopic && matchesSearch;
    }).toList();
  }

  void _onSearchFocusChanged() {
    if (_searchFocused != _searchFocusNode.hasFocus) {
      setState(() {
        _searchFocused = _searchFocusNode.hasFocus;
      });
    }
  }

  String _userKeyForPost(Post post) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final postKey = post.id ?? post.problemTitle;
    return '$userId|$postKey';
  }

  void _updatePostInLists(Post updatedPost) {
    _allPosts = _allPosts
        .map((post) => post.id == updatedPost.id ? updatedPost : post)
        .toList();
    _displayedPosts = _displayedPosts
        .map((post) => post.id == updatedPost.id ? updatedPost : post)
        .toList();
  }

  Future<void> _incrementPostView(Post post) async {
    final key = _userKeyForPost(post);
    if (_viewedPostKeys.contains(key)) return;

    _viewedPostKeys.add(key);
    try {
      if (post.id != null) {
        await _postsRepository.recordView(post.id!);
      }
    } catch (_) {
      // Ignore view update failures, keep local UX consistent.
    }

    final updated = post.copyWith(views: post.views + 1);
    setState(() {
      _updatePostInLists(updated);
    });
  }

  Future<void> _toggleLove(Post post) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to love this post.')),
      );
      return;
    }

    final key = _userKeyForPost(post);
    if (_likedPostKeys.contains(key)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You already loved this post.')),
      );
      return;
    }

    _likedPostKeys.add(key);
    try {
      if (post.id != null) {
        await _postsRepository.likePost(post.id!);
      }
    } catch (_) {
      // Ignore like failures for now, still keep the UI optimistic.
    }

    final updated = post.copyWith(likes: post.likes + 1);
    setState(() {
      _updatePostInLists(updated);
    });
  }

  Future<void> _refreshPosts() async {
    await _loadInitialData();
  }

  void _filterPosts(String query) {
    setState(() {
      _searchQuery = query;
      _displayedPosts = _applyFilters(_allPosts, _searchQuery, _selectedTopic);
    });
  }

  void _selectTopic(String topic) {
    setState(() {
      _selectedTopic = topic;
      _displayedPosts = _applyFilters(_allPosts, _searchQuery, _selectedTopic);
    });
  }

  void _onScroll() {
    // Keep the scroll controller for future pagination or sticky UI features.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = const Color(0xFF6366F1);
    final secondaryAccent = const Color(0xFFF97316);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent.withOpacity(0.95),
                  secondaryAccent.withOpacity(0.18),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Explore',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Fresh ideas from the community',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          actions: [
            _buildAppBarIcon(
              icon: Icons.sort_rounded,
              background: Colors.white.withOpacity(0.12),
              iconColor: Colors.white,
              onTap: _showSortOptions,
            ),
            _buildAppBarIcon(
              icon: Icons.tune_rounded,
              background: Colors.white.withOpacity(0.12),
              iconColor: Colors.white,
              onTap: _showFilterDialog,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.background,
              theme.colorScheme.primary.withOpacity(0.04),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _refreshPosts,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildSearchBar(context),
                      const SizedBox(height: 18),
                      _buildTopicsSection(theme),
                      const SizedBox(height: 22),
                      _buildPostsHeader(theme),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              if (_errorMessage != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildErrorState(theme),
                  ),
                )
              else if (_isLoading && _displayedPosts.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 190,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                      ),
                      childCount: 4,
                    ),
                  ),
                )
              else if (_displayedPosts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildEmptyState(theme),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final post = _displayedPosts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: _buildExploreCard(context, index, post, theme),
                        );
                      },
                      childCount: _displayedPosts.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarIcon({
    required IconData icon,
    required Color background,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, size: 22, color: iconColor),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final isFocused =
        _searchFocusNode.hasFocus || _searchController.text.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        gradient: isFocused
            ? LinearGradient(
                colors: [
                  const Color(0xFF6366F1).withOpacity(0.18),
                  const Color(0xFFEC4899).withOpacity(0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused
              ? const Color(0xFF6366F1)
              : theme.dividerColor.withOpacity(0.5),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isFocused ? 0.12 : 0.04),
            blurRadius: isFocused ? 14 : 8,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isFocused
                  ? const Color(0xFF6366F1)
                  : theme.colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.search_rounded,
              size: 20,
              color: isFocused ? Colors.white : const Color(0xFF65748B),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              focusNode: _searchFocusNode,
              controller: _searchController,
              onChanged: _filterPosts,
              cursorColor: const Color(0xFF6366F1),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                hintText: 'Search problems, tags, authors...',
                hintStyle: TextStyle(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.68),
                ),
                border: InputBorder.none,
                isDense: true,
                suffixIcon: AnimatedOpacity(
                  opacity: _searchController.text.isNotEmpty ? 1 : 0,
                  duration: const Duration(milliseconds: 220),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: const Icon(
                      Icons.clear_rounded,
                      color: Color(0xFF94A3B8),
                      size: 18,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _filterPosts('');
                      _searchFocusNode.unfocus();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsSection(ThemeData theme) {
    if (_topics.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.trending_up_rounded, color: Color(0xFF6366F1)),
            const SizedBox(width: 10),
            Text(
              'Trending topics',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 54,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _topics.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final topic = _topics[index];
              final isSelected = topic == _selectedTopic;
              final colorA = _topicGradientColor(index);
              final colorB = Color.alphaBlend(
                colorA.withOpacity(0.46),
                theme.colorScheme.surface,
              );

              return MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _hoveredTopicIndex = index),
                onExit: (_) => setState(() => _hoveredTopicIndex = -1),
                child: GestureDetector(
                  onTap: () => _selectTopic(topic),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [colorA, colorB],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : theme.dividerColor.withOpacity(0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            isSelected || _hoveredTopicIndex == index
                                ? 0.14
                                : 0.06,
                          ),
                          blurRadius: isSelected || _hoveredTopicIndex == index
                              ? 22
                              : 12,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle : Icons.tag_rounded,
                          size: 18,
                          color: isSelected ? Colors.white : colorA,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          topic,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Swipe through topics and find the newest problem solutions with bold colors and fast navigation.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.72),
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildPostsHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionTitle(label: 'Top insights'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_displayedPosts.length} posts',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Tap any card to explore the full approach and see why the community loves it.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildPostsContent(ThemeData theme) {
    if (_isLoading && _displayedPosts.isEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 190,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        ),
      );
    }

    if (_displayedPosts.isEmpty) {
      return _buildEmptyState(theme);
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 6, bottom: 24),
      itemCount: _displayedPosts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        final post = _displayedPosts[index];
        return _buildExploreCard(context, index, post, theme);
      },
    );
  }

  Widget _buildExploreCard(
    BuildContext context,
    int index,
    Post post,
    ThemeData theme,
  ) {
    final isHovered = _hoveredPostIndex == index;
    final gradientStart = _topicGradientColor(index);
    final gradientEnd = gradientStart.withOpacity(0.12);
    final liked = _likedPostKeys.contains(_userKeyForPost(post));

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredPostIndex = index),
      onExit: (_) => setState(() => _hoveredPostIndex = -1),
      child: GestureDetector(
        onTap: () {
          _incrementPostView(post);
          GoRouter.of(context).go('/post', extra: post);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          transform: Matrix4.translationValues(0, isHovered ? -4 : 0, 0),
          transformAlignment: Alignment.center,
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.surface, gradientEnd],
              begin: Alignment.topCenter,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isHovered ? 0.14 : 0.08),
                blurRadius: isHovered ? 28 : 18,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: gradientStart.withOpacity(0.16),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  gradient: LinearGradient(
                    colors: [gradientStart, gradientStart.withOpacity(0.1)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(post.userAvatar),
                          backgroundColor: Colors.grey.shade200,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.userName,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                post.platform,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onBackground
                                      .withOpacity(0.72),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: gradientStart.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            post.difficulty,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: gradientStart,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      post.problemTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: post.tags.take(4).map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: theme.colorScheme.primary
                              .withOpacity(0.1),
                          labelStyle: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      post.approachPreview,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.55,
                        color: theme.colorScheme.onBackground.withOpacity(0.76),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatChip(
                          icon: Icons.remove_red_eye_outlined,
                          label: '${post.views}',
                          theme: theme,
                        ),
                        _buildStatChip(
                          icon: Icons.comment_outlined,
                          label: '${post.comments}',
                          theme: theme,
                        ),
                        GestureDetector(
                          onTap: () {
                            _toggleLove(post);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 280),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: liked
                                  ? const Color(0xFFFB7185).withOpacity(0.18)
                                  : theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: liked
                                    ? const Color(0xFFFB7185)
                                    : theme.dividerColor.withOpacity(0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  liked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 20,
                                  color: liked
                                      ? const Color(0xFFFB7185)
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${post.likes} love',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: liked
                                        ? const Color(0xFFDB2777)
                                        : theme.colorScheme.onBackground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onBackground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 62,
            color: theme.colorScheme.onBackground.withOpacity(0.35),
          ),
          const SizedBox(height: 18),
          Text(
            _searchQuery.isEmpty ? 'No posts yet' : 'No results found',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            _searchQuery.isEmpty
                ? 'Try refreshing or check back soon for fresh solutions.'
                : 'Refine your search or switch a topic to find more posts.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.72),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              _filterPosts('');
              _selectTopic('All');
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Clear filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text('Something went wrong', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? 'Unknown error',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.72),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refreshPosts,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Color _topicGradientColor(int index) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFFE879F9),
      const Color(0xFFF97316),
      const Color(0xFF22C55E),
      const Color(0xFFEC4899),
      const Color(0xFF0EA5E9),
    ];
    return colors[index % colors.length];
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sort by',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSortOption('Latest', Icons.access_time, 'timestamp'),
            _buildSortOption('Popular', Icons.trending_up, 'upvotes'),
            _buildSortOption('Most discussed', Icons.comment, 'comments'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, IconData icon, String field) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        // In a real implementation, you would sort by this field
        // Since we're using Firestore, you'd need to re-query with orderBy
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sorting by $label (not implemented)')),
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Posts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select topics to filter:'),
            const SizedBox(height: 16),
            if (_topics.isEmpty)
              const CircularProgressIndicator()
            else
              Wrap(
                spacing: 8,
                children: _topics.map((topic) {
                  final isSelected = _selectedTopic == topic;
                  return ChoiceChip(
                    label: Text(topic),
                    selected: isSelected,
                    onSelected: (selected) {
                      _selectTopic(topic);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _selectTopic('All');
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
