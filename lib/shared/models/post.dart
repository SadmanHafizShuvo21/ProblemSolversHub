class Post {
  final String? id; // Firestore document ID
  final String userId; // Author's user ID
  final String userAvatar;
  final String userName;
  final String problemTitle;
  final String platform;
  final String difficulty;
  final List<String> tags;
  final String approachPreview;
  final String approachFull;
  final String codeSnippet;
  final int likes;
  final int comments;
  final int views;
  final DateTime timestamp;

  const Post({
    this.id,
    required this.userId,
    required this.userAvatar,
    required this.userName,
    required this.problemTitle,
    required this.platform,
    required this.difficulty,
    required this.tags,
    required this.approachPreview,
    required this.approachFull,
    required this.codeSnippet,
    required this.likes,
    required this.comments,
    required this.views,
    required this.timestamp,
  });
}
