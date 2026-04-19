class PostPreview {
  final String id;
  final String username;
  final String avatarUrl;
  final String difficulty;
  final String title;
  final String platform;
  final List<String> tags;
  final String preview;
  final int likes;
  final int comments;
  final int views;
  final String timestamp;
  final String approach;
  final String code;

  const PostPreview({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.difficulty,
    required this.title,
    required this.platform,
    required this.tags,
    required this.preview,
    required this.likes,
    required this.comments,
    required this.views,
    required this.timestamp,
    required this.approach,
    required this.code,
  });
}

class CommentPreview {
  final String username;
  final String avatarUrl;
  final String text;
  final String timestamp;

  const CommentPreview({
    required this.username,
    required this.avatarUrl,
    required this.text,
    required this.timestamp,
  });
}

class ProfileBadge {
  final String title;
  final String description;

  const ProfileBadge({required this.title, required this.description});
}

class ProfileActivity {
  final String title;
  final String subtitle;
  final String timestamp;

  const ProfileActivity({
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });
}

const kFeedTopics = [
  'DP',
  'Graphs',
  'Greedy',
  'Trees',
  'Strings',
  'Math',
  'Binary Search',
  'Brainteasers',
];

const kFeedPosts = [
  PostPreview(
    id: 'post-1',
    username: 'Aria Chen',
    avatarUrl:
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=80&q=80',
    difficulty: 'Intermediate',
    title: 'Merge Intervals using Sweep Line',
    platform: 'LeetCode',
    tags: ['Intervals', 'Sorting', 'Greedy'],
    preview:
        'Sort intervals by start time and merge overlapping segments with a simple scan.',
    likes: 124,
    comments: 24,
    views: 820,
    timestamp: '2h ago',
    approach:
        'Sort intervals by their starting point, then iterate through the sorted list while maintaining a current range. If the next interval overlaps, merge the intervals into one combined range; otherwise, append the current range and move forward.',
    code: '''List<Interval> merge(List<Interval> intervals) {
  intervals.sort((a, b) => a.start.compareTo(b.start));
  final merged = <Interval>[];
  for (final interval in intervals) {
    if (merged.isEmpty || merged.last.end < interval.start) {
      merged.add(interval);
    } else {
      merged.last = Interval(merged.last.start, max(merged.last.end, interval.end));
    }
  }
  return merged;
}''',
  ),
  PostPreview(
    id: 'post-2',
    username: 'Mira Patel',
    avatarUrl:
        'https://images.unsplash.com/photo-1502685104226-ee32379fefbe?auto=format&fit=crop&w=80&q=80',
    difficulty: 'Advanced',
    title: 'Optimizing Dijkstra for large graphs',
    platform: 'Codeforces',
    tags: ['Graphs', 'Heap', 'Shortest Path'],
    preview:
        'Use a min-heap and adjacency list to keep complexity down to O(m log n).',
    likes: 98,
    comments: 16,
    views: 640,
    timestamp: '5h ago',
    approach:
        'Maintain a priority queue keyed by distance and relax edges only when a shorter path is found. Represent graph edges compactly to reduce memory churn and avoid repeated heap inserts by checking current distances.',
    code: '''void dijkstra(int src) {
  fill(dist, dist + n, INF);
  dist[src] = 0;
  pq.push({0, src});
  while (!pq.empty()) {
    auto [d, u] = pq.top(); pq.pop();
    if (d > dist[u]) continue;
    for (auto &edge : adj[u]) {
      if (dist[edge.to] > d + edge.weight) {
        dist[edge.to] = d + edge.weight;
        pq.push({dist[edge.to], edge.to});
      }
    }
  }
}''',
  ),
  PostPreview(
    id: 'post-3',
    username: 'Noah Kim',
    avatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=80&q=80',
    difficulty: 'Beginner',
    title: 'Two Sum with Hashing',
    platform: 'HackerRank',
    tags: ['HashMap', 'Arrays'],
    preview:
        'Use a single pass hash map to store seen values and lookup complements instantly.',
    likes: 210,
    comments: 42,
    views: 1020,
    timestamp: '1d ago',
    approach:
        'Iterate through the array once, and for each element compute the complement target - nums[i]. If it exists in the map, return current index and complement index. Otherwise, store the current value in the map for future lookups.',
    code: '''Map<int, int> memo = {};
for (int i = 0; i < nums.length; i++) {
  final complement = target - nums[i];
  if (memo.containsKey(complement)) {
    return [memo[complement]!, i];
  }
  memo[nums[i]] = i;
}
return [];''',
  ),
];

const kDiscussionComments = [
  CommentPreview(
    username: 'Lina',
    avatarUrl:
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=80&q=80',
    text:
        'This approach is nice and clean. The edge cases are easy to cover too.',
    timestamp: '30m ago',
  ),
  CommentPreview(
    username: 'Omar',
    avatarUrl:
        'https://images.unsplash.com/photo-1544723795-3fb6469f5b39?auto=format&fit=crop&w=80&q=80',
    text: 'I found this helpful for understanding interval comparisons.',
    timestamp: '1h ago',
  ),
  CommentPreview(
    username: 'Sofia',
    avatarUrl:
        'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=80&q=80',
    text: 'Can this be extended to merge k sorted lists?',
    timestamp: '2h ago',
  ),
];

const kProfileBadges = [
  ProfileBadge(title: 'Top 10%', description: 'Consistent problem solver'),
  ProfileBadge(title: 'Quick Solver', description: 'Fastest time under 5m'),
  ProfileBadge(title: 'Discussion Leader', description: 'Active commentator'),
];

const kProfileActivities = [
  ProfileActivity(
    title: 'Published a new problem breakdown',
    subtitle: 'Merge Intervals explained',
    timestamp: '3h ago',
  ),
  ProfileActivity(
    title: 'Commented on',
    subtitle: 'Optimizing Dijkstra for large graphs',
    timestamp: '5h ago',
  ),
  ProfileActivity(
    title: 'Added a new friend',
    subtitle: 'Connected with Mira Patel',
    timestamp: '7h ago',
  ),
];

const kFriends = [
  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=80&q=80',
  'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=80&q=80',
  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=80&q=80',
  'https://images.unsplash.com/photo-1502685104226-ee32379fefbe?auto=format&fit=crop&w=80&q=80',
];
