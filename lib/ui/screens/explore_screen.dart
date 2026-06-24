import 'package:flutter/material.dart';
import 'package:problem_solvers_hub/core/service_locator.dart';
import 'package:problem_solvers_hub/features/feed/widgets/post_card.dart';
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

  List<Post> _allPosts = [];
  List<Post> _displayedPosts = [];
  List<String> _topics = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
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
      final matchesSearch = normalizedQuery.isEmpty ||
          post.problemTitle.toLowerCase().contains(normalizedQuery) ||
          post.userName.toLowerCase().contains(normalizedQuery) ||
          post.tags.any((tag) => tag.toLowerCase().contains(normalizedQuery));
      return matchesTopic && matchesSearch;
    }).toList();
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          IconButton(
            onPressed: _showSortOptions,
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 22),
              Text(
                'Search by topic or challenge',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              _buildSearchBar(context),
              const SizedBox(height: 22),
              _buildTopicsSection(),
              const SizedBox(height: 24),
              _buildPostsHeader(context),
              Expanded(
                child: _errorMessage != null
                    ? _buildErrorState()
                    : _buildPostsContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(128, 128, 128, 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterPosts,
        decoration: InputDecoration(
          hintText: 'Search problems, tags, authors...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _filterPosts('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTopicsSection() {
    if (_topics.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(label: 'Trending topics'),
        const SizedBox(height: 12),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _topics.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final topic = _topics[index];
              final isSelected = topic == _selectedTopic;

              return FilterChip(
                label: Text(topic),
                selected: isSelected,
                onSelected: (_) => _selectTopic(topic),
                backgroundColor: const Color(0xFFE8EBFF),
                selectedColor: const Color(0xFF4A6CF7),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? Colors.transparent : Colors.transparent,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPostsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SectionTitle(label: 'Top insights'),
        Text(
          '${_displayedPosts.length} posts',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF64748B),
              ),
        ),
      ],
    );
  }

  Widget _buildPostsContent() {
    if (_isLoading && _displayedPosts.isEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 180,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }

    if (_displayedPosts.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      controller: _scrollController,
      itemCount: _displayedPosts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return PostCard(post: _displayedPosts[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No posts yet' : 'No results found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Be the first to share a problem solution!'
                : 'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF64748B),
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              _filterPosts('');
              _selectTopic('All');
            },
            child: const Text('Clear filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF64748B),
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