class ProblemSolution {
  final String problemName;
  final String problemLink;
  final String platform;
  final String difficulty;
  final List<String> tags;
  final String approachExplanation;
  final String codeSnippet;
  final String timeComplexity;
  final String spaceComplexity;
  final List<String> keyLearnings;
  final String createdBy;
  final String createdByName;
  final String createdByAvatar;
  final DateTime createdAt;
  final int likes;
  final int views;

  ProblemSolution({
    required this.problemName,
    required this.problemLink,
    required this.platform,
    required this.difficulty,
    required this.tags,
    required this.approachExplanation,
    required this.codeSnippet,
    required this.timeComplexity,
    required this.spaceComplexity,
    required this.keyLearnings,
    required this.createdBy,
    required this.createdByName,
    required this.createdByAvatar,
    required this.createdAt,
    this.likes = 0,
    this.views = 0,
  });
}
