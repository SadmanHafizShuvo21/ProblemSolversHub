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
  final String? problemLink; // Optional field for problem link
  final String? timeComplexity; // Optional field for time complexity
  final String? spaceComplexity; // Optional field for space complexity
  final List<String>? keyLearnings; // Optional field for key learnings

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
    this.problemLink, // Optional field for problem link
    this.timeComplexity, // Optional field for time complexity
    this.spaceComplexity, // Optional field for space complexity
    this.keyLearnings, // Optional field for key learnings
    required this.timestamp,
  });

  String? get title => null;

  Post copyWith({
    String? id,
    String? userId,
    String? userAvatar,
    String? userName,
    String? problemTitle,
    String? platform,
    String? difficulty,
    List<String>? tags,
    String? approachPreview,
    String? approachFull,
    String? codeSnippet,
    int? likes,
    int? comments,
    int? views,
    DateTime? timestamp,
    String? problemLink,
    String? timeComplexity,
    String? spaceComplexity,
    List<String>? keyLearnings,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userAvatar: userAvatar ?? this.userAvatar,
      userName: userName ?? this.userName,
      problemTitle: problemTitle ?? this.problemTitle,
      platform: platform ?? this.platform,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      approachPreview: approachPreview ?? this.approachPreview,
      approachFull: approachFull ?? this.approachFull,
      codeSnippet: codeSnippet ?? this.codeSnippet,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      views: views ?? this.views,
      timestamp: timestamp ?? this.timestamp,
      problemLink: problemLink ?? this.problemLink,
      timeComplexity: timeComplexity ?? this.timeComplexity,
      spaceComplexity: spaceComplexity ?? this.spaceComplexity,
      keyLearnings: keyLearnings ?? this.keyLearnings,
    );
  }
}
