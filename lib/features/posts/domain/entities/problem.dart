class Problem {
  final String? id;
  final String problemName;
  final String normalizedName;
  final String problemLink;
  final String platform;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int solutionCount;

  Problem({
    this.id,
    required this.problemName,
    required this.normalizedName,
    required this.problemLink,
    required this.platform,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.solutionCount = 0,
  });
}
